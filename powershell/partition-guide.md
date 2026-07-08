# PowerShell Disk & Partition Management

A practical guide for creating, deleting, and managing partitions on HDDs and SSDs using PowerShell.

---

## Table of Contents

- [Prerequisites](#prerequisites)
- [Core Concepts](#core-concepts)
- [Key PowerShell Cmdlets](#key-powershell-cmdlets)
- [Inspecting Disks & Partitions](#inspecting-disks--partitions)
- [Initializing a Disk](#initializing-a-disk)
- [Creating Partitions](#creating-partitions)
- [Formatting Volumes](#formatting-volumes)
- [Assigning Drive Letters](#assigning-drive-letters)
- [Resizing Partitions](#resizing-partitions)
- [Deleting Partitions](#deleting-partitions)
- [Automation Examples](#automation-examples)
- [Best Practices](#best-practices)
- [Troubleshooting](#troubleshooting)

---

## Prerequisites

- Windows 10 / Windows Server 2016+
- PowerShell 5.1 or newer
- Administrator privileges

---

## Core Concepts

| Term | Description |
|------|------------|
| Disk | Physical storage device |
| Partition | Logical section of disk |
| Volume | Formatted partition |
| GPT | Modern partition standard |
| MBR | Legacy partition standard |

---

## Key PowerShell Cmdlets

- Get-Disk
- Initialize-Disk
- Get-Partition
- New-Partition
- Remove-Partition
- Resize-Partition
- Format-Volume
- Get-Volume
- Set-Partition

---

## Inspecting Disks & Partitions

```powershell
Get-Disk
```

```powershell
Get-Partition -DiskNumber 1
```

```powershell
Get-Volume
```

---

## Initializing a Disk

```powershell
Initialize-Disk -Number 1 -PartitionStyle GPT
```

```powershell
Initialize-Disk -Number 1 -PartitionStyle MBR
```

---

## Creating Partitions

```powershell
New-Partition -DiskNumber 1 -UseMaximumSize -AssignDriveLetter
```

```powershell
New-Partition -DiskNumber 1 -Size 100GB -AssignDriveLetter
```

```powershell
New-Partition -DiskNumber 1 -Size 50GB -DriveLetter E
```

---

## Formatting Volumes

```powershell
Format-Volume -DriveLetter E -FileSystem NTFS -NewFileSystemLabel "Data"
```

```powershell
Format-Volume -DriveLetter E -FileSystem exFAT
```

---

## Assigning Drive Letters

```powershell
Set-Partition -DiskNumber 1 -PartitionNumber 1 -NewDriveLetter F
```

---

## Resizing Partitions

```powershell
Resize-Partition -DriveLetter E -Size (Get-PartitionSupportedSize -DriveLetter E).SizeMax
```

```powershell
Resize-Partition -DriveLetter E -Size 80GB
```

---

## Deleting Partitions

```powershell
Remove-Partition -DiskNumber 1 -PartitionNumber 1
```

```powershell
Remove-Partition -DiskNumber 1 -PartitionNumber 1 -Confirm:$false
```

---

## Automation Examples

```powershell
$diskNumber = 1

Initialize-Disk -Number $diskNumber -PartitionStyle GPT

$partition = New-Partition -DiskNumber $diskNumber -UseMaximumSize -AssignDriveLetter

Format-Volume -Partition $partition -FileSystem NTFS
```

---

## Best Practices

- Use GPT instead of MBR
- Verify disk numbers before changes
- Use -WhatIf before execution
- Backup data before deletion or resizing

---

## Troubleshooting

### Disk Offline

```powershell
Set-Disk -Number 1 -IsOffline $false
```

### Disk Read-only

```powershell
Set-Disk -Number 1 -IsReadOnly $false
```

### Check Resize Limits

```powershell
Get-PartitionSupportedSize -DriveLetter E
