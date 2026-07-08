# 🐚 PowerShell Guide

A comprehensive reference for PowerShell covering syntax, scripting, system management, automation, and a glossary of core cmdlets with examples.

---
# Overview

PowerShell is an object-oriented scripting language and shell used for automation, configuration management, and administrative tasks.

---

# Syntax Fundamentals

```powershell
# Command structure
Verb-Noun -Parameter Value

Get-Process -Name "explorer"
```

---

# Data Types

| Type | Example |
|------|--------|
| String | "Hello" |
| Int | 10 |
| Bool | $true |
| Array | @(1,2,3) |
| Hashtable | @{Name="John"} |
| Object | [PSCustomObject]@{A=1} |

---

# Variables

```powershell
$name = "Keith"
$number = 10
$array = @(1,2,3)
```

---

# Operators

| Operator | Meaning | Example |
|----------|--------|--------|
| -eq | Equal | $a -eq $b |
| -ne | Not equal | $a -ne $b |
| -gt | Greater than | $a -gt 5 |
| -lt | Less than | $a -lt 5 |
| -like | Pattern match | $a -like "*test*" |

---

# Control Flow

## If

```powershell
if ($x -gt 5) {
    "Greater"
}
```

## Loop

```powershell
foreach ($item in $array) {
    $item
}
```

---

# Functions

```powershell
function Get-Square {
    param($x)
    return $x * $x
}
```

---

# Modules

```powershell
Import-Module Storage
Get-Module
```

---

# Pipeline

```powershell
Get-Process | Where-Object {$_.CPU -gt 100} | Select-Object Name, CPU
```

---

# Error Handling

```powershell
try {
    Get-Item "C:\fake"
} catch {
    Write-Error "Failed"
}
```

---

# File & System Management

| Cmdlet | Purpose | Example |
|--------|--------|--------|
| Get-Item | Retrieve item | Get-Item C:\file.txt |
| Set-Item | Modify item | Set-Item |
| Copy-Item | Copy files | Copy-Item a b |
| Remove-Item | Delete files | Remove-Item file |

---

# Disk & Partition Management

| Cmdlet | Purpose | Example |
|--------|--------|--------|
| Get-Disk | List disks | Get-Disk |
| Initialize-Disk | Init disk | Initialize-Disk -Number 1 |
| New-Partition | Create partition | New-Partition |
| Remove-Partition | Delete partition | Remove-Partition |

---

# Networking

| Cmdlet | Purpose | Example |
|--------|--------|--------|
| Test-Connection | Ping | Test-Connection google.com |
| Get-NetIPConfiguration | IP config | Get-NetIPConfiguration |
| Resolve-DnsName | DNS lookup | Resolve-DnsName google.com |

---

# Security

| Cmdlet | Purpose | Example |
|--------|--------|--------|
| Get-Acl | Permissions | Get-Acl file |
| Set-Acl | Set permissions | Set-Acl |
| ConvertTo-SecureString | Encrypt | ConvertTo-SecureString |

---

# Remoting

```powershell
Enter-PSSession -ComputerName Server01
Invoke-Command -ComputerName Server01 -ScriptBlock { Get-Process }
```

---

# Automation

```powershell
# Scheduled task example
$action = New-ScheduledTaskAction -Execute "PowerShell.exe" -Argument "script.ps1"
```

---

# Glossary of Core Cmdlets

## System Cmdlets

| Cmdlet | Description | Example |
|--------|------------|--------|
| Get-Process | Lists processes | Get-Process |
| Stop-Process | Stops process | Stop-Process -Name notepad |
| Get-Service | List services | Get-Service |
| Start-Service | Start service | Start-Service wuauserv |

## File Cmdlets

| Cmdlet | Description | Example |
|--------|------------|--------|
| Get-ChildItem | List directory | Get-ChildItem |
| New-Item | Create file | New-Item file.txt |
| Remove-Item | Delete | Remove-Item file.txt |

## Object Cmdlets

| Cmdlet | Description | Example |
|--------|------------|--------|
| Where-Object | Filter | Where-Object {$_.Name -eq "test"} |
| Select-Object | Select props | Select-Object Name |
| Sort-Object | Sort | Sort-Object Name |

## Utility Cmdlets

| Cmdlet | Description | Example |
|--------|------------|--------|
| Write-Output | Output text | Write-Output "Hi" |
| Write-Host | Display | Write-Host "Hello" |
| Measure-Object | Count | Measure-Object |

---

# Massive PowerShell Cmdlet Reference Table

> Categorized core and commonly used cmdlets with concise purpose and example usage.

## Process Management

| Cmdlet | Purpose | Example |
|--------|--------|--------|
| Get-Process | List processes | Get-Process |
| Start-Process | Start process | Start-Process notepad |
| Stop-Process | Stop process | Stop-Process -Name notepad |
| Wait-Process | Wait for exit | Wait-Process -Name notepad |
| Debug-Process | Attach debugger | Debug-Process -Id 1234 |

## Service Management

| Cmdlet | Purpose | Example |
|--------|--------|--------|
| Get-Service | List services | Get-Service |
| Start-Service | Start service | Start-Service wuauserv |
| Stop-Service | Stop service | Stop-Service wuauserv |
| Restart-Service | Restart service | Restart-Service wuauserv |
| Set-Service | Configure service | Set-Service -Name wuauserv -StartupType Manual |

## File System

| Cmdlet | Purpose | Example |
|--------|--------|--------|
| Get-ChildItem | List files/dirs | Get-ChildItem C:\ |
| New-Item | Create item | New-Item file.txt |
| Remove-Item | Delete item | Remove-Item file.txt |
| Copy-Item | Copy | Copy-Item a.txt b.txt |
| Move-Item | Move | Move-Item a.txt C:\temp |
| Rename-Item | Rename | Rename-Item a.txt b.txt |
| Test-Path | Exists check | Test-Path C:\file.txt |
| Get-Content | Read file | Get-Content file.txt |
| Set-Content | Write file | Set-Content file.txt "data" |
| Add-Content | Append | Add-Content file.txt "more" |

## Object & Pipeline

| Cmdlet | Purpose | Example |
|--------|--------|--------|
| Where-Object | Filter | Where-Object {$_.CPU -gt 100} |
| Select-Object | Select props | Select-Object Name |
| Sort-Object | Sort | Sort-Object Name |
| Group-Object | Group | Group-Object Status |
| Measure-Object | Measure | Measure-Object -Line |
| ForEach-Object | Iterate | ForEach-Object { $_ } |

## Disk & Storage

| Cmdlet | Purpose | Example |
|--------|--------|--------|
| Get-Disk | List disks | Get-Disk |
| Initialize-Disk | Init disk | Initialize-Disk -Number 1 |
| Get-Partition | List partitions | Get-Partition -DiskNumber 1 |
| New-Partition | Create | New-Partition -DiskNumber 1 -Size 10GB |
| Remove-Partition | Delete | Remove-Partition -DiskNumber 1 -PartitionNumber 1 |
| Resize-Partition | Resize | Resize-Partition -DriveLetter C -Size 100GB |
| Format-Volume | Format | Format-Volume -DriveLetter E -FileSystem NTFS |
| Get-Volume | List volumes | Get-Volume |

## Networking

| Cmdlet | Purpose | Example |
|--------|--------|--------|
| Test-Connection | Ping | Test-Connection google.com |
| Test-NetConnection | Port test | Test-NetConnection google.com -Port 443 |
| Get-NetIPConfiguration | IP info | Get-NetIPConfiguration |
| Get-NetIPAddress | IP addresses | Get-NetIPAddress |
| Resolve-DnsName | DNS lookup | Resolve-DnsName google.com |

## Security & Identity

| Cmdlet | Purpose | Example |
|--------|--------|--------|
| Get-Acl | Get permissions | Get-Acl C:\file.txt |
| Set-Acl | Set permissions | Set-Acl |
| ConvertTo-SecureString | Encrypt string | ConvertTo-SecureString "pass" -AsPlainText -Force |
| ConvertFrom-SecureString | Decrypt | ConvertFrom-SecureString $sec |
| Get-Credential | Prompt creds | Get-Credential |

## Remoting

| Cmdlet | Purpose | Example |
|--------|--------|--------|
| Enter-PSSession | Remote shell | Enter-PSSession server |
| Exit-PSSession | Exit | Exit-PSSession |
| Invoke-Command | Run remote | Invoke-Command -ComputerName server -ScriptBlock { Get-Process } |
| New-PSSession | Create session | New-PSSession server |
| Remove-PSSession | Remove session | Remove-PSSession $s |

## Jobs & Background Tasks

| Cmdlet | Purpose | Example |
|--------|--------|--------|
| Start-Job | Run background | Start-Job { Get-Process } |
| Get-Job | List jobs | Get-Job |
| Receive-Job | Get output | Receive-Job 1 |
| Stop-Job | Stop job | Stop-Job 1 |
| Remove-Job | Delete job | Remove-Job 1 |

## Modules & Packages

| Cmdlet | Purpose | Example |
|--------|--------|--------|
| Get-Module | List modules | Get-Module |
| Import-Module | Import | Import-Module Az |
| Remove-Module | Remove | Remove-Module Az |
| Install-Module | Install | Install-Module Az |
| Update-Module | Update | Update-Module Az |

## Utility

| Cmdlet | Purpose | Example |
|--------|--------|--------|
| Write-Output | Output | Write-Output "Hello" |
| Write-Host | Display | Write-Host "Hello" |
| Read-Host | Input | Read-Host "Enter" |
| Clear-Host | Clear screen | Clear-Host |
| Get-Date | Current date | Get-Date |

---

# Summary

This section provides a high-density reference table of commonly used PowerShell cmdlets across domains for rapid lookup and scripting efficiency.
