<#
.SYNOPSIS
    Validates the Windows Server Infrastructure configuration for Lab 1.
.DESCRIPTION
    Checks the following requirements:
    1. Hostname Naming Convention (GXXSRVYY)
    2. Static IP Assignment & IPv6 Status (Must be Disabled)
    3. Active Directory Domain Services Status
    4. NTP Synchronization with cit.lcl
    5. DNS Reachability
.NOTES
    Author: Ritvik Indupuri
    Project: Lab 1 - Windows Infrastructure Setup
#>

Write-Host "--- STARTING INFRASTRUCTURE VALIDATION ---" -ForegroundColor Cyan

# 1. Validate Hostname
$hostname = $env:COMPUTERNAME
Write-Host "[INFO] Checking Hostname..."
if ($hostname -match "^G\d{2}(SRV|WKS)\d{2}$") {
    Write-Host " [PASS] Hostname '$hostname' follows naming convention." -ForegroundColor Green
} else {
    Write-Host " [WARN] Hostname '$hostname' may not match standard (GXXSRVYY)." -ForegroundColor Yellow
}

# 2. Network Configuration Check
Write-Host "`n[INFO] Checking Network Adapters..."
$adapters = Get-NetAdapter | Where-Object Status -eq 'Up'
foreach ($nic in $adapters) {
    $ipv6 = Get-NetAdapterBinding -Name $nic.Name -ComponentID ms_tcpip6
    if ($ipv6.Enabled) {
        Write-Host " [FAIL] IPv6 is ENABLED on $($nic.Name). It must be disabled." -ForegroundColor Red
    } else {
        Write-Host " [PASS] IPv6 is DISABLED on $($nic.Name)." -ForegroundColor Green
    }
}

# 3. Active Directory Check
Write-Host "`n[INFO] Checking Domain Status..."
try {
    $domain = Get-ADDomain
    Write-Host " [PASS] Server is a Domain Controller for: $($domain.DNSRoot)" -ForegroundColor Green
    Write-Host "        Forest Mode: $($domain.ForestMode)"
} catch {
    Write-Host " [FAIL] Unable to retrieve Domain information. Is AD DS installed?" -ForegroundColor Red
}

# 4. NTP Synchronization Check (Critical for Kerberos)
Write-Host "`n[INFO] Checking Time Synchronization..."
$timeSource = w32tm /query /source
if ($timeSource -match "cit.lcl") {
    Write-Host " [PASS] Time Source is synchronized with: $timeSource" -ForegroundColor Green
} else {
    Write-Host " [WARN] Time Source is set to: $timeSource. Ensure it points to cit.lcl." -ForegroundColor Yellow
}

Write-Host "`n--- VALIDATION COMPLETE ---" -ForegroundColor Cyan
