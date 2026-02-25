+++
date = '2026-01-10'
#showDateUpdated =
showTableOfContents = true
#showWordCount =
title = 'GitOps Principles with Flux CD'
#description = 'First time installing Arch Linux'
draft = false
+++

This article documents my understanding of GitOps and it's application to kubernetes clusters.

## What is GitOps

[GitOps](https://www.gitops.tech/#what-is-gitops)is a set of best practices where the entire code delivery process is controlled via Git, including infrastructure and application definition as code, with automation to complete updates and rollbacks. The entire system is described declaratively, with its desired state versioned in Git, approved changes automatically applied, and software agents ensuring correctness while alerting on divergence.

In terms of workflow, a Git repository holds all configuration for applications and infrastructure. A GitOps controller then runs a constant loop, pulling changes and deployment information to match the Git state with the cluster state.

This approach carries significant benefits: it provides version control and a full history of changes, enables team collaboration through Git workflows, improves security by reducing direct cluster access, and facilitates automation for updates and rollbacks.

---
## Flux CD

### What is Flux CD
[Flux CD](https://fluxcd.io/) is an open-source continuous delivery tool designed to automate Kubernetes application deployments using GitOps. It runs as a set of controllers inside a  Kubernetes cluster that continuously monitor connected Git repositories for changes.

When code is updated in a monitored repository, Flux CD synchronises the state of the cluster by applying only the necessary changes i.e adding, modifying, or deleting Kubernetes resources. This ensures consistent, version-controlled deployments with minimal manual intervention and rollback-friendly workflows. 

FluxCD integrates easily with:
- Kubernetes
- Helm
- Grafana
- Istio
- Prometheus
- Linkerd
- Kyverno
- SOPS

In addition to offering the following features:
- Automating image patches and updates based on scans of your deployed containers, with pushes back to your Git repository.
- Multi-tenant enabled architecture support making Flux CD suitable for clusters that serve multiple teams and apps.
- A [rich ecosystem](https://fluxcd.io/ecosystem) of extensions, interfaces, and compatible development platforms that let you customise your Flux CD experience to match the way you work.

### Flux CD vs Argo CD
I chose Flux for it's simpler setup and less overwhelming interface, emphasis on CLI usage and GitOps thinking.
In addition to it's heavy reliance on Kustomize, a templating language for Kubernetes manifest that allows for the declarative management of Kubernetes objects.
### Flux Bootstrap

[https://fluxcd.io/flux/installation/](https://fluxcd.io/flux/installation/)  
Installed flux locally
```sh
yay -S flux-bin
```

Generated a Github [Personal Access Token](https://help.github.com/en/github/authenticating-to-github/creating-a-personal-access-token-for-the-command-line)

Export PAT as an environmental variable
```sh
export GITHUB_TOKEN=<gh-token>
```


{{< alert cardColor="#80AA9E" textColor="#1B1B1B" >}}
**Note!** - Flux uses the current cluster context, make sure the correct context is set before bootstraping
{{< /alert >}}

```sh
flux bootstrap github \
  --token-auth \
  --owner=ksefuke-labs \
  --repository=kubernetes-homelab \
  --branch=main \
  --path=clusters/staging \
  --personal
```
### Repo structure
[Flux CD - Repository-Structure](https://fluxcd.io/flux/guides/repository-structure/)  
For simplicity i will be going for a monorepo approach, which is were you store all your Kubernetes manifests in a single Git repository. The various environments specific configs are all stored in the same branch.  
Each cluster state is defined in a dedicated directory e.g. `clusters/production` where the specific apps and infrastructure overlays are referenced. 

The separation between apps and infrastructure makes it possible to define the order in which a cluster is reconciled, e.g. first the cluster addons and other Kubernetes controllers, then the applications.
```console
├── apps
│   ├── base
│   ├── production 
│   └── staging
├── infrastructure
│   ├── base
│   ├── production 
│   └── staging
└── clusters
    ├── production
    └── staging
```

### Reconciliation and Kustomization
**Reconciliation** is the process where Flux fetches the latest state from your Git repository, compares it with the current cluster state, applies any differences to bring the cluster in line with Git and reports the status back.
GitRepository → Kustomization → Reconciliation Loop → Cluster State

1. **Kustomization defines the rules**: You create a Kustomization resource that specifies which path in your Git repo to watch and how often to reconcile
2. **Reconciliation executes the rules**: Every `interval` (e.g., every 10 minutes), Flux's kustomize-controller:
- Pulls from the GitRepository - Builds the Kustomize overlay from the specified path
- Applies resources to the cluster - Performs health checks
- Updates the Kustomization status

3. **Continuous sync**: This happens automatically and continuously, creating a self-healing system
- Patches can be applied in app kustomize.yaml files to replace certain values between staging and production workloads i.e staging vs production secrets
- The "base" directory within ./apps hold reference manifest for each applications which are referenced in staging as follows

`./apps/staging/linkding/kustomization.yaml`
```yaml
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
namespace: linkding
resources:
	- ../../base/linkding/
```

`./apps/base/linkding/`
```
./apps/base/linkding
│   ├── kustomization.yaml   # Referenced by ./cluster/flux-systems/apps.yaml, references resources in working dir to deploy
│   ├── deployment.yaml      # Typical deployment manifest
│   └── namespace.yaml       # Typical namespace manifest
```

### Deploying via Helm workloads with Flux CD
Deployment of Helm workloads is done via two source controllers, Helm Repositories and Helm Charts. I will be using the "Kube Prometheus Stack" as an example, which i previously spun up on on my local rancher desktop deployment.

{{< alert cardColor="#80AA9E" textColor="#1B1B1B" >}}
**Note!** -  I will placing all infrastructure related configs file (i.e Monitoring, controllers, security, networking) inside of sub directories of infrastructure. i.e base and staging.
{{< /alert >}}

```bash
├── infrastructure
│   ├── base
│   │   ├── kustomization.yaml
│   │   └── monitoring
│   │       ├── kube-prometheus-stack
│   │       │   ├── kustomization.yaml
│   │       │   ├── namespace.yaml
│   │       │   ├── release.yaml
│   │       │   └── repository.yaml
│   │       └── kustomization.yaml
│   └── staging
│       ├── kustomization.yaml
│       └── monitoring
│           ├── kube-prometheus-stack
│           │   ├── grafana-tls-secret.yaml
│           │   └── kustomization.yaml
│           └── kustomization.yaml
```

[Helm Repositories](https://fluxcd.io/flux/components/source/helmrepositories/)
As the name suggest handles the fetching of a designated Helm repository, equivalent to `helm repo add` with spec.interval option to check periodically for repo updates
```yaml
apiVersion: source.toolkit.fluxcd.io/v1
kind: HelmRepository
metadata:
  name: kube-prometheus-stack
  namespace: monitoring
spec:
  interval: 24h
  url: https://prometheus-community.github.io/helm-charts
```


[Helm Charts](https://fluxcd.io/flux/components/source/helmcharts/)
Handles the installation of a specific chart from the helm repository above, equivalent to `helm install`.  With additional parameters available depending on the helm chart:
- **spec.install.crds: create** - Created custom resource definition upon helm chart installation
- **spec.upgrade.crds: createReplace** - Creates/replace custom resource definitions upon upgrade of helm chart, needed for kube-prom-stack due to CRDs not being deleted/updated automatically when uninstalling or upgrade the [chart](https://github.com/prometheus-community/helm-charts/tree/main/charts/kube-prometheus-stack#uninstall-helm-chart)
- **spec.driftDetection.mode: enabled** - Enables you to detect any unintentional changes to resources in your Kubernetes cluster that may have occurred outside of your Helm release process, particularly important with Flux CD/Gitops
- **spec.values:** - This section is where you add values that override the defaults a chart ships with.

```yaml
apiVersion: helm.toolkit.fluxcd.io/v2
kind: HelmRelease
metadata:
  name: kube-prometheus-stack
  namespace: monitoring
spec:
  interval: 30m
  chart:
    spec:
      chart: kube-prometheus-stack
      version: "66.2.2"
      sourceRef:
        kind: HelmRepository
        name: kube-prometheus-stack
        namespace: monitoring
      interval: 12h
  install:
    crds: Create
  upgrade:
    crds: CreateReplace
    # Replaces CRDs, this step would have to be done manually after each update
  driftDetection:
    mode: enabled
    ignore:
      # Ignore "validated" annotation which is not inserted during install
      - paths: ["/metadata/annotations/prometheus-operator-validated"]
        target:
          kind: PrometheusRule
  values:
    grafana:
      adminPassword: supersecure password
```

#### Kustomization File Gotcha

Make sure resources directories are listed correctly, otherwise reconciliation will fail.

Incorrect reference of `kubernetes-homelab/infrastructure/staging/monitoring/kube-prometheus-stack`
```yaml
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
namespace: monitoring
resources:
  - ../../base/monitoring/kube-prometheus-stack
```

Fixed reference
```yaml
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
namespace: monitoring
resources:
  - ../../../base/monitoring/kube-prometheus-stack
```

`ls -la` can be used inside the working directory to confirm if pathing is correct
```bash
cd infrastructure/staging/monitoring/kube-prometheus-stack
ls -la ../../../base/monitoring/kube-prometheus-stack | tree
├── grafana-tls-secret.yaml
└── kustomization.yaml
```

---

## GitOps Managed Project

I've deployed [Audiobookshelf](https://www.audiobookshelf.org/)to my K3s Cluster entirely via GitOps. Audiobookshelf is an open-source self-hosted media server for your audiobooks and podcasts. Objectives are as follows:
- Application should run on port 3005, configured via `ConfigMap`
- Have a cluster IP service using port 3005
- Utilise persistent storage
- Exposed via cloudflare Tunnels
- Runs as non root user
- Secrets Encrypted via SOPs

The application doesn't have installation instructions for kubernetes so K8s manifest need to be made from scratch.
Below is the standard docker compose [template](https://www.audiobookshelf.org/docs/#docker-compose-install)
```yaml
services:
  audiobookshelf:
    image: ghcr.io/advplyr/audiobookshelf:latest
    ports:
      - 13378:80
    volumes:
      - </path/to/audiobooks>:/audiobooks
      - </path/to/podcasts>:/podcasts
      - </path/to/config>:/config
      - </path/to/metadata>:/metadata
    environment:
      - TZ=America/Toronto
```

In addition to these useful snippets of [environmental variables](https://www.audiobookshelf.org/docs#env-configuration)
```md
Filesystem
    CONFIG_PATH (default: ./config)
        Path to the config directory.
        It will contain the database (users/books/libraries/settings). This location must not be mounted over the network.
    METADATA_PATH (default: ./metadata)
        Path to the metadata directory.
        It will contain cache, streams, covers, downloads, backups and logs.
    BACKUP_PATH (default: ./metadata/backups)
        Path to where backups are stored.
        Backups contain a backup of the database in /config and images/metadata stored in ./metadata/items and ./metadata/authors

Network
    HOST
        The host Audiobookshelf binds to. Most commonly, this will be 127.0.0.1 if you want the service to listen to localhost only, or left unset           if you want to listen to all interfaces (both IPv4 and IPv6).
    PORT
        The TCP port Audiobookshelf will listen on.

```

Output of `cat /etc/passwd` inside Audiobookshelf's shell reveals an existing non root user
```sh
node:x:1000:1000:Linux User,,,:/home/node:/bin/sh
```

### Manifest Files

<details>

<summary>Deployment.yaml</summary>

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: audiobookshelf

spec:
  replicas: 1
  selector:
    matchLabels:
      app: audiobookshelf
  
  template:
    metadata:
      labels:
        app: audiobookshelf
    spec:
      securityContext:
        fsGroup: 1000
        runAsUser: 1000 
        runAsGroup: 1000

      containers:
      - image: ghcr.io/advplyr/audiobookshelf:2.17.2
        name: audiobookshelf
        envFrom:
          - configMapRef:
              name: abs-configmap

        ports: 
          - containerPort: 3005
            protocol: TCP
        
        securityContext:
            allowPrivilegeEscalation: false
        
        volumeMounts:
          - mountPath: /config
            name: abs-config

          - mountPath: /audiobooks
            name: abs-audiobooks

          - mountPath: /metadata
            name: abs-metadata
          
      restartPolicy: Always
      volumes:
        - name: abs-config
          persistentVolumeClaim:
            claimName: abs-config-pvc

        - name: abs-audiobooks
          persistentVolumeClaim:
            claimName: abs-audiobooks-pvc

        - name: abs-metadata
          persistentVolumeClaim:
            claimName: abs-metadata-pvc

        
```

</details>

**ConfigMap.yaml** - Map port to 3005 using the "PORT" environmental variable listed above
```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: abs-configmap
data:
  PORT: "3005"
```

<details>

<summary>Storage.yaml for audiobooks, config, metadata PVCs</summary>

```yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: abs-config-pvc
  namespace: audiobookshelf
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 5Gi
---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: abs-audiobooks-pvc
  namespace: audiobookshelf
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 5Gi
---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: abs-metadata-pvc
  namespace: audiobookshelf
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 1Gi
```

</details>

**Service.yaml** - Port-forward/ingress/cloudflare tunnels
```yaml
apiVersion: v1
kind: Service
metadata:
  name: audiobookshelf-svc
spec:
  ports:
    - port: 3005
      protocol: TCP
  selector:
    app: audiobookshelf
  type: ClusterIP
```

**Ingress.yaml** - Used to test app access before deployment of cloudflare tunnel
```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: audiobookshelf
  namespace: audiobookshelf
spec:
  ingressClassName: traefik
  rules:
    - host: abs.ksefuke-labs.com
      http:
        paths:
          - backend:
              service:
                name: audiobookshelf
                port:
                  number: 3005
            path: /
            pathType: Prefix
```

**Cloudflare-secret.yaml** - Tunnel Credentials encrypted with SOPs
```yaml
apiVersion: v1
data:
    credentials.json: ENC[AES256_GCM,data:XR5ZoS4wpFAnHV3BUTyPMgxecTQxOFVPEBgOBPVJFo7+7L7l7YW2n7G0vVL5siou0lesMB/L7LShuDM1E2VkOQgLqPPoim3OTYt8Y3lJzd7Wqyz0geywAffpOyFyVZyK8JotlXOitkQzTDUvEsLu4Xq0v6LKIOjLV7OOYtapiAu+6sOReACBgNhDIr+T540l5qi/B3aRNTp8dro/4wc1qzja2e8yVE6M9n6b0M9yRpoC2zsFF9dDQkaeANVU7upFTZ1r6xpKc3kd6g0rgVEOtMBAYeGs/QjfI0eiKghM83x8IA4OuXqQjQR16to=,iv:iTch+p7MzjgOcq4wSkawMZuxfVUNB5hYdC3LL1w91iY=,tag:ilDx2tw/CRMD/nP1huRoYg==,type:str]
kind: Secret
metadata:
    name: abs-tunnel-credentials
sops:
    age:
        - recipient: age1w0ptdg04h8e6d7nmwjj4unuphwstxrw8fmk9e7jhda28re6c8stqtfcsvt
          enc: |
            -----BEGIN AGE ENCRYPTED FILE-----
            YWdlLWVuY3J5cHRpb24ub3JnL3YxCi0+IFgyNTUxOSA2VnZhZWc1TjdOTU5pbHI3
            WUlwR1Mwb3N6NzM1ZFpMTzhIVGdZMGx1bEZZCkU3YTJVQWEzQlRQZXBRQ2lnLy9U
            OWFDQ1dyNEZnaXI1OVB4RnQrZ2lZVWMKLS0tIGlkL1lnckhWdGdhdS9XYkRSMjVM
            MUNFTU9vVFYvWUpkYTlQWWYxclRqVHMKhf/mLewahIrZ6sBS7CriEdIMB8I+W0xx
            //I84/sO+OWOZBqY1fJDTEtrKpkhAaNFVV1KOHHX88lZpskstr1lOQ==
            -----END AGE ENCRYPTED FILE-----
    lastmodified: "2026-01-31T04:31:40Z"
    mac: ENC[AES256_GCM,data:noz0xjeSYP7fIjWOITyAn78bycQCAa2KElteePEQuLb9SoRoTaVSj2nweRmKerqGPVIV3B+oxTyTDBxN1NZgcmSPK7aagAQRkWuoPIOtGoaXgtwX0kvpqgmaoRgzvShr1QomjASBV4eqT0nw3nZYXCzC9ho00l+1AQvV/bJHz1s=,iv:xNHntYpUelqgnwsUaJUqccGRauHr9HMSze3iAAPFpRM=,tag:nj7Tma3E4yc6BDYA3bKe2Q==,type:str]
    encrypted_regex: ^(data|stringData)$
    version: 3.11.0
```

<details>

<summary>Cloudflare.yaml - Tunnel Deployment</summary>

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: cloudflared
spec:
  selector:
    matchLabels:
      app: cloudflared
  replicas: 2
  template:
    metadata:
      labels:
        app: cloudflared
    spec:
      containers:
      - name: cloudflared
        image: cloudflare/cloudflared:latest
        args:
        - tunnel
        - --config # Points cloudflared to the config file, which configures what cloudflared will actually do (ConfigMao) 
        - /etc/cloudflared/config/config.yaml
        - run
        livenessProbe:
          httpGet:
            path: /ready # Cloudflared has a /ready endpoint which returns 200 if and only if it has an active connection to the edge.
            port: 2000
          failureThreshold: 1
          initialDelaySeconds: 10
          periodSeconds: 10
        volumeMounts:
        - name: config
          mountPath: /etc/cloudflared/config
          readOnly: true

        - name: creds # Each tunnel has an associated "credentials file" which authorizes machines to run the tunnel. 
                      #cloudflared will read this file from its local filesystem and it'll be stored in a k8s secret.
          mountPath: /etc/cloudflared/creds
          readOnly: true
      volumes:
      - name: creds
        secret:
          secretName: abs-tunnel-credentials

      # Create a config.yaml file from the ConfigMap below.
      - name: config
        configMap:
          name: cloudflared
          items:
          - key: config.yaml
            path: config.yaml


---
apiVersion: v1
kind: ConfigMap
metadata:
  name: cloudflared
data:
  config.yaml: |
    # Name of the tunnel you want to run
    
    tunnel: abs

    credentials-file: /etc/cloudflared/creds/credentials.json

    # Serves the metrics server under /metrics and the readiness server under /ready
    metrics: 0.0.0.0:2000 
    no-autoupdate: true

    ingress:
    - hostname: abs.ksefuke-labs.com
      service: http://audiobookshelf:3005

    # This rule sends traffic to the built-in hello-world HTTP server. This can help debug connectivity
    # issues. If hello.example.com resolves and tunnel.example.com does not, then the problem is
    # in the connection from cloudflared to your local service, not from the internet to cloudflared.
    - hostname: hello.example.com
      service: hello_world
    # This rule matches any traffic which didn't match a previous rule, and responds with HTTP 404.
    - service: http_status:404

# This ConfigMap is just a way to define the cloudflared config.yaml file in k8s.
# It's useful to define it in k8s, rather than as a stand-alone .yaml file, because
# this lets you use various k8s templating solutions (e.g. Helm charts) to
# parameterize your config, instead of just using string literals.
```

</details>

### Project Repository Structure

**Apps/base** - Files in the directory cover parameter which are unlikely to change.
```txt
base/audiobookshelf
├── configmap.yaml
├── deployment.yaml
├── kustomization.yaml
├── namespace.yaml
├── service.yaml
└── storage.yaml
```

**Apps/staging** - Files in this directory cover parameter which are subject to change/being tested.
```txt
staging/audiobookshelf
├── cloudflare-secret.yaml
├── cloudflare.yaml
├── ingress.yaml
└── kustomization.yaml
```

**Kustomization.yaml** - Located in `apps/staging/audiobookshelf`
This directory is watched by kustomize.toolkit.fluxcd.io/v1 file `apps.yaml` in `cluster/staging`. So flux with reconcile this project deployment to the cluster once these changes have been committed.

```yaml
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
namespace: audiobookshelf
resources:
  - ../../base/audiobookshelf/ # load manifest in base/audiobookshelf
  - cloudflare.yaml
  - cloudflare-secret.yaml
  #- ingress.yaml
```
### Gotchas
- **Service metadata name** - was "audiobook-svc" which cause issues with cloudflared.yaml ingress which was listen for "audiobook"
- **Kubectl secret from-file syntax** - file name when generating the secret i.e from-file=credential.json='"actual file name"
- **Persistent Volume Permission Issues** - Since i created a Pod Deployment with PV and PVCs before modifying `securityContext`, non root PVs and PVCs failed to be provisioned. Deleting the original root PVs and PVCs fixed the issue, this was fine to do since critical data wasn't being stored. But a more precise approach will need to be taken in production environments such as executing into the pods and doing the equivalent of `chown -R user:user` and `chmod 760 -R `

---
## Next Steps
### The 12 Factor App Principles

Going forward I would like to get all my git projects to adhere to [12 factor](https://12factor.net/) principles:
- **[I. Codebase](https://12factor.net/codebase)** - One codebase tracked in revision control, many deploys
- **[II. Dependencies](https://12factor.net/dependencies)** - Explicitly declare and isolate dependencies
- **[III. Config](https://12factor.net/config)** - Store config in the environment
- **[IV. Backing services](https://12factor.net/backing-services)** - Treat backing services as attached resources
- **[V. Build, release, run](https://12factor.net/build-release-run)** - Strictly separate build and run stages
- **[VI. Processes](https://12factor.net/processes)** - Execute the app as one or more stateless processes
- **[VII. Port binding](https://12factor.net/port-binding)** - Export services via port binding
- **[VIII. Concurrency](https://12factor.net/concurrency)** - Scale out via the process model
- **[IX. Disposability](https://12factor.net/disposability)** - Maximise robustness with fast startup and graceful shutdown
- **[X. Dev/prod parity](https://12factor.net/dev-prod-parity)** - Keep development, staging, and production as similar as possible
- **[XI. Logs](https://12factor.net/logs)** - Treat logs as event streams
- **[XII. Admin processes](https://12factor.net/admin-processes)** - Run admin/management tasks as one-off processes

### Kubernetes Homelab Architecture
Now i have experience with deploying kubernetes resources manually and via GitOps it is finally time to scaling up my kubernetes homelab and moving my docker services and testing workflows over to it. All the code mentioned in this article will be available at the repo below.

{{< github repo="ksefuke-labs/kubernetes-homelab" showThumbnail=false >}}


