+++
date = '2026-01-01T20:27:30Z'
title = 'State of the Homelab 2026'
Description = 'An overview of my compact yet powerful Proxmox-based homelab, the hardware behind it, and the services it currently hosts'
+++



I'm quite proud of the Homelab Stack I've created, it's certainly grown over the years.
It started off as a means of storing and streaming of my purchased music and progressed into something else entirely. 

{{< carousel images="{opnsense-dash.png,pve-dash.png,omv-dash.png,jellyfin-music.png}" interval="3500" >}}

This post details my home lab adventures so far and whats to come in the future
## The Start of something new
I've never been a fan of music streaming services like spotify as i prefer to own my music and have built up a quite a large collection over the years. I also didn't like the idea of storing personal files using cloud storage providers like google drive, Microsoft Onedrive and Apple Icloud. 
A Synology Nas was an option but i really wanted to build something myself.

A spectacular video from German Youtuber "[Wolfgang's Channel](https://www.youtube.com/@WolfgangsChannel)" detailing the build process for a custom NAS sparked my [interest](https://www.youtube.com/watch?v=qACTvCW_yDc), i but was turned off due to my lack understanding of Linux at the time (2021).
It wasn't until i deleted my windows install and fully migrated to Arch Linux back in 2022 that i decided to revisit the idea again with new found vigour.
## Objectives
Me being the over thinker that i am wanted to identify all of my current requirements and take future requirements into consideration:
- All in one - Wanted to be able to host services in addition it being a NAS.
- Quiet and power efficient - Server would live in my room, on my desk so it couldn't be loud.
- Small - Ideally ITX form factor so it's not cumbersome to tinker with or store.
- No vendor lock in or subscriptions - The Primary reason for doing this
- Flexible and Cheap to expand/scale
## Choice of hardware (At the start 😅)
At the start i made of use of several components i had lying around from my first PC build and purchased everything else, see **link** for my adventures into the PC master iceberg:



{{< tabs >}}

    {{< tab label="DECEMBER 2022" >}}

| **Case**         | [Jonsbo n1](https://www.jonsbo.com/en/products/N1.html)                                                                                                                                    |
| ---------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| **CPU**          | [Intel Core i5-6400 ](https://www.intel.com/content/www/us/en/products/sku/88185/intel-core-i56400-processor-6m-cache-up-to-3-30-ghz/specifications.html)                                  |
| **Cooler**       | Cryorig C7                                                                                                                                                                                 |
| **Motherboard**  | [MSI B150I Gaming PRO AC](https://www.msi.com/Motherboard/B150I-GAMING-PRO-AC/Specification)                                                                                               |
| **Memory**       | 2 x 8 GB DDR4-2400 CL16                                                                                                                                                                    |
| **Power Supply** | [EVGA SuperNOVA 650 G1+](https://www.evga.com/Products/Specs/PSU.aspx?pn=9D224A7D-D321-4350-A2FA-C8366DF799A4)                                                                             |
| **Boot Drive**   | [2 TB Seagate Firacuda NVMe 520](https://www.seagate.com/gb/en/support/internal-hard-drives/ssd/firecuda-520-ssd/?sku=ZP1000GV3A012#Specs)                                                 |
| **NAS Storage**  | 2 x [12 TB Western Digital Red Plus HDD ](https://www.westerndigital.com/en-gb/products/internal-drives/data-center-drives/ultrastar-dc-hc520-hdd?sku=0F30146)+ 1 TB Seagate Barracuda HDD |
| **Network**      | 1GbE Realtek® RTL8111H NIC                                                                                                                                                                 |
| **Add-on Cards** | LSI HBA PCIe 2.0 SAS Card (IT mode)                                                                                                                                                        |
    
    
    {{< /tab >}}

    {{< tab label="SEPTEMBER 2023 - NOVEMBER 2023" >}}

| **CPU**                     | [Intel Core i5-12500T](https://www.intel.com/content/www/us/en/products/sku/96140/intel-core-i512500t-processor-18m-cache-up-to-4-40-ghz/specifications.html)                                                                                                                         |
| --------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **Motherboard**             | [ASRock Z690 ITX](https://www.asrock.com/mb/Intel/Z690M-ITXax/)                                                                                                                                                                                                                       |
| **Memory**                  | 2 x 32GB DDR4 3200MHz CL22                                                                                                                                                                                                                                                            |
| **Case**                    | [Jonsbo n1](https://www.jonsbo.com/en/products/N1.html)                                                                                                                                                                                                                               |
| **Boot Drive + VM Storage** | 2 x [1.92TB Intel S4500 SSDs](https://lenovopress.lenovo.com/lp0755-intel-s4500-entry-sata-6gb-ssds)                                                                                                                                                                                  |
| **NAS Storage**             | 2 x [12TB Western Digital Red Plus HDD ](https://www.westerndigital.com/en-gb/products/internal-drives/data-center-drives/ultrastar-dc-hc520-hdd?sku=0F30146)<br>1 x [3.84TB Kingston DC500R SSD](https://www.kingston.com/datasheets/DC500R_us.pdf)<br>1 x 1TB Seagate Barracuda HDD |
| **Network**                 | 2.5 GbE Realtek NIC + 1GbE Intel I219V NIC                                                                                                                                                                                                                                            |
    {{< /tab >}}``

    {{< tab label="JUNE 2024 - AUGUST 2025" >}}

| **CPU**         | [Intel Core i5-14500](https://www.intel.com/content/www/us/en/products/sku/236784/intel-core-i5-processor-14500-24m-cache-up-to-5-00-ghz/specifications.html)                                                                                                                                                                                                                                                                                                                                                                 |
| --------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **Motherboard** | [ASRock Z690 ITX](https://www.asrock.com/mb/Intel/Z690M-ITXax/)                                                                                                                                                                                                                                                                                                                                                                                                                                                               |
| **Memory**      | 2 x 32GB DDR4 3200MHz CL22                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                    |
| **Case**        | [Silverstone RM21-308](https://www.silverstonetek.com/en/product/info/server-nas/RM21-308/)                                                                                                                                                                                                                                                                                                                                                                                                                                   |
| **Boot Drive**  | 1 x [480GB Intel S3510 SSD](https://lenovopress.lenovo.com/lp0056-s3510-enterprise-entry-sata-ssds)                                                                                                                                                                                                                                                                                                                                                                                                                           |
| **VM Storage**  | [2 TB Seagate Firacuda NVMe 520](https://www.seagate.com/gb/en/support/internal-hard-drives/ssd/firecuda-520-ssd/?sku=ZP1000GV3A012#Specs) + Intel S4500 960GB SSD                                                                                                                                                                                                                                                                                                                                                            |
| **NAS Storage** | 1 x [4TB Transcend SSD470K SSD](https://www.transcend-info.com/embedded/product/embedded-ssd-solutions/ssd470k-ssd470k-i)<br>1 x [3.84TB Kingston DC500R SSD](https://www.kingston.com/datasheets/DC500R_us.pdf)<br>2 x [12TB Western Digital Red Plus HDDs](https://www.westerndigital.com/en-gb/products/internal-drives/wd-red-plus-sata-3-5-hdd?sku=WD120EFGX)<br>2 x [12TB Ultrastar DC HC520 HDDs](https://www.westerndigital.com/en-gb/products/internal-drives/data-center-drives/ultrastar-dc-hc520-hdd?sku=0F30146) |
| **Network**     | 2.5 GbE NIC                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                   |

And 2 Mini PCs from Ebay with the same specs (The deals were too good to pass)

| **PC**              | [MINISFORUM UN100P](https://www.minisforum.com/products/minisforum-un100p-1)                                    |
| ------------------- | --------------------------------------------------------------------------------------------------------------- |
| **Memory**          | 1 x 16GB DDR4 3200MHz SODIMM                                                                                    |
| **Boot + VM Drive** | 1 x [Intel S4500 1.92TB SSD](https://lenovopress.lenovo.com/lp0755-intel-s4500-entry-sata-6gb-ssds)             |
| **VM Storage**      | 1 X [1TB IronWolf 525](https://www.seagate.com/gb/en/support/internal-hard-drives/nas-drives/ironwolf-525-ssd/) |
| **Network**         | 2.5 GbE NIC                                                                     |

    {{< /tab >}}

{{< /tabs >}}








## Choice of Operating Systems
To satisfy the "all in one" requirement for my homelab i could have just installed ubuntu server edition and left it at that. But me being the chronic tinkerer that i am wanted to be able to break things without having reinstall the core os (Had already broken several arch based installs already at this point).
I stumbled across [Perfect Media Server ]( https://perfectmediaserver.com/)by Alex Kretzschmar which suggested using proxmox as the core OS.

[Proxmox VE](https://www.proxmox.com/en/products/proxmox-virtual-environment/overview) is a type 1 hypervisor based on debian that's free to deploy, has very few limits imposed on users without a Enterprise Subscription and has a fantastic web interface and shell. It can used to provision traditional virtual machines and linux containers (LXC).
![[image-70.png|1422x800]]

I do have experience supporting Vmware infrastructure in my MSP Cloud Analyst role but didn't consider it an option due to the shear difference in free feature set (in 2023):

**Proxmox VE:**
- Full clustering capabilities
- High availability
- Live migration
- Backup and restore tools with advanced features (deduplication, compression, incremental backups)
- Both KVM (full virtualization) and LXC (containers)
- Web-based management interface
- ZFS, LVM, iSCSI, NFS storage support
- No core or memory limitations

**VMware ESXi:**
- Could only run on a limited number of cores and had extremely limited memory
- No vCenter Server access - Centralised Panel/dashboard for managing multiple ESXI servers.
- No Distributed Resource Scheduler 
- No fault tolerance
- Free Edition completely dropped into 2024 accompanied by significant licensing changes which burned a lot of companies wallets. 

---
## 💽 Choice of NAS
[Openmediavault ](https://www.openmediavault.org/)was my goto NAS option at the time. Its based on Debian under the hood and provided all require services ([Hdparm](https://wiki.archlinux.org/title/Hdparm), NFS, Rsync, SSH, S.M.A.R.T, SMB )  out of the box or via [plugins](https://wiki.omv-extras.org/doku.php?id=start) (ZFS Support).
	**Note** - I will admit the initial configuration of services and disks can be quite tedious due to the config confirmation nature of OMV, every change needs to be confirmed/applied and it's in your best interest to not commit multiple changes at once. As a config error may force you revert them. (Speaking from experience)


There were other DIY solutions at the time, but these didn't meet my requirements for a number of reasons:
- Ubuntu Server (CLI) - I wasn't comfortable manually configuring all backed services at the time and wanted something that just worked so i start tinkering with services. There are gui apps such Red Hat's [Cockpit ](https://cockpit-project.org/) and [webmin](https://webmin.com/) which can installed on ubuntu server, but i found those to be a bit finicky. Obviously now i am aware the CLI is the superior way due to things with scripting and automation.
- [Unraid ](https://account.unraid.net/buy)- requires a license to use after 30 days. It was also way too web gui oriented for my liking. **Note** - There is a fork of unraid open-source `md_unraid` kernel driver called [non-raid](https://github.com/qvr/nonraid)
- [TrueNAS'](https://www.truenas.com/truenas-community-edition/) ZFS is a fantastic filesystem, but it requires all the drives to be spun up all the time (see this [post](https://forums.truenas.com/t/hdd-sleep-spindown-standby/13325/120)🙃) which increases power usage by 20w-30w. In addition to require purchasing drives in sets to expand available storage depending on the raid setup.
### Filesystems - The bread and butter
Below are the filesystems in use:

XFS - Deployed on a 
ZFS - File system for mission critical data i.e family photo



- **mergerfs** is used to combine multiple disks into a **single unified directory**
- Pools multiple drives into one mountable volume
- Supports addition _and_ removal of devices with no rebuild times
- Permits drives with mismatched sizes with no penalties
- Each drive has an individually readable filesystem (ext4, xfs, zfs, etc)
- Drives may contain data when mounted via Mergerfs
- Simple configuration with one line in `/etc/fstab` (example below)
```txt
/mnt/disk* /mnt/storage fuse.mergerfs defaults,nonempty,allow_other,use_ino,cache.files=off,moveonenospc=true,category.create=mfs,dropcacheonclose=true,minfreespace=250G,fsname=mergerfs 0 0
```

![[image-71.png|1009x800]]

- Provide fault tolerance to protect against (inevitable) hard drive failure
- Checksum files to guard against bitrot
- Support hard drives of differing / mismatched sizes
- Enable incremental upgrading of hard drives in batches as small as one
- Each drive should have a separately readable filesystem with no striping of data
![[image-74.png|769x800]]

### PCIE PASSTHROUGH
Did i forget mention the NAS was virtualized? While researching Proxmox i discovered you can pass-through [PCIE devices](https://pve.proxmox.com/wiki/PCI(e)_Passthrough) into VMs so they appear as native devices.
The idea of leaving the NAS disk exposed on proxmox and provisioning block storage from them to be virtualized on OMV felt gross and i wanted near native performance from OMV

Below is the general process for systems using systemd-boot:
```bash
# 1. Confirm VT-d (Intel) or AMD-Vi (AMD) is available/enabled in the bios for IOMMU support.

# 2. Configure kernel command line for IOMMU
echo "intel_iommu=on iommu=pt" > /etc/kernel/cmdline

# 3. Configure required VFIO modules
cat > /etc/modules << 'EOF'
vfio
vfio_iommu_type1
vfio_pci
vfio_virqfd
EOF

# Verify VFIP Modules are loaded
lsmod | grep vfio
# Confirm IOMMU is enabled via 
dmesg | grep -e DMAR -e IOMMU
# Identify PCI IDS/drivers using LSPCI
lspci -nnk
# 3. Configure VFIO PCI IDs and blacklist conflicting drivers
cat > /etc/modprobe.d/pve-blacklist.conf << 'EOF'
options vfio-pci ids=1000:0072,8086:4690
blacklist mpt3sas
blacklist i915
EOF

# 4. Apply changes
proxmox-boot-tool refresh && update-initramfs -u -k all
```
Once this is done the driver in use should change to "**vfio-pci**"
LSI HBA SAS Controller:
```bash
01:00.0 RAID bus controller [0104]: Broadcom / LSI SAS2008 PCI-Express Fusion-MPT SAS-2 [Falcon] [1000:0072] (rev 03)
        Subsystem: Fujitsu Technology Solutions HBA Ctrl SAS 6G 0/1 [D2607] [1734:1177]
        Kernel driver in use: vfio-pci
        Kernel modules: mpt3sas
```

```bash
00:02.0 VGA compatible controller [0300]: Intel Corporation AlderLake-S GT1 [8086:4680] (rev 0c)
        Subsystem: ASRock Incorporation Device [1849:4680]
        Kernel driver in use: vfio-pci
        Kernel modules: i915, xe
```

----

## 🐕‍🦺 Services
- Crowdsec - Multi server Config
- Home Assistant 
- Hugo Webserver (Used before switching to local development)
- Immich
- Jellyfin (Music Streaming)
- Kasm Workspaces
- LinuxGSM
- Navidrome
- Nginx Proxy Manager Plus (Has crowdsec nginx bouncer support)
- Obsidian Livesync (via Couchdb)
- Pelican Panel
- Portainer
- Pterodactyl
- Tailscale
- Technitium DNS
- Vikunja
- Wazuh Siem - in testing
---

  
## 🚀 Future Improvements
### Dedicated Hardware for Baremetal NAS
Running a NAS as a virtual machine has proven to be quite stable and flexible.  But i would love to move it to dedicated hardware at some point, there is something about the setup that makes me feel like it's a snake eating it's own tail. Especially isn't helpful if i have to switch of the proxmox node for maintenance. Considering getting another 2u chassis and moving proxmox to that instead?

### Kubernetes on spare mini pc's?
I honestly haven't touched the 2 minisforum n100d mini pcs i bought them back in June besides installing proxmox on them, i bought them with initial idea of clustering them and messing with zfs/ceph replication. But i decided against it as i didn't have enough services to warrant spreading them out. Now with my migration to Kubernetes from docker underway. I plan to install K3S or Talos Linux on them directly and cluster them 

### Rack mountable 2.5gb switch 
I would like to purchase a 2.5gb managed switch, i tried Mikrotik 2.5gbe switch however it was way too loud and would ports would randomly drop out.
The 1GBE bandwidth limitation imposed my mikrotik isn't causing 30 pound is potential temporary solution, but i would like something with at 12 ports that is rack mountable

### Experimental SRIOV support of Intel IGPU

### NIXOS NAS

---
## 📚Sources
https://liliputing.com/minisforum-un100p-mini-pc-comes-with-intel-n100-and-n150-processor-options/
https://pve.proxmox.com/wiki/PCI(e)_Passthrough
https://www.servethehome.com/how-to-pass-through-pcie-nics-with-proxmox-ve-on-intel-and-amd/
[Perfect Media Server ]( https://perfectmediaserver.com/)by Alex Kretzschmar ([Ironicbadger](https://github.com/ironicbadger)) 
[The Perfect Home Server Build! 18TB, 10Gbit LAN, Quiet & Compact](https://www.youtube.com/watch?v=qACTvCW_yDc) by Wolfgang's Channel
[Building a Homelab Server Rack](https://www.youtube.com/watch?v=b-x5CsBDbzg) by Wolfgang's Channel
[Building a Power Efficient Home Server!](https://www.youtube.com/watch?v=MucGkPUMjNo)  by Wolfgang's Channel
[Busting 8 Common Homelab Power Efficiency Myths](https://www.youtube.com/watch?v=Ppo6C_JhDHM)  by Wolfgang's Channel