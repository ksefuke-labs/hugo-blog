+++
date = '2026-01-16'
#showDateUpdated =
#showPagination =
#showReadingTime =
#showTableOfContents =
#showWordCount =
title = 'Encrypting Secrets with SOPs'
description = 'First time installing Arch Linux'
draft = false
+++
---

## Secret Management with SOPs
With my kubernetes homelab infrastructure as code being public, secrets need to be encrypted if they are going to be stored as code. By default secrets are just encoded in base64 which can be decoded by anyone.

A way to resolve this is by using SOPs with flux CD. SOPs is an editor of encrypted files that supports YAML, JSON, ENV, INI and BINARY formats and can encrypt with AWS KMS, GCP KMS, Azure Key Vault, HuaweiCloud KMS and age.

The simplest encryption method to manage secrets at the moment is age, which is a simple, modern and secure file encryption tool. I will consider testing Azure Key Vault in the future.
```sh
paru -S age sops gnupg
age-keygen -o age.agekey
cat age.agekey
```

Example of "age.agekey" file
```
# created: 2026-01-19T17:44:04Z
# public key: age1zd5n9zx0dsdwdggjuvz32ppngn45gk0sdadasdasdsadasdsadaddadada
AGE-SECRET-929VUUUSHGHFEHSJHFHFRHFHJDSHSJHHFHHHFHFHFHFJEUYHAKJFSAE374HH646GC
```

Export public key as environmental
```bash
export AGE_PUBLIC=age1zd5n9zx0dsdwdggjuvz32ppngn45gk0sdadasdasdsadasdsadaddadada
```

Creating a test secret
```bash
kubectl create secret generic test-secret 
\--from-literal=user=lancelot
\--from-literal=password=password123 
\--dry-run=client 
\-o yaml > test-secret.yaml
```

Encrypting test secret
```bash
sops --age=$AGE_PUBLIC 
\--encrypt --encrypted-regex '^(data|stringData)$' 
\--in-place test-secret.yaml
```

<details>

<summary>Encrypted output of test-secret.yaml</summary>

```yaml
apiVersion: v1
data:
    password: ENC[AES256_GCM,data:6wPB1gnVImU=,iv:rUwG2uzF2Kc7jGvLJQyLPYrw3BwHN+HFw57GbTz8Bsg=,tag:IaKJqImzr8VCO8/CZFXPQw==,type:str]
    user: ENC[AES256_GCM,data:XhlBhK+l7Js=,iv:CKB5oUFexGTFnO9MkBt+UgYZk9/25cHyrMtQmxeKDE0=,tag:oqAFZ4Ict0Hkjs3Los4k4w==,type:str]
kind: Secret
metadata:
    name: test-secret
sops:
    age:
        - recipient: age1zd5n9zx0dsdwdggjuvz32ppngn45gk0sdadasdasdsadasdsadaddadada
          enc: |
            -----BEGIN AGE ENCRYPTED FILE-----
            YWdlLWVuY3J5cHRpb24ub3JnL3YxCi0+IFgyNTUxOSBUNndRdW40dHFZWUhHcVZN
            VjJta0F1MkYydHlVbVozRkRkZk1lTjJiWWdBCndrK2lHQ3F3Wm5mTnF0dG4yMUlI
            bWJvbnJYdGI4ZHRTUGFwdHFPSjFEeDgKLS0tIHNkUlcvQXRPOHJhRERCMlhQUTJP
            ZkovekVtaFM1SVR6NG0wU2k2c2JLbUkKGeAB+pFV8cNC7p7mvpboZ9EITbJAX6lJ
            c2U4fOEoYqzfW0Nsaym4iJ3U3MWyEW5vawkAvSAom/B2SaGQChVuzw==
            -----END AGE ENCRYPTED FILE-----
    lastmodified: "2026-01-19T20:47:25Z"
    mac: ENC[AES256_GCM,data:j4s84sBgCdIDxK0EIwC/Kp5GPRG5Cg8JCmamH79w+oVYvecI5tPUh/Ma8VuuqOsZyWekSQkbgqkpkg9y8CSbKKa2IUBrK/4oVV65vBPumrAQ0Mu8H1XOJe0qpQN123rntlYzuiJvl9GlTlH1C42p7MgkYNGNq/Lgi4gt87Rar3I=,iv:88gHPMv66kXDnIyzPtoH4EhNwFtBYwIhsD0B4ND+cgQ=,tag:JNr2LNM1Zvd5OmxA3KrxSA==,type:str]
    encrypted_regex: ^(data|stringData)$
    version: 3.11.0
```

</details>


Add the private key to the cluster
```bash
cat age.agekey | kubectl create secret generic sops-age --namespace=flux-system --from-file=age.agekey=/dev/stdin
```

Added sops as a decryption provider to apps.yaml kustomization file with the sops-age created above as a secretRef
```yaml
apiVersion: kustomize.toolkit.fluxcd.io/v1
kind: Kustomization
metadata:
  name:  apps
  namespace: flux-system
spec:
  interval: 1m
  retryInterval: 1m
  timeout: 5m
  sourceRef:
    kind: GitRepository
    name: flux-system
  path: ./apps/staging
  prune: true

  decryption:
    provider: sops
    secretRef:
      name: sops-age
```

Created .sop.yaml at root of homelab directory. simplifies encrypting and decrypting files
```yaml
creation_rules:
  - path_regex: \.yaml$
    encrypted_regex: ^(data|stringData)$
    age: age1zd5n9zx0dsdwdggjuvz32ppngn45gk0sdadasdasdsadasdsadaddadadal
```

**Note** - Had to export the whole file instead of just the public key for encrypt/decrypt to work
```bash
export SOPS_AGE_KEY_FILE=$HOME/.sops/age.agekey
```

---

## Application Examples

Examples of applications on the repo with encrypted secrets.

### Cloudflare Tunnels

Encrypting cloudflare credentials for tunnel with SOPs + age
```bash
kubectl create secret generic tunnel-credentials 
\--from-file=credentials.json=59c97568-9eda-4dbf-9857-b6cf9cf91259.json 
\--dry-run=client -o yaml > cloudflare-secret.yaml 
\sops --encrypt --in-place cloudflare-secret.yaml
```
---

### Linkding Environmental Variables

I previously used the command below inside linkding's shell to config a user account. But this isn't very GitOps friendly.
```bash
python manage.py createsuperuser --username=test --email=linkding-test@example.com
```

Linkding has a list of available [environmental variables](https://linkding.link/options/#list-of-options) to declare:
- LD_SUPERUSER_NAME - Admin Account
- LD_SUPERUSER_PASSWORD - Admin Account Password  
These variables need to be declared in deployment.yaml but can't be hard coded for obvious reason.
**Workflow**: Create secret > Encrypt Secret with SOPS + age > Commit to Git > Secret Decrypted by FLUX via SOPS using "sop-age" secret in apps.yaml

```bash
kubectl create secret generic linkding-container-env 
\--from-literal=LD_SUPERUSER_NAME=superadmin 
\--from-literal=LD_SUPERUSER_PASSWORD=password123? 
\--dry-run=client 
\-o yaml > linkding-container-env-secret.yaml
```

```bash
sops --age=$AGE_PUBLIC \--encrypt --encrypted-regex '^(data|stringData)$' --in-place linkding-container-env-secret.yaml
```

To make these environmental variable available inside linkding, we'll need to make use of `envFrom`.  
`envFrom` allows you to set environment variables for a container by referencing either a ConfigMap or a Secret. When you use `envFrom`, all the key-value pairs in the referenced ConfigMap or Secret are set as environment variables for the container.
```yaml
      containers:
      - image: ghcr.io/sissbruecker/linkding:1.44.2-plus-alpine
        name: linkding
        envFrom:
         # - configMapRef:
         #     name: linkding-configmap
          - secretRef:
              name: linkding-container-env
```

Added linkding-container-env-secret.yaml to apps/staging and referenced it in linkding kustomization
```yaml
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
namespace: linkding
resources:  
	- ../../base/linkding/  
	- cloudflare.yaml  
	- cloudflare-secret.yaml  
	- linkding-container-env-secret.yaml
```

**Note** - Linkding needs to be restarted for ENV variables to be injected, this can be done by commenting out directory and resource references in the base and staging kustomization files.
**Note** - It is preferable to use ENV variables for configuration if possible.

---

### Grafana Dashboard with self signed TLS cert

Generating TLS cert with openssl https://www.digitalocean.com/community/tutorials/openssl-essentials-working-with-ssl-certificates-private-keys-and-csrs **NOTE**
```bash
openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
  -keyout ./tls.key \
  -out ./tls.crt \
  -subj "/C=UK/ST=London/L=Basement/O=Homelab/OU=Monitoring/CN=grfs.ksefuke-labs.com" \
  -addext "subjectAltName=DNS:grfs.ksefuke-labs.com"
```

Creating TLS secret
```
kubectl create secret tls grafana-tls-secret \
  --cert=tls.crt \
  --key=tls.key \
  --namespace=monitoring \
  --dry-run=client \
  -o yaml > grafana-tls-secret.yaml
```

<details>

<summary>Application of Secret in Grafana's helm release manifest</summary>

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
  driftDetection:
    mode: enabled
    ignore:
      # Ignore "validated" annotation which is not inserted during install
      - paths: ["/metadata/annotations/prometheus-operator-validated"]
        target:
          kind: PrometheusRule
  values:
    grafana:
      ingress:
        enabled: true
        ingressClassName: traefik
      #annotations: {} - Potentially needed by cert manager
      # kubernetes.io/ingress.class: nginx
      # kubernetes.io/tls-acme: "true"

      ## Hostnames.Must be provided if Ingress is enable.
        hosts:
          - grfs.ksefuke-labs.com

      ## TLS configuration for grafana Ingress
      ## Secret must be manually created in the namespace
        tls:
          - secretName: grafana-tls-secret
            hosts:
              - grfs.ksefuke-labs.com
```

</details>



---
## Beats to Listen to

{{< alert cardColor="#DB4740" textColor="#1B1B1B" >}}
**ALERT!** - Lower your volume, the embedded bandcamp player doesn't have volume controls and it's quite loud by default
{{< /alert >}}