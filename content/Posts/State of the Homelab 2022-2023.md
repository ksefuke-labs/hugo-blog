+++
date = '2024-12-25T20:27:30Z'
title = 'State of the Homelab 2023/2024'
+++

# Proxmox All-in-One Homelab

*An overview of my compact yet powerful Proxmox-based homelab, the hardware behind it, and the services it currently hosts.*

---

## 📌 Overview

This post documents my current homelab setup built around a single Proxmox node.  
The goal of this lab is to provide a reliable, energy-efficient, and flexible platform for self-hosting services, experimenting with infrastructure, and learning modern virtualization and container workflows.

---

## 🖥️ Hardware Specifications

| Component | Details |
|---------|--------|
| **CPU** | Intel Core i5-14500 |
| **Motherboard** | ASRock Z690 ITX |
| **Memory** | 64 GB DDR4 |
| **Case** | Silverstone RM21-308 |
| **Boot Drive** | 480 GB Intel DC SSD |
| **Primary Storage** | 2 TB NVMe |
| **VM Storage** | 960 GB SSD |
| **Network** | 2.5 GbE Realtek NIC (currently limited to 1 GbE) |

---

## 🧱 Platform Choice: Proxmox VE

I chose **Proxmox VE** as the hypervisor for the following reasons:

- Native support for **KVM virtual machines and LXC containers**
- Excellent **web-based management interface**
- Strong **community support**
- Snapshotting, backups, and clustering capabilities
- Ideal balance between enterprise features and homelab usability

---

## 🗂️ Storage Layout

The system uses a multi-disk approach to separate concerns:

- **Boot Drive:** Dedicated Intel DC SSD for Proxmox OS
- **VM Disk Storage:**  
  - NVMe for performance-critical workloads  
  - SATA SSD for general-purpose VMs
- **Backups:** *(Describe your backup strategy here, if applicable)*

---

## 🌐 Networking

- Single onboard **2.5 GbE Realtek NIC**
- Currently operating at **1 GbE** due to network constraints
- Reverse proxy handled via **Nginx Proxy Manager**

*(Optional: VLANs, firewall rules, or future network upgrades)*

---

## 🧩 Virtual Machine Layout

All services are hosted in **separate virtual machines** to ensure isolation, easier maintenance, and improved security.

### 🐳 Docker VM

This VM serves as the main container host and runs the following services:

#### Media & Content
- **Beets** – Music library management and tagging
- **Jellyfin** – Self-hosted media streaming
- **Immich** – Photo and video backup and management

#### Infrastructure & Access
- **Nginx Proxy Manager (npmplus)** – Reverse proxy and TLS management
- **Kasm Workspaces** – Browser-based containerized desktops
- **CrowdSec LAPI** – Crowd-sourced intrusion prevention

---

## 🔐 Security Considerations

- Services isolated into individual VMs
- Reverse proxy handling all public ingress
- CrowdSec deployed for proactive threat detection
- *(Optional: firewall rules, fail2ban, backups, access control)*

---

## 📈 Performance & Resource Usage

*(Describe CPU, RAM, and disk usage under normal load)*

- Average CPU utilization:
- Memory usage:
- Storage growth trends:

---

## 🔄 Maintenance & Updates

- Regular Proxmox updates
- Snapshotting before major changes
- Automated container updates *(if applicable)*

---

## 🚀 Future Plans

Some potential upgrades and improvements:

- Upgrade to full **2.5 GbE networking**
- Add redundant storage or ZFS
- High availability or Proxmox clustering
- Monitoring with Prometheus / Grafana
- Automated backups to off-site storage

---

## 📝 Closing Thoughts

This homelab strikes a balance between simplicity and capability.  
Running everything on a single Proxmox node has proven reliable while still allowing room to grow and experiment.

If you’re considering a compact all-in-one homelab, this setup offers a solid starting point.

---

*Last updated: YYYY-MM-DD*
