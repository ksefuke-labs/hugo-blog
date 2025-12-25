+++
date = '2025-07-25T20:26:30Z'
title = 'Infrastructure Security Stack'
+++
Crowdsec IDS/IPS and Wazuh XDR/SIEM are deployed on all servers to monitor endpoints/services, halt intrusion attempts and scan servers for vulnerabilities.
Services are served behind a nginx proxy manager with let’s encrypt certificates. Access Control and GeoIP list are deployed alongside OPNsense port forward rules to restrict LAN and WAN access and reduce attack surface. Tailscale (VPN) is deployed on opnsense and all servers, so they can be accessed remotely without exposing them directly to the internet via port forwarding.
