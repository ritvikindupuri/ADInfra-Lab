# Lab 1: Microsoft Windows Infrastructure Setup

## Executive Summary
This project establishes a fully networked client-server environment designed to simulate a hierarchical enterprise network. The objective was to deploy a multi-server **Active Directory (AD)** forest architecture using **Windows Server 2022**. The infrastructure includes a forest root domain and two child domains, requiring the configuration of distinct hardware roles, secure boot environments, and integrated DNS services.

## Architectural Diagram
The following network topology illustrates the relationship between the Forest Root and the Child Domains, including the specific hardware roles (Dell Pro Tower Plus vs. OptiPlex 5060) and networking layers.



**Figure 1: Lab Network Topology & Trust Relationships**
* [cite_start]**System Deployment:** Utilized Ventoy bootable USBs to deploy Windows Server 2022 images to NVMe targets[cite: 38, 39, 40].
* **Forest Root (`groupXX.c24200.cit.lcl`):** Hosted on **Server 01** (Dell Pro Tower Plus). [cite_start]Acts as the primary Domain Controller and DNS authority for the forest[cite: 58].
* **Child Domains:**
    * [cite_start]**Child A (`c242-XX-a`):** Hosted on the **Workstation** (Dell OptiPlex 5060)[cite: 63, 64].
    * [cite_start]**Child B (`c242-XX-b`):** Hosted on **Server 02** (Dell Pro Tower Plus)[cite: 60, 61].
* **Networking:** All nodes operate on an isolated VLAN but maintain a trust relationship via the parent-child AD structure.

## Technical Configuration & Implementation

### 1. Hardware Provisioning & OS Installation
* [cite_start]**Boot Configuration:** Systems were configured to use **UEFI Boot** with Secure Boot disabled to allow Ventoy to load the installation ISOs[cite: 48, 50, 52].
* [cite_start]**Disk Partitioning:** Critical care was taken to install the OS specifically on the **NVMe (~250GB)** drive, deleting all partitions on physical drives while preserving the USB installer[cite: 52, 53].
* [cite_start]**Driver Injection:** Post-installation, the Intel PCIe Ethernet drivers were manually injected via Device Manager to enable network connectivity[cite: 66, 67, 73].

### 2. Active Directory Forest Setup
The Active Directory structure was built hierarchically to test parent-child domain trusts.



**Figure 2: Server Manager Dashboard (Post-Promotion)**
* **Status Analysis:** The dashboard confirms that the **AD DS (Active Directory Domain Services)** and **DNS (Domain Name System)** roles are active (Green status).
* **Local Server Config:** The server is configured with a static IP and has remote management enabled. The red notification on "All Servers" likely indicates a pending service restart or update, typical immediately after promoting a DC.
* **Role Integration:** DNS is integrated directly with AD, essential for the replication of SRV records between the Forest Root and Child Domains.

### 3. Networking & DNS Strategy
* **IP Addressing:** Static IPs were assigned per the group IP sheet. [cite_start]IPv6 was explicitly disabled to prevent routing conflicts[cite: 16, 17, 19].
* **DNS Forwarding:**
    * [cite_start]**Preferred DNS:** Set to the loopback address (`127.0.0.1`) so the DC queries itself first[cite: 85].
    * [cite_start]**Alternate DNS:** Pointed to the CIT upstream DNS server to allow external resolution[cite: 85].
    * [cite_start]**Replication:** Child domains point their DNS to the Forest Root to locate the schema master and establish the trust relationship[cite: 62, 65].

### 4. Remote Administration
* **Remote Desktop (RDP):** Enabled on all servers to facilitate headless management. [cite_start]Access is restricted to the 'Administrator' account for security[cite: 30].
* [cite_start]**NTP Synchronization:** Time settings were synchronized with `cit.lcl` time servers using PowerShell to ensure Kerberos authentication tickets do not fail due to time drift[cite: 33].

## Validation Checklist
* [cite_start][x] **OS Installation:** Windows Server 2022 installed on NVMe drives[cite: 53].
* [cite_start][x] **Naming Convention:** Servers named `GXXSRVYY` (e.g., G01SRV01)[cite: 20].
* [x] **Network:** Static IPs assigned; [cite_start]IPv6 disabled[cite: 16, 19].
* [x] **Active Directory:**
    * [cite_start]Forest Root: `groupXX.c24200.cit.lcl`[cite: 58].
    * [cite_start]Child A: `c242-XX-a`[cite: 64].
    * [cite_start]Child B: `c242-XX-b`[cite: 61].
* [cite_start][x] **Updates:** All critical updates applied within 12 hours of check-off[cite: 29].

## Troubleshooting Notes
* [cite_start]**Driver Issues:** If the Ethernet controller does not appear, use the "Have Disk" method in Device Manager and browse to the extracted Intel drivers on the USB[cite: 72, 73].
* [cite_start]**Promotion Failures:** If a child domain fails to join the forest, verify that its **Preferred DNS** is set to the IP address of the **Forest Root Server** (Server 01) temporarily during the promotion process[cite: 62].

## Conclusion
This lab successfully demonstrated the deployment of a robust Identity & Access Management (IAM) foundation. By establishing a functional forest with child domains, the infrastructure is now prepared for advanced administration tasks, including Group Policy Object (GPO) management, user provisioning, and centralized security auditing.
