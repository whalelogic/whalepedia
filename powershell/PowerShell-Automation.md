
# PowerShell Automation Guide

### Windows Updates · Disk Partitioning · Encryption · Active Directory

> **Audience:** IT administrators and power users looking for reliable, reusable starting points for common Windows automation tasks.  
> **Requirements:** PowerShell 5.1+ (most sections); PowerShell 7+ noted where relevant. Run all scripts as **Administrator** unless stated otherwise.  
> **Last updated:** May 2026
> **Created by: Keith Thomson**, **ASCS,, Security+, AWS Solutions Architect**

----------

## Table of Contents

1.  [PowerShell Fundamentals](#1-powershell-fundamentals)
2.  [Windows Update Automation](#2-windows-update-automation)
3.  [Disk Partitioning — SSD & HDD](#3-disk-partitioning--ssd--hdd)
4.  [Encryption with BitLocker & EFS](#4-encryption-with-bitlocker--efs)
5.  [Active Directory Common Tasks](#5-active-directory-common-tasks)
6.  [Error Handling Patterns](#6-error-handling-patterns)
7.  [Logging & Reporting](#7-logging--reporting)
8.  [Quick Reference Tables](#8-quick-reference-tables)
9.  [References](#9-references)

----------

## 1. PowerShell Fundamentals

Before diving into specific tasks, it's worth establishing a few habits that will keep your scripts safe, readable, and reusable across environments.

### 1.1 Execution Policy

Windows blocks unsigned scripts by default. Set the policy appropriately for your environment before running any of the scripts in this guide.

```powershell
# Check the current policy
Get-ExecutionPolicy -List

# For a single session (safest for one-off work)
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass

# For the current user permanently (good for dev machines)
Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy RemoteSigned

# For all users on a managed machine (use via GPO in production)
Set-ExecutionPolicy -Scope LocalMachine -ExecutionPolicy RemoteSigned

```

> **Why RemoteSigned?** It allows locally written scripts to run freely while requiring a digital signature on anything downloaded from the internet — a reasonable balance for admin work.

### 1.2 Script Template (Copy-Paste Starter)

Every script you write should have a `#Requires` block, a `param()` block, and structured error handling. This template is referenced throughout the guide.

```powershell
#Requires -RunAsAdministrator
#Requires -Version 5.1

<#
.SYNOPSIS
    Short one-line description.
.DESCRIPTION
    Longer description of what the script does.
.PARAMETER ComputerName
    Target computer(s). Defaults to localhost.
.EXAMPLE
    .\MyScript.ps1 -ComputerName "PC01","PC02"
#>

[CmdletBinding(SupportsShouldProcess)]
param (
    [Parameter(Mandatory = $false)]
    [string[]]$ComputerName = $env:COMPUTERNAME,

    [Parameter(Mandatory = $false)]
    [string]$LogPath = "C:\Logs\$(Get-Date -Format 'yyyyMMdd')_script.log"
)

# ── Helper: simple timestamped log ──────────────────────────────────────────
function Write-Log {
    param([string]$Message, [string]$Level = "INFO")
    $entry = "[{0}] [{1}] {2}" -f (Get-Date -Format "yyyy-MM-dd HH:mm:ss"), $Level, $Message
    Add-Content -Path $LogPath -Value $entry
    Write-Verbose $entry
}

# ── Main ────────────────────────────────────────────────────────────────────
try {
    Write-Log "Script started by $env:USERNAME"
    # Your code here

} catch {
    Write-Log "FATAL: $_" -Level "ERROR"
    throw
} finally {
    Write-Log "Script finished"
}

```

### 1.3 Remote Execution Primer

Most commands in this guide run locally. To target remote machines, wrap them in `Invoke-Command`:

```powershell
# Single target
Invoke-Command -ComputerName "SERVER01" -ScriptBlock {
    Get-WindowsUpdate  # example cmdlet
}

# Multiple targets in parallel (uses PowerShell remoting / WinRM)
$computers = "PC01", "PC02", "PC03"
Invoke-Command -ComputerName $computers -ThrottleLimit 10 -ScriptBlock {
    # $using: allows passing local variables into the remote session
    $hostname = $using:env:COMPUTERNAME
    "Running on $env:COMPUTERNAME, called from $hostname"
}

```

----------

## 2. Windows Update Automation

### 2.1 Module Overview

The `PSWindowsUpdate` community module is the most practical tool for scripting updates. The built-in `WindowsUpdate` COM API is an alternative but far more verbose.

```
┌─────────────────────────────────────────────────────────────────┐
│                   Windows Update Flow                           │
│                                                                 │
│  [PSWindowsUpdate]  ──►  [Windows Update Agent (WUA)]          │
│         │                        │                             │
│    Get-WUList              Scans WSUS / WU / MU                │
│    Install-WUJob                  │                            │
│    Get-WUHistory           Downloads & Installs                │
│         │                        │                             │
│         └──────────► [Event Log / WU Log]                      │
└─────────────────────────────────────────────────────────────────┘

```

### 2.2 Installing PSWindowsUpdate

```powershell
# Install from PSGallery (requires internet access or internal feed)
Install-Module -Name PSWindowsUpdate -Force -AllowClobber

# Verify the module loaded correctly
Get-Module -ListAvailable PSWindowsUpdate | Select-Object Name, Version

# Import it (required each session unless in $PROFILE)
Import-Module PSWindowsUpdate

```

### 2.3 Checking for Available Updates

```powershell
# List all available updates — does NOT install anything
Get-WUList -MicrosoftUpdate -Verbose

# Filter to only critical and security updates
Get-WUList -MicrosoftUpdate | Where-Object {
    $_.Categories -match "Critical|Security"
} | Select-Object KB, Title, Size, MsrcSeverity

# Check a remote machine
Get-WUList -ComputerName "PC01" -MicrosoftUpdate

```

**Sample output columns:**

Column

Meaning

`KB`

Knowledge Base article number (e.g. KB5034441)

`Title`

Human-readable update name

`Size`

Download size in MB

`MsrcSeverity`

Critical / Important / Moderate / Low

`IsDownloaded`

Whether the package is already cached locally

### 2.4 Installing Updates

```powershell
# Install all available updates, auto-accept, reboot if needed
Install-WindowsUpdate -MicrosoftUpdate -AcceptAll -AutoReboot

# Install only specific KB articles
Install-WindowsUpdate -KBArticleID "KB5034441","KB5033372" -AcceptAll

# Install everything EXCEPT specific KBs (useful to defer problematic patches)
Install-WindowsUpdate -MicrosoftUpdate -AcceptAll -NotKBArticleID "KB5034441"

# Schedule installation for off-hours (creates a scheduled task)
$triggerTime = (Get-Date "02:00").AddDays(1)  # 2 AM tomorrow
Install-WUJob -ComputerName "PC01" -TaskName "NightlyUpdates" `
    -Trigger (New-ScheduledTaskTrigger -Once -At $triggerTime) `
    -RunNow:$false

```

### 2.5 Bulk Update Deployment Script

This script targets a list of machines, installs all pending updates, logs results, and generates a summary CSV — a solid starting point for patch night.

```powershell
#Requires -RunAsAdministrator
#Requires -Modules PSWindowsUpdate

param (
    [string[]]$ComputerName = @("localhost"),
    [string]$ReportPath = "C:\Logs\PatchReport_$(Get-Date -Format yyyyMMdd).csv"
)

$results = @()

foreach ($computer in $ComputerName) {
    Write-Host "Processing $computer ..." -ForegroundColor Cyan

    try {
        # Retrieve update list first so we can log what was pending
        $pending = Get-WUList -ComputerName $computer -MicrosoftUpdate -ErrorAction Stop

        if ($pending.Count -eq 0) {
            Write-Host "  $computer — No updates pending." -ForegroundColor Green
            $results += [PSCustomObject]@{
                Computer    = $computer
                UpdateCount = 0
                Status      = "UpToDate"
                RebootNeeded = $false
                Error       = ""
            }
            continue
        }

        # Perform installation
        $installResult = Install-WindowsUpdate -ComputerName $computer `
            -MicrosoftUpdate -AcceptAll -IgnoreReboot -ErrorAction Stop

        $rebootNeeded = ($installResult | Where-Object { $_.RebootRequired }) -ne $null

        $results += [PSCustomObject]@{
            Computer     = $computer
            UpdateCount  = $installResult.Count
            Status       = "Patched"
            RebootNeeded = $rebootNeeded
            Error        = ""
        }

        Write-Host "  $computer — $($installResult.Count) updates installed." -ForegroundColor Green

    } catch {
        Write-Host "  ERROR on $computer : $_" -ForegroundColor Red
        $results += [PSCustomObject]@{
            Computer     = $computer
            UpdateCount  = 0
            Status       = "Failed"
            RebootNeeded = $false
            Error        = $_.Exception.Message
        }
    }
}

# Export summary
$results | Export-Csv -Path $ReportPath -NoTypeInformation
Write-Host "`nReport saved to: $ReportPath" -ForegroundColor Yellow

```

### 2.6 Update History & Compliance Queries

```powershell
# Show the last 30 days of installed updates
Get-WUHistory | Where-Object {
    $_.Date -gt (Get-Date).AddDays(-30)
} | Select-Object Date, Title, KB, Result | Sort-Object Date -Descending

# Check if a specific KB is installed (returns nothing if missing)
Get-HotFix -Id "KB5034441"

# Audit multiple machines for a specific KB
$computers = "PC01","PC02","PC03"
$computers | ForEach-Object {
    $hotfix = Get-HotFix -ComputerName $_ -Id "KB5034441" -ErrorAction SilentlyContinue
    [PSCustomObject]@{
        Computer  = $_
        Installed = ($null -ne $hotfix)
        InstalledOn = $hotfix.InstalledOn
    }
}

```

----------

## 3. Disk Partitioning — SSD & HDD

PowerShell exposes the full `Storage` module for partition management. The key distinction when working with SSDs versus HDDs is **alignment** — SSDs perform better when partitions start on 1 MB boundaries (the `Offset` parameter).

### 3.1 Disk Topology at a Glance

```
Physical Disk (e.g., Disk 1 — 500 GB NVMe SSD)
│
├── Partition Table (GPT recommended for disks > 2 TB or UEFI systems)
│   ├── Partition 1 — EFI System Partition (ESP)  ~100 MB  [FAT32]
│   ├── Partition 2 — MSR (Microsoft Reserved)     ~16 MB
│   ├── Partition 3 — Windows OS / Data            remaining space  [NTFS]
│   └── (optional) Recovery partition              ~500 MB  [NTFS]
│
└── Partition Table (MBR — legacy BIOS, max 4 primary partitions, max 2 TB)
    ├── Primary Partition 1
    ├── Primary Partition 2
    ├── Extended Partition
    │   └── Logical drives...
    └── ...

```

> **GPT vs MBR:** Always use GPT for modern machines (UEFI boot, NVMe, or disks over 2 TB). Use MBR only when targeting legacy BIOS systems.

### 3.2 Discovering Disks and Partitions

```powershell
# List all physical disks
Get-Disk | Select-Object Number, FriendlyName, Size, PartitionStyle, OperationalStatus

# Detailed partition layout for a specific disk
Get-Partition -DiskNumber 1 | Select-Object PartitionNumber, DriveLetter,
    Size, Offset, Type, IsSystem, IsActive

# List all volumes with filesystem info
Get-Volume | Select-Object DriveLetter, FileSystemLabel, FileSystem,
    SizeRemaining, Size, HealthStatus

# Find which disk a drive letter lives on
$vol = Get-Volume -DriveLetter D
$part = Get-Partition | Where-Object { $_.AccessPaths -contains "$($vol.Path)" }
Get-Disk -Number $part.DiskNumber

```

### 3.3 Initializing a New Disk

```powershell
# Show raw (uninitialized) disks
Get-Disk | Where-Object { $_.PartitionStyle -eq "RAW" }

# Initialize as GPT (recommended) — this is non-destructive until you partition
Initialize-Disk -Number 2 -PartitionStyle GPT

# Initialize as MBR (legacy)
Initialize-Disk -Number 2 -PartitionStyle MBR

# Confirm
Get-Disk -Number 2 | Select-Object PartitionStyle, OperationalStatus

```

### 3.4 Creating Partitions — SSD Best Practices

For SSDs, always align to **1 MB (1048576 bytes)** boundaries to avoid performance-killing partial-stripe writes.

```powershell
# ── Full-disk single partition (most common use case) ───────────────────────
$disk = Get-Disk -Number 2

# Use -UseMaximumSize to fill remaining space
$partition = New-Partition -DiskNumber $disk.Number `
    -UseMaximumSize `
    -AssignDriveLetter  # PowerShell auto-picks the next letter

# Format as NTFS with a meaningful label
Format-Volume -DriveLetter $partition.DriveLetter `
    -FileSystem NTFS `
    -NewFileSystemLabel "DataDrive" `
    -AllocationUnitSize 4096 `  # 4 KB clusters — default, optimal for most workloads
    -Confirm:$false

Write-Host "Drive $($partition.DriveLetter): created and formatted."

```

```powershell
# ── Multi-partition layout (e.g., OS + Data + Recovery) ─────────────────────

$diskNum = 3
Initialize-Disk -Number $diskNum -PartitionStyle GPT -PassThru

# OS partition — 120 GB, aligned at offset 1 MB
New-Partition -DiskNumber $diskNum `
    -Size 128GB `
    -DriveLetter C `
    -Offset 1MB    # <-- SSD alignment

# Data partition — 300 GB
New-Partition -DiskNumber $diskNum `
    -Size 300GB `
    -DriveLetter D

# Recovery — use remaining space
New-Partition -DiskNumber $diskNum `
    -UseMaximumSize `
    -DriveLetter E

# Format all three
"C","D","E" | ForEach-Object {
    Format-Volume -DriveLetter $_ -FileSystem NTFS -NewFileSystemLabel "$($_)-Vol" -Confirm:$false
}

```

### 3.5 Resizing Partitions

```powershell
# ── Extend a partition to fill unallocated space ─────────────────────────────
$maxSize = (Get-PartitionSupportedSize -DriveLetter D).SizeMax
Resize-Partition -DriveLetter D -Size $maxSize

# ── Shrink a partition (creates unallocated space for a new one) ─────────────
# Get the minimum shrinkable size first
$minSize = (Get-PartitionSupportedSize -DriveLetter D).SizeMin
# Shrink to 100 GB (ensure this is larger than SizeMin)
Resize-Partition -DriveLetter D -Size 100GB

```

### 3.6 HDD-Specific — Formatting with 4K Native (Advanced Format)

Modern HDDs use 4096-byte physical sectors. Use a matching allocation unit size:

```powershell
# Check if a disk uses 4K native sectors
Get-Disk -Number 1 | Select-Object PhysicalSectorSize, LogicalSectorSize

# Format with 4096-byte clusters for 4K native HDDs
Format-Volume -DriveLetter E `
    -FileSystem NTFS `
    -AllocationUnitSize 4096 `
    -NewFileSystemLabel "Archive" `
    -Confirm:$false

```

### 3.7 Removing Partitions Safely

```powershell
# Identify before deleting — always double-check!
Get-Partition -DiskNumber 3 | Format-Table

# Remove a specific partition by number
Remove-Partition -DiskNumber 3 -PartitionNumber 2 -Confirm:$true

# Clear all partitions from a disk (DESTRUCTIVE — no undo)
# The -Confirm:$false skips the prompt; remove it to be prompted
Clear-Disk -Number 3 -RemoveData -RemoveOEM -Confirm:$false

```

----------

### 4.2 BitLocker Setup Flow

```
┌──────────────────────────────────────────────────────────┐
│                  BitLocker Enable Flow                   │
│                                                          │
│  1. Check TPM status      ──► Get-Tpm                   │
│  2. Enable BitLocker      ──► Enable-BitLocker           │
│  3. Add recovery key      ──► Add-BitLockerKeyProtector  │
│  4. Back up to AD         ──► Backup-BitLockerKeyProtector│
│  5. Monitor encryption    ──► Get-BitLockerVolume        │
└──────────────────────────────────────────────────────────┘

```

### 4.3 Enabling BitLocker

```powershell
# ── Check TPM readiness ──────────────────────────────────────────────────────
$tpm = Get-Tpm
if (-not $tpm.TpmPresent) {
    Write-Warning "No TPM found. BitLocker will require a startup key on USB."
}
if (-not $tpm.TpmReady) {
    Write-Warning "TPM present but not initialized. Check BIOS settings."
}

# ── Enable BitLocker on C: with TPM + PIN ────────────────────────────────────
# The PIN must be a SecureString to avoid logging plaintext
$securePin = Read-Host "Enter 6-digit PIN" -AsSecureString

Enable-BitLocker -MountPoint "C:" `
    -EncryptionMethod XtsAes256 `     # XTS-AES-256 is strongest; use AES256 for removable drives
    -TpmAndPinProtector `
    -Pin $securePin

# ── Add a recovery key protector (CRITICAL — do this every time) ─────────────
Add-BitLockerKeyProtector -MountPoint "C:" -RecoveryPasswordProtector

# ── Verify the protectors that are registered ────────────────────────────────
(Get-BitLockerVolume -MountPoint "C:").KeyProtector | 
    Select-Object KeyProtectorId, KeyProtectorType, RecoveryPassword

```

### 4.4 Backing Up Recovery Keys to Active Directory

```powershell
# Get the recovery key protector ID
$vol       = Get-BitLockerVolume -MountPoint "C:"
$recoverId = ($vol.KeyProtector | Where-Object { $_.KeyProtectorType -eq "RecoveryPassword" }).KeyProtectorId

# Back up to AD DS (requires BitLocker AD schema extensions in your domain)
Backup-BitLockerKeyProtector -MountPoint "C:" -KeyProtectorId $recoverId

# Confirm backup succeeded — check if the key is in the computer's AD object
# (Run from a DC or machine with RSAT)
$computerDN = (Get-ADComputer $env:COMPUTERNAME).DistinguishedName
Get-ADObject -Filter { objectClass -eq "msFVE-RecoveryInformation" } `
    -SearchBase $computerDN -Properties msFVE-RecoveryPassword |
    Select-Object Name, msFVE-RecoveryPassword

```

### 4.5 BitLocker on Removable Drives (BitLocker To Go)

```powershell
# Encrypt a USB drive (uses AES256, not XTS-AES which is OS-volume only)
$usbPassword = Read-Host "USB Password" -AsSecureString

Enable-BitLocker -MountPoint "E:" `
    -EncryptionMethod Aes256 `
    -PasswordProtector `
    -Password $usbPassword

# Add recovery key
Add-BitLockerKeyProtector -MountPoint "E:" -RecoveryPasswordProtector

# Check encryption progress (EncryptionPercentage will count up to 100)
Get-BitLockerVolume -MountPoint "E:" | Select-Object MountPoint, VolumeStatus, EncryptionPercentage

```

### 4.6 BitLocker Bulk Audit Script

Use this to check BitLocker status across a fleet:

```powershell
param([string[]]$ComputerName = @("localhost"))

$report = foreach ($computer in $ComputerName) {
    try {
        $volumes = Invoke-Command -ComputerName $computer -ScriptBlock {
            Get-BitLockerVolume | Select-Object MountPoint, VolumeStatus,
                EncryptionPercentage, ProtectionStatus, KeyProtector
        }
        foreach ($vol in $volumes) {
            [PSCustomObject]@{
                Computer            = $computer
                Drive               = $vol.MountPoint
                Status              = $vol.VolumeStatus
                EncPct              = $vol.EncryptionPercentage
                Protected           = $vol.ProtectionStatus
                HasRecoveryPassword = ($vol.KeyProtector.KeyProtectorType -contains "RecoveryPassword")
            }
        }
    } catch {
        [PSCustomObject]@{
            Computer = $computer; Drive = "ERROR"; Status = $_.Exception.Message
        }
    }
}

$report | Format-Table -AutoSize
$report | Export-Csv "C:\Logs\BitLockerAudit_$(Get-Date -Format yyyyMMdd).csv" -NoTypeInformation

```

### 4.7 EFS (Encrypting File System)

EFS encrypts at the file level using the logged-in user's certificate — transparent to that user, opaque to everyone else.

```powershell
# Encrypt a folder (and all files in it) with EFS
$folder = "C:\Users\jsmith\SensitiveData"
cipher /e /s:$folder    # /e = encrypt, /s = apply to subdirectories

# Verify EFS status of a file
cipher /u "C:\Users\jsmith\SensitiveData\budget.xlsx"   # shows key thumbprint

# Decrypt (must run as the encrypting user)
cipher /d /s:$folder

# Using PowerShell directly (equivalent to checking the attribute)
$file = Get-Item "C:\Users\jsmith\SensitiveData\budget.xlsx"
$file.Attributes -band [System.IO.FileAttributes]::Encrypted  # non-zero = encrypted

```

> **Important:** EFS is tied to the user certificate. If you delete a user profile without exporting the EFS certificate and key, encrypted files become permanently unrecoverable unless a **Data Recovery Agent (DRA)** was configured in Group Policy ahead of time.

### 4.8 Configuring an EFS Data Recovery Agent via GPO

```powershell
# Step 1: Generate a recovery agent certificate on the DRA machine
cipher /r:EFSRecoveryAgent   # Creates EFSRecoveryAgent.cer and .pfx

# Step 2: Import the .cer into GPO
# (This part is done in GPMC or via the registry path)
# Computer Config → Windows Settings → Security Settings →
# Public Key Policies → Encrypting File System → right-click → Add Data Recovery Agent

# Step 3: Verify the DRA is configured
certutil -store EFS    # shows EFS certs including DRA on this machine

```

----------

## 5. Active Directory Common Tasks

### 5.1 Required Module

All AD cmdlets require the `ActiveDirectory` module, part of RSAT:

```powershell
# Install RSAT on Windows 10/11 (requires internet or WSUS)
Add-WindowsCapability -Online -Name "Rsat.ActiveDirectory.DS-LDS.Tools~~~~0.0.1.0"

# Verify
Get-Module -ListAvailable ActiveDirectory
Import-Module ActiveDirectory

```

### 5.2 AD Object Hierarchy (Quick Reference)

```
Forest (contoso.com)
│
├── Domain (corp.contoso.com)
│   ├── Organizational Unit (OU=Users,OU=Corp,DC=corp,DC=contoso,DC=com)
│   │   ├── User Objects
│   │   └── Contact Objects
│   ├── OU=Computers
│   │   └── Computer Objects
│   ├── OU=Groups
│   │   ├── Security Groups
│   │   └── Distribution Groups
│   └── OU=ServiceAccounts
│       └── Service Accounts / MSAs / gMSAs
│
└── Domain (subsidiary.contoso.com)
    └── ...

```

### 5.3 User Management

#### Creating Users

```powershell
# ── Single user creation ─────────────────────────────────────────────────────
$password = Read-Host "Initial Password" -AsSecureString

New-ADUser `
    -Name            "Jane Smith" `
    -GivenName       "Jane" `
    -Surname         "Smith" `
    -SamAccountName  "jsmith" `
    -UserPrincipalName "jsmith@corp.contoso.com" `
    -Path            "OU=Users,OU=HR,DC=corp,DC=contoso,DC=com" `
    -AccountPassword $password `
    -ChangePasswordAtLogon $true `
    -Enabled         $true `
    -Department      "Human Resources" `
    -Title           "HR Coordinator" `
    -Company         "Contoso Corp" `
    -OfficePhone     "555-1234" `
    -EmailAddress    "jsmith@contoso.com"

Write-Host "User jsmith created successfully."

```

#### Bulk User Import from CSV

```powershell
# Expected CSV columns: FirstName,LastName,Username,OU,Department,Title,Email
# Example row: Jane,Smith,jsmith,"OU=HR,DC=corp,DC=contoso,DC=com",HR,Coordinator,jsmith@contoso.com

$defaultPassword = ConvertTo-SecureString "Welcome1!" -AsPlainText -Force
$users = Import-Csv "C:\Scripts\new_users.csv"

foreach ($user in $users) {
    $displayName = "$($user.FirstName) $($user.LastName)"
    $upn         = "$($user.Username)@corp.contoso.com"

    try {
        New-ADUser `
            -Name              $displayName `
            -GivenName         $user.FirstName `
            -Surname           $user.LastName `
            -SamAccountName    $user.Username `
            -UserPrincipalName $upn `
            -Path              $user.OU `
            -AccountPassword   $defaultPassword `
            -ChangePasswordAtLogon $true `
            -Enabled           $true `
            -Department        $user.Department `
            -Title             $user.Title `
            -EmailAddress      $user.Email

        Write-Host "[OK] Created: $displayName ($($user.Username))" -ForegroundColor Green
    } catch {
        Write-Host "[FAIL] $displayName — $_" -ForegroundColor Red
    }
}

```

#### Modifying and Querying Users

```powershell
# Get all properties of a user
Get-ADUser -Identity "jsmith" -Properties *

# Update common attributes
Set-ADUser -Identity "jsmith" `
    -Title       "Senior HR Coordinator" `
    -Department  "Human Resources" `
    -Manager     (Get-ADUser -Identity "mboss")

# Disable an account (e.g., employee offboarding)
Disable-ADAccount -Identity "jsmith"

# Move to a different OU (e.g., "Leavers" OU during offboarding)
Move-ADObject -Identity (Get-ADUser "jsmith").DistinguishedName `
    -TargetPath "OU=Leavers,DC=corp,DC=contoso,DC=com"

# Unlock a locked account
Unlock-ADAccount -Identity "jsmith"

# Force password reset at next logon
Set-ADUser -Identity "jsmith" -ChangePasswordAtLogon $true

# Reset password
$newPwd = Read-Host "New Password" -AsSecureString
Set-ADAccountPassword -Identity "jsmith" -NewPassword $newPwd -Reset

```

### 5.4 Group Management

```powershell
# ── Create a new security group ──────────────────────────────────────────────
New-ADGroup `
    -Name           "GRP_Finance_ReadOnly" `
    -GroupScope     Global `           # Global | DomainLocal | Universal
    -GroupCategory  Security `         # Security | Distribution
    -Path           "OU=Groups,DC=corp,DC=contoso,DC=com" `
    -Description    "Read-only access to Finance file shares"

# ── Add/Remove members ───────────────────────────────────────────────────────
Add-ADGroupMember -Identity "GRP_Finance_ReadOnly" -Members "jsmith","bwilliams"
Remove-ADGroupMember -Identity "GRP_Finance_ReadOnly" -Members "bwilliams" -Confirm:$false

# ── Enumerate members ────────────────────────────────────────────────────────
Get-ADGroupMember -Identity "GRP_Finance_ReadOnly" -Recursive |
    Select-Object Name, SamAccountName, objectClass | Sort-Object Name

# ── Find all groups a user belongs to ───────────────────────────────────────
(Get-ADUser -Identity "jsmith" -Properties MemberOf).MemberOf |
    ForEach-Object { (Get-ADGroup $_).Name } | Sort-Object

# ── Nested group membership (recursive) ─────────────────────────────────────
Get-ADGroupMember -Identity "Domain Admins" -Recursive |
    Where-Object { $_.objectClass -eq "user" }

```

### 5.5 Computer Object Management

```powershell
# Find all computers in a specific OU
Get-ADComputer -Filter * -SearchBase "OU=Workstations,DC=corp,DC=contoso,DC=com" |
    Select-Object Name, DistinguishedName, Enabled

# Find computers that haven't logged in for 90+ days (stale objects)
$cutoff = (Get-Date).AddDays(-90)
Get-ADComputer -Filter { LastLogonDate -lt $cutoff } `
    -Properties LastLogonDate, OperatingSystem |
    Select-Object Name, LastLogonDate, OperatingSystem |
    Sort-Object LastLogonDate

# Disable stale computer accounts
Get-ADComputer -Filter { LastLogonDate -lt $cutoff } -Properties LastLogonDate |
    ForEach-Object {
        Disable-ADAccount -Identity $_.SamAccountName
        Write-Host "Disabled: $($_.Name)"
    }

# Join a computer to the domain (run locally on the target machine)
Add-Computer `
    -DomainName    "corp.contoso.com" `
    -OUPath        "OU=Workstations,OU=Corp,DC=corp,DC=contoso,DC=com" `
    -Credential    (Get-Credential) `
    -Restart       # reboots immediately; use -NoRestart to defer

```

### 5.6 OU Management

```powershell
# Create a new OU
New-ADOrganizationalUnit `
    -Name                            "Finance" `
    -Path                            "OU=Corp,DC=corp,DC=contoso,DC=com" `
    -ProtectedFromAccidentalDeletion $true `   # prevents Delete in ADUC by mistake
    -Description                     "Finance department objects"

# List all OUs in the domain
Get-ADOrganizationalUnit -Filter * |
    Select-Object Name, DistinguishedName | Sort-Object DistinguishedName

# Remove an OU (must first disable accidental deletion protection)
Set-ADOrganizationalUnit -Identity "OU=Finance,OU=Corp,DC=corp,DC=contoso,DC=com" `
    -ProtectedFromAccidentalDeletion $false
Remove-ADOrganizationalUnit -Identity "OU=Finance,OU=Corp,DC=corp,DC=contoso,DC=com" `
    -Recursive -Confirm:$true

```

### 5.7 Group Policy Queries

```powershell
# List all GPOs in the domain
Get-GPO -All | Select-Object DisplayName, GpoStatus, CreationTime, ModificationTime

# Get GPO links for an OU
Get-GPInheritance -Target "OU=Users,OU=HR,DC=corp,DC=contoso,DC=com" |
    Select-Object -ExpandProperty GpoLinks

# Create and link a new GPO
$gpo = New-GPO -Name "SEC_Disable_USB_Storage" -Comment "Blocks USB mass storage devices"
New-GPLink -Name $gpo.DisplayName -Target "OU=Workstations,DC=corp,DC=contoso,DC=com"

# Force a GPUpdate on a remote machine
Invoke-GPUpdate -Computer "PC01" -Force -RandomDelayInMinutes 0

```

### 5.8 Password Policy & Lockout

```powershell
# View the default domain password policy
Get-ADDefaultDomainPasswordPolicy

# View a Fine-Grained Password Policy (PSO)
Get-ADFineGrainedPasswordPolicy -Filter * |
    Select-Object Name, MinPasswordLength, LockoutThreshold, LockoutDuration

# Apply a PSO to a group
Add-ADFineGrainedPasswordPolicySubject `
    -Identity "PSO_AdminAccounts" `
    -Subjects "Domain Admins","GRP_ServiceAccounts"

# Find locked-out accounts across the domain
Search-ADAccount -LockedOut | Select-Object Name, SamAccountName, LockedOut

# Unlock all locked accounts (use cautiously)
Search-ADAccount -LockedOut | Unlock-ADAccount

```

### 5.9 Replication & Domain Health

```powershell
# Check replication status between DCs
repadmin /replsummary       # summary (run in CMD or via Invoke-Expression)
Get-ADReplicationFailure -Scope Domain   # PowerShell equivalent

# Check SYSVOL and NETLOGON share availability on all DCs
$dcs = (Get-ADDomainController -Filter *).Name
foreach ($dc in $dcs) {
    $sysvol  = Test-Path "\\$dc\SYSVOL"
    $netlogon = Test-Path "\\$dc\NETLOGON"
    [PSCustomObject]@{
        DC       = $dc
        SYSVOL   = $sysvol
        NETLOGON = $netlogon
    }
}

# Force replication from a specific source DC
Sync-ADObject -Object (Get-ADDomain).DistinguishedName `
    -Source "DC01" -Destination "DC02"

```

----------

## 6. Error Handling Patterns

Good scripts fail gracefully and leave a breadcrumb trail. Here are the patterns used throughout this guide, explained in context.

### 6.1 Try/Catch/Finally

```powershell
try {
    # Code that might fail
    Get-ADUser -Identity "nonexistent_user" -ErrorAction Stop  # ErrorAction Stop is key:
    # without it, non-terminating errors skip the catch block entirely
} catch [Microsoft.ActiveDirectory.Management.ADIdentityNotFoundException] {
    # Catch a SPECIFIC exception type — more precise than catching everything
    Write-Warning "User not found. Continuing..."
} catch {
    # Generic fallback for any other error
    Write-Error "Unexpected error: $($_.Exception.Message)"
    # $_ is the ErrorRecord; $_.Exception.Message is the human-readable text
    # $_.ScriptStackTrace shows where in the script it failed
} finally {
    # Runs regardless of success or failure — use for cleanup
    Write-Host "Cleanup complete."
}

```

### 6.2 Validating Input Before Acting

```powershell
function Remove-StaleUser {
    param(
        [Parameter(Mandatory)][string]$Username,
        [switch]$WhatIf
    )

    # Guard clause — validate before doing anything irreversible
    $user = Get-ADUser -Filter { SamAccountName -eq $Username } -ErrorAction SilentlyContinue
    if (-not $user) {
        Write-Warning "User '$Username' not found. Skipping."
        return   # exit the function early
    }

    if ($user.Enabled) {
        Write-Warning "User '$Username' is still enabled. Disable first."
        return
    }

    if ($WhatIf) {
        Write-Host "[WhatIf] Would delete: $($user.DistinguishedName)"
        return
    }

    Remove-ADUser -Identity $user.SamAccountName -Confirm:$false
    Write-Host "Deleted: $Username"
}

```

### 6.3 Retrying Transient Failures

Useful when running against remote machines or services that may be temporarily unavailable:

```powershell
function Invoke-WithRetry {
    param(
        [ScriptBlock]$Action,
        [int]$MaxAttempts = 3,
        [int]$DelaySeconds = 5
    )
    $attempt = 0
    do {
        $attempt++
        try {
            return & $Action   # & invokes the ScriptBlock; return exits the function
        } catch {
            if ($attempt -ge $MaxAttempts) { throw }
            Write-Warning "Attempt $attempt failed. Retrying in ${DelaySeconds}s... ($_)"
            Start-Sleep -Seconds $DelaySeconds
        }
    } while ($attempt -lt $MaxAttempts)
}

# Usage
Invoke-WithRetry -Action {
    Invoke-Command -ComputerName "PC01" -ScriptBlock { Get-Service "wuauserv" }
}

```

----------

## 7. Logging & Reporting

### 7.1 Structured Log Function

```powershell
function Write-Log {
    param(
        [string]$Message,
        [ValidateSet("INFO","WARN","ERROR","DEBUG")][string]$Level = "INFO",
        [string]$LogFile = "C:\Logs\automation.log"
    )

    # Ensure log directory exists
    $dir = Split-Path $LogFile
    if (-not (Test-Path $dir)) { New-Item -ItemType Directory -Path $dir -Force | Out-Null }

    $entry = "[{0}] [{1}] [{2}] {3}" -f `
        (Get-Date -Format "yyyy-MM-dd HH:mm:ss"),
        $Level,
        $env:USERNAME,
        $Message

    Add-Content -Path $LogFile -Value $entry

    # Also write to console with colour coding
    switch ($Level) {
        "ERROR" { Write-Host $entry -ForegroundColor Red }
        "WARN"  { Write-Host $entry -ForegroundColor Yellow }
        "DEBUG" { Write-Verbose $entry }
        default { Write-Host $entry -ForegroundColor Gray }
    }
}

```

### 7.2 HTML Report Generation

```powershell
# Generate a styled HTML report from any object collection
function Export-HTMLReport {
    param(
        [object[]]$Data,
        [string]$Title = "Automation Report",
        [string]$OutputPath = "C:\Reports\report.html"
    )

    $style = @"
<style>
  body { font-family: Segoe UI, Arial, sans-serif; font-size: 14px; }
  table { border-collapse: collapse; width: 100%; }
  th { background: #0078D4; color: white; padding: 8px; text-align: left; }
  td { padding: 6px 8px; border-bottom: 1px solid #ddd; }
  tr:nth-child(even) { background: #f5f5f5; }
  h1 { color: #0078D4; }
  .timestamp { color: gray; font-size: 12px; }
</style>
"@

    $body = $Data | ConvertTo-Html -Property * -Fragment

    $html = ConvertTo-Html -Head $style -Body @"
<h1>$Title</h1>
<p class='timestamp'>Generated: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') by $env:USERNAME</p>
$body
"@

    $html | Out-File -FilePath $OutputPath -Encoding UTF8
    Write-Host "Report saved: $OutputPath"
}

# Usage example
$adReport = Get-ADUser -Filter * -Properties LastLogonDate, Department |
    Select-Object Name, SamAccountName, Department, LastLogonDate, Enabled

Export-HTMLReport -Data $adReport -Title "AD User Report" -OutputPath "C:\Reports\users.html"

```

----------

## 8. Quick Reference Tables

### PowerShell Modules by Task Area

Task Area

Module

Install Command

Windows Updates

`PSWindowsUpdate`

`Install-Module PSWindowsUpdate`

Active Directory

`ActiveDirectory`

RSAT feature (see §5.1)

BitLocker

Built-in (`BitLocker`)

None — included in Windows

Disk Management

Built-in (`Storage`)

None — included in Windows

Group Policy

`GroupPolicy`

RSAT: `Add-WindowsCapability`

DNS

`DnsServer` / `DnsClient`

RSAT (server) / built-in (client)

DHCP

`DhcpServer`

RSAT feature

### Common AD Filter Patterns

Goal

Filter Syntax

All enabled users

`{Enabled -eq $true}`

Users in a specific department

`{Department -eq "Finance"}`

Accounts not logged in for 90 days

`{LastLogonDate -lt (Get-Date).AddDays(-90)}`

Accounts with no password expiry

`{PasswordNeverExpires -eq $true}`

Computers running Windows 11

`{OperatingSystem -like "*Windows 11*"}`

Groups with "Admin" in the name

`{Name -like "*Admin*"}`

### BitLocker Encryption Methods

Method

Key Length

Use Case

Notes

`XtsAes256`

256-bit

OS drives, fixed data drives

Strongest; Windows 10 1511+

`XtsAes128`

128-bit

OS drives, fixed data drives

Slightly faster on older hardware

`Aes256`

256-bit

Removable drives

Compatible with older Windows versions

`Aes128`

128-bit

Removable drives

Widest compatibility

### Partition Type GUIDs (GPT)

Partition Type

GUID

Purpose

EFI System

`C12A7328-F81F-11D2-BA4B-00A0C93EC93B`

Boot loader (ESP)

Microsoft Reserved

`E3C9E316-0B5C-4DB8-817D-F92DF00215AE`

MSR — Windows internal

Basic Data

`EBD0A0A2-B9E5-4433-87C0-68B6B72699C7`

Standard NTFS/FAT data

Windows Recovery

`DE94BBA4-06D1-4D40-A16A-BFD50179D6AC`

WinRE recovery environment

----------

## 9. References

### Official Microsoft Documentation

Topic

URL

PSWindowsUpdate module

https://www.powershellgallery.com/packages/PSWindowsUpdate

`Get-Partition` reference

https://learn.microsoft.com/powershell/module/storage/get-partition

`Enable-BitLocker` reference

https://learn.microsoft.com/powershell/module/bitlocker/enable-bitlocker

AD PowerShell module overview

https://learn.microsoft.com/powershell/module/activedirectory

BitLocker overview

https://learn.microsoft.com/windows/security/operating-system-security/data-protection/bitlocker

EFS overview

https://learn.microsoft.com/windows/win32/fileio/file-encryption

GPT disk structure

https://learn.microsoft.com/windows-server/storage/disk-management/overview-of-disk-management

Fine-grained password policies

https://learn.microsoft.com/windows-server/identity/ad-ds/get-started/virtual-dc/fine-grained-password-policies

### Useful Community Tools

Tool

Purpose

URL

PSWindowsUpdate

Windows Update scripting

https://mikefrobbins.com/tag/pswindowsupdate/

LAPS (Local Admin Password Solution)

Randomise local admin passwords, store in AD

https://learn.microsoft.com/defender-for-identity/laps

MBAM (Microsoft BitLocker Administration)

Enterprise BitLocker management

Now integrated into MEMCM/Intune

AD Tidy

AD cleanup and reporting

https://github.com/simeoncloud/ADTidy

----------

> **Tip:** Save frequently used functions (like `Write-Log` and `Export-HTMLReport`) in a shared module file (`MyOrgTools.psm1`) and import it at the top of every script. This keeps your codebase DRY and makes updates instant across all scripts.

> **Security reminder:** Never hardcode credentials in scripts. Use `Get-Credential`, `SecureString`, Windows Credential Manager (`CredentialManager` module), or a secrets vault like HashiCorp Vault or Azure Key Vault.

