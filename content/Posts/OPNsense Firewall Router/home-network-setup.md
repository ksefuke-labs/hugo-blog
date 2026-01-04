+++
date = '2025-07-25T20:24:57Z'
title = 'Home Network Setup'
+++
# Custom Home Network Infrastructure

*A self-managed home network built for reliability, security, and seamless integration with a Proxmox-based homelab.*

---

## 📌 Overview

This post outlines the design and maintenance of my custom home network infrastructure.  
The network is built to support a virtualized homelab environment, multiple client devices, and self-hosted services while maintaining strong security and performance.

---

## 🧠 Design Goals

- Reliable internet connectivity
- Strong network segmentation and security
- Support for virtualization and self-hosted services
- Scalable switching and wireless coverage

---

## 🧱 Network Topology

### ISP & Edge

- **ISP Modem:** BT ONT
- **Router / Firewall:** OPNsense

OPNsense serves as the core routing, firewalling, and gateway platform.

---

### Switching & Wired Infrastructure

- **Switch:** MikroTik managed switch
- **Powerline Adapters:** Used where structured cabling is unavailable
- **Client Devices:** Desktops, servers, peripherals, and IoT devices

---

### Wireless

- **Access Point:** TP-Link AP
- Centralized wireless coverage for mobile and IoT devices

---

## 🖥️ Homelab Integration

The network is tightly integrated with a **Proxmox Virtual Environment** running as an all-in-one homelab server.

### Hosted Services

- NAS (OpenMediaVault)
- Docker server
- CrowdSec Local API server
- Wazuh SIEM / XDR
- Game servers
- Kasm Workspaces (DaaS)

---

## 🔐 Security Architecture

- Stateful firewalling via OPNsense
- Intrusion detection and prevention:
  - CrowdSec
  - Wazuh SIEM / XDR
- Network segmentation *(VLANs if applicable)*
- Controlled ingress through reverse proxy services

---

## 📊 Monitoring & Management

- Centralized logging *(optional)*
- Traffic visibility and firewall logging
- Device-level monitoring

---

## 🚀 Future Enhancements

- VLAN-based network segmentation
- 2.5 GbE or 10 GbE core upgrades
- Improved wireless coverage
- Redundant internet connection

---

## 📝 Closing Thoughts

This network provides a solid foundation for both everyday usage and advanced homelab experimentation.  
Combining enterprise-grade open-source tools with consumer hardware offers excellent flexibility at minimal cost.

---

*Last updated: YYYY-MM-DD*
