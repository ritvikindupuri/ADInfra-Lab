# Lab 1: Microsoft Windows Infrastructure Setup

## Executive Summary
This project establishes a fully networked client-server environment designed to simulate a hierarchical enterprise network. The objective was to deploy a multi-server **Active Directory (AD)** forest architecture using **Windows Server 2022**. The infrastructure includes a forest root domain and two child domains, requiring the configuration of distinct hardware roles, secure boot environments, and integrated DNS services.

## Architectural Diagram
The topology below visualizes the transition from system deployment to logical domain administration. It highlights the segregation of duties between the Forest Root and Child Domains, operating on an isolated VLAN.

<p align="center">
  <img src=".assets/Screenshot 2026-01-22 120213.png" alt="Lab Network Topology Diagram" width="850"/>
  <br>
  <b>Figure 1: Lab Network Topology & Trust Relationships</b>
</p>

**Architecture Analysis:**
The diagram details the specific "Trust Flow" implemented in this lab:
* **System Deployment (Left):** Shows the use of **Ventoy** and NVMe-targeted ISOs for the initial OS provisioning, ensuring a clean slate on the hardware.
* **Physical Layer (Center):** Segments the hardware roles between the **Dell Pro Tower Plus** (hosting the Forest Root and Child B) and the **OptiPlex 5060** (hosting Child A), all connected via a Layer 2 Lab Switch with IPv6 explicitly disabled to prevent routing leaks.
* **Logical Layer (Right):** Visualizes the hierarchy where `groupXX.c24200` acts as the Forest Root. The arrows indicate the parent-child trust relationships and the replication of DNS zones required for the child domains (`c242-XX-a` and `c242-XX-b`) to authenticate against the forest.

## Technical Configuration & Implementation

### 1. Hardware Provisioning & OS Installation
* **Boot Configuration:** Systems were configured to use **UEFI Boot** with Secure Boot disabled to allow the Ventoy USB to load the Windows Server 2022 ISO.
* **Disk Partitioning:** Critical care was taken to install the OS specifically on the **NVMe (~250GB)** drive, strictly avoiding the 1TB SATA drives to ensure performance and separation of concerns.
* **Driver Injection:** Post-installation, Intel PCIe Ethernet drivers were manually injected via Device Manager ("Have Disk" method) to enable network connectivity.

### 2. Active Directory Forest Setup
Once networking was established, the servers were promoted to Domain Controllers. The dashboard below confirms the successful deployment of these roles.

<p align="center">
  <img src=".assets/Active Directory Setup.jpeg" alt="Server Manager Dashboard" width="850"/>
  <br>
  <b>Figure 2: Server Manager Dashboard (Post-Promotion)</b>
</p>

**Dashboard Forensics:**
* **Service Health:** The green indicators on **AD DS** (Active Directory Domain Services) and **DNS** confirm that the core identity services are running and healthy.
* **Pending Actions:** The red status on the **All Servers** tile typically indicates a post-promotion warning, such as a pending restart or a service (like "Download Maps Manager") that is set to delayed start. In a production environment, this would trigger a maintenance window for remediation.
* **Role Integration:** The grouping of File Services, DNS, and AD DS demonstrates the server's multi-role capability as a Domain Controller.

### 3. Networking & DNS Strategy
* **IP Addressing:** Static IPs were assigned per the group allocation sheet.
* **DNS Forwarding:**
    * **Preferred DNS:** Set to `127.0.0.1` (loopback) to ensure the DC queries its own local records first.
    * **Alternate DNS:** Pointed to the upstream CIT DNS server (`cit.lcl`) to facilitate external name resolution for updates.
    * **Time Sync:** NTP settings were synchronized with the `cit.lcl` time servers using PowerShell to prevent Kerberos ticket failures due to time drift.

## Validation Checklist
* [x] **OS Installation:** Windows Server 2022 installed on NVMe drives.
* [x] **Naming Convention:** Servers named `GXXSRVYY` (e.g., G01SRV01).
* [x] **Network:** Static IPs assigned; IPv6 disabled.
* [x] **Active Directory:**
    * Forest Root: `groupXX.c24200.cit.lcl`.
    * Child A: `c242-XX-a`.
    * Child B: `c242-XX-b`.
* [x] **Updates:** All critical updates applied within 12 hours of check-off.

## Troubleshooting Notes
* **Driver Issues:** If the Ethernet controller does not appear, the specific Intel drivers (Version 12.19.2.45) were manually located on the USB drive.
* **Promotion Failures:** If a child domain fails to join the forest, verify that its **Preferred DNS** is temporarily set to the IP address of the **Forest Root Server** (Server 01) to allow it to locate the schema master.

## Conclusion
This lab successfully demonstrated the deployment of a robust Identity & Access Management (IAM) foundation. By establishing a functional forest with child domains, the infrastructure is now prepared for advanced administration tasks, including Group Policy Object (GPO) management, user provisioning, and centralized security auditing.
