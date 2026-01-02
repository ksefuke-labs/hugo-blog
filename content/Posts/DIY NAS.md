+++
date = '2025-07-25T20:24:57Z'
title = 'DIY NAS'
+++
# DIY NAS with OpenMediaVault

*A virtualized NAS design using OpenMediaVault, ZFS, and mergerfs, built for flexibility, performance, and scalability.*

---

## 📌 Overview

This post documents my DIY NAS implementation running as a virtual machine within my Proxmox homelab.  
The design prioritizes disk flexibility, fault tolerance, and clean separation between storage management and application workloads.

---

## 🧠 Design Goals

- Centralized storage for containers and client devices
- Flexible disk expansion with mixed drive types
- Filesystem-level redundancy and integrity
- Clean passthrough of storage hardware to the NAS VM

---

## 🖥️ Platform & Virtualization

- **Hypervisor:** Proxmox VE
- **NAS OS:** OpenMediaVault
- **VM Configuration:**  
  - PCIe passthrough for storage controller  
  - Host drivers blacklisted to ensure exclusive VM access  

This approach allows the NAS VM to fully control disk operations while maintaining Proxmox as the primary host.

---

## 💾 Storage Architecture

### HBA & Passthrough

- **Controller:** LSI HBA card
- **Passthrough:** PCIe passthrough enabled in Proxmox
- **Driver Handling:** Relevant host drivers blacklisted

This ensures direct disk access and optimal ZFS behavior.

---

### Filesystems

The NAS uses a **hybrid filesystem approach**:

- **ZFS**  
  - Used for data requiring integrity, checksumming, and resilience
- **XFS**  
  - Used for large, sequential data and high-performance workloads

---

### Pooling & Abstraction

- **mergerfs** is used to combine multiple disks into a **single unified directory**
- Enables:
  - Mixed disk sizes and types
  - Easier expansion
  - Simplified mount points for consumers

---

## 🔁 Data Access & Sharing

- **Primary Protocol:** NFS
- **Consumers:**  
  - Docker containers  
  - Client devices across the network  

This setup provides low-latency access while maintaining compatibility across Linux-based systems.

---

## 🔐 Reliability & Maintenance

- SMART monitoring via OpenMediaVault
- ZFS scrubbing schedules
- Manual or automated snapshot strategies *(optional)*
- Backup strategy *(describe here if applicable)*

---

## 🚀 Future Improvements

- Additional ZFS redundancy
- Off-site or cloud backups
- 10 GbE network upgrade
- Snapshot replication

---

## 📝 Closing Thoughts

Running a NAS as a virtual machine has proven both stable and flexible.  
With proper passthrough and filesystem choices, performance and reliability remain on par with bare-metal solutions.

---

*Last updated: YYYY-MM-DD*
