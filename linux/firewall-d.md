# firewalld Networking Command Reference

## Overview

`firewall-cmd` is the command-line interface for **firewalld**, the dynamic firewall manager used on many Linux distributions including:

- RHEL / Rocky Linux / AlmaLinux
- Fedora
- CentOS
- openSUSE

---

# Core Concepts

| Concept          | Description                                   | Examples                            |
| ---------------- | --------------------------------------------- | ----------------------------------- |
| Zone             | Trust level profile controlling traffic rules | `public`, `home`, `internal`, `dmz` |
| Service          | Named port/protocol bundle                    | `ssh`, `http`, `https`, `samba`     |
| Port             | Explicit port/protocol rule                   | `80/tcp`, `53/udp`                  |
| Runtime Config   | Active until reboot                           | default behavior                    |
| Permanent Config | Saved configuration                           | `--permanent`                       |
| Rich Rule        | Advanced granular filtering                   | source, logging, rate limiting      |
| Masquerading     | NAT address translation                       | router/gateway setups               |
| Forward Port     | Redirect traffic                              | `8080 -> 80`                        |
| Interface        | NIC assigned to zone                          | `eth0`, `ens18`                     |
| Source           | IP/network assigned to zone                   | `192.168.1.0/24`                    |

---

# Installation & Service Management

| Action                          | Command                            | Description                  |
| ------------------------------- | ---------------------------------- | ---------------------------- |
| Install firewalld (RHEL/Fedora) | `sudo dnf install firewalld -y`    | Install package              |
| Install firewalld (Debian)      | `sudo apt install firewalld -y`    | Install package              |
| Enable firewalld                | `sudo systemctl enable firewalld`  | Start at boot                |
| Start firewalld                 | `sudo systemctl start firewalld`   | Start service                |
| Restart firewalld               | `sudo systemctl restart firewalld` | Reload daemon completely     |
| Reload rules                    | `sudo firewall-cmd --reload`       | Apply permanent changes      |
| Stop firewalld                  | `sudo systemctl stop firewalld`    | Disable firewall temporarily |
| Disable firewalld               | `sudo systemctl disable firewalld` | Disable at boot              |
| Check status                    | `sudo firewall-cmd --state`        | Running state                |
| Service status                  | `sudo systemctl status firewalld`  | Detailed service state       |

---

# Runtime vs Permanent Rules

| Operation               | Runtime                                   | Permanent                                             |
| ----------------------- | ----------------------------------------- | ----------------------------------------------------- |
| Add port                | `sudo firewall-cmd --add-port=80/tcp`     | `sudo firewall-cmd --permanent --add-port=80/tcp`     |
| Remove port             | `sudo firewall-cmd --remove-port=80/tcp`  | `sudo firewall-cmd --permanent --remove-port=80/tcp`  |
| Add service             | `sudo firewall-cmd --add-service=http`    | `sudo firewall-cmd --permanent --add-service=http`    |
| Remove service          | `sudo firewall-cmd --remove-service=http` | `sudo firewall-cmd --permanent --remove-service=http` |
| Apply permanent changes | N/A                                       | `sudo firewall-cmd --reload`                          |

---

# Zone Management

| Action                | Command                                              | Notes              |
| --------------------- | ---------------------------------------------------- | ------------------ |
| List all zones        | `sudo firewall-cmd --get-zones`                      | Available zones    |
| Active zones          | `sudo firewall-cmd --get-active-zones`               | Currently used     |
| Default zone          | `sudo firewall-cmd --get-default-zone`               | Current default    |
| Set default zone      | `sudo firewall-cmd --set-default-zone=home`          | Persistent         |
| Zone details          | `sudo firewall-cmd --zone=public --list-all`         | Full config        |
| List all zone configs | `sudo firewall-cmd --list-all-zones`                 | Every zone         |
| Create zone           | `sudo firewall-cmd --permanent --new-zone=myzone`    | Custom zone        |
| Delete zone           | `sudo firewall-cmd --permanent --delete-zone=myzone` | Remove custom zone |

---

# Interface Assignment

| Action                         | Command                                                             |
| ------------------------------ | ------------------------------------------------------------------- |
| List interfaces                | `ip addr`                                                           |
| Add interface to zone          | `sudo firewall-cmd --zone=home --change-interface=eth0`             |
| Permanent interface assignment | `sudo firewall-cmd --permanent --zone=home --change-interface=eth0` |
| Remove interface               | `sudo firewall-cmd --zone=home --remove-interface=eth0`             |
| Query interface zone           | `sudo firewall-cmd --get-zone-of-interface=eth0`                    |

---

# Source IP Assignment

| Action                  | Command                                                                     |
| ----------------------- | --------------------------------------------------------------------------- |
| Add source subnet       | `sudo firewall-cmd --zone=internal --add-source=192.168.1.0/24`             |
| Permanent source subnet | `sudo firewall-cmd --permanent --zone=internal --add-source=192.168.1.0/24` |
| Remove source           | `sudo firewall-cmd --zone=internal --remove-source=192.168.1.0/24`          |
| Query source            | `sudo firewall-cmd --zone=internal --query-source=192.168.1.0/24`           |

---

# Service Management

## Common Built-In Services

| Service      | Ports       | Protocol | Purpose              |
| ------------ | ----------- | -------- | -------------------- |
| `ssh`        | 22          | TCP      | Secure shell         |
| `http`       | 80          | TCP      | Web server           |
| `https`      | 443         | TCP      | Secure web           |
| `dns`        | 53          | TCP/UDP  | DNS service          |
| `dhcp`       | 67/68       | UDP      | DHCP server/client   |
| `smtp`       | 25          | TCP      | Mail transfer        |
| `imap`       | 143         | TCP      | Mail access          |
| `imaps`      | 993         | TCP      | Secure IMAP          |
| `pop3`       | 110         | TCP      | Mail retrieval       |
| `pop3s`      | 995         | TCP      | Secure POP3          |
| `ftp`        | 21          | TCP      | FTP server           |
| `tftp`       | 69          | UDP      | Trivial FTP          |
| `samba`      | 137-139,445 | TCP/UDP  | Windows file sharing |
| `nfs`        | 2049        | TCP/UDP  | Network file system  |
| `mdns`       | 5353        | UDP      | Multicast DNS        |
| `ipp`        | 631         | TCP/UDP  | Printer service      |
| `cockpit`    | 9090        | TCP      | Web admin            |
| `mysql`      | 3306        | TCP      | MySQL/MariaDB        |
| `postgresql` | 5432        | TCP      | PostgreSQL           |
| `mongodb`    | 27017       | TCP      | MongoDB              |
| `redis`      | 6379        | TCP      | Redis                |
| `kubernetes` | varies      | TCP      | Kubernetes cluster   |
| `libvirt`    | varies      | TCP/UDP  | Virtualization       |
| `rsyncd`     | 873         | TCP      | Rsync daemon         |

---

## List Available Services

| Action                   | Command                                  |
| ------------------------ | ---------------------------------------- |
| List predefined services | `sudo firewall-cmd --get-services`       |
| Service details          | `sudo firewall-cmd --info-service=http`  |
| Query service enabled    | `sudo firewall-cmd --query-service=http` |

---

## Enable / Disable Services

| Action                | Command                                               |
| --------------------- | ----------------------------------------------------- |
| Enable HTTP           | `sudo firewall-cmd --add-service=http`                |
| Enable HTTPS          | `sudo firewall-cmd --add-service=https`               |
| Enable SSH            | `sudo firewall-cmd --add-service=ssh`                 |
| Enable Samba          | `sudo firewall-cmd --add-service=samba`               |
| Enable printer access | `sudo firewall-cmd --add-service=ipp`                 |
| Enable DNS            | `sudo firewall-cmd --add-service=dns`                 |
| Enable Cockpit        | `sudo firewall-cmd --add-service=cockpit`             |
| Disable service       | `sudo firewall-cmd --remove-service=http`             |
| Permanent enable      | `sudo firewall-cmd --permanent --add-service=http`    |
| Permanent disable     | `sudo firewall-cmd --permanent --remove-service=http` |

---

# Port Management

## Open Ports

| Action              | Command                                             |
| ------------------- | --------------------------------------------------- |
| Open TCP port       | `sudo firewall-cmd --add-port=8080/tcp`             |
| Open UDP port       | `sudo firewall-cmd --add-port=53/udp`               |
| Open permanent port | `sudo firewall-cmd --permanent --add-port=8080/tcp` |
| Open port range     | `sudo firewall-cmd --add-port=6000-6010/tcp`        |
| Open both protocols | `sudo firewall-cmd --add-port=161/tcp` + `161/udp`  |

---

## Close Ports

| Action                | Command                                                |
| --------------------- | ------------------------------------------------------ |
| Close TCP port        | `sudo firewall-cmd --remove-port=8080/tcp`             |
| Close UDP port        | `sudo firewall-cmd --remove-port=53/udp`               |
| Remove permanent port | `sudo firewall-cmd --permanent --remove-port=8080/tcp` |
| Remove port range     | `sudo firewall-cmd --remove-port=6000-6010/tcp`        |

---

## Query Ports

| Action              | Command                                  |
| ------------------- | ---------------------------------------- |
| List open ports     | `sudo firewall-cmd --list-ports`         |
| Query specific port | `sudo firewall-cmd --query-port=443/tcp` |
| List services       | `sudo firewall-cmd --list-services`      |
| Full zone listing   | `sudo firewall-cmd --list-all`           |

---

# Port Forwarding

| Action                | Command                                                                                  |
| --------------------- | ---------------------------------------------------------------------------------------- |
| Forward 8080 → 80     | `sudo firewall-cmd --add-forward-port=port=8080:proto=tcp:toport=80`                     |
| Forward to another IP | `sudo firewall-cmd --add-forward-port=port=8080:proto=tcp:toaddr=192.168.1.50:toport=80` |
| Permanent forward     | `sudo firewall-cmd --permanent --add-forward-port=port=8080:proto=tcp:toport=80`         |
| Remove forwarding     | `sudo firewall-cmd --remove-forward-port=port=8080:proto=tcp:toport=80`                  |

---

# Masquerading / NAT

| Action                 | Command                                          |
| ---------------------- | ------------------------------------------------ |
| Enable masquerading    | `sudo firewall-cmd --add-masquerade`             |
| Permanent masquerading | `sudo firewall-cmd --permanent --add-masquerade` |
| Disable masquerading   | `sudo firewall-cmd --remove-masquerade`          |
| Query masquerade       | `sudo firewall-cmd --query-masquerade`           |

---

# Rich Rules

## Syntax

rule [family="ipv4|ipv6"] source address="IP" service name="http" accept

## Rich Rule Examples

| Purpose               | Command                                                                                                            |
| --------------------- | ------------------------------------------------------------------------------------------------------------------ |
| Allow one IP          | `sudo firewall-cmd --add-rich-rule='rule family="ipv4" source address="10.0.0.5" accept'`                          |
| Allow SSH from subnet | `sudo firewall-cmd --add-rich-rule='rule family="ipv4" source address="192.168.1.0/24" service name="ssh" accept'` |
| Block IP              | `sudo firewall-cmd --add-rich-rule='rule family="ipv4" source address="1.2.3.4" reject'`                           |
| Rate limit SSH        | `sudo firewall-cmd --add-rich-rule='rule service name="ssh" limit value="5/m" accept'`                             |
| Log dropped packets   | `sudo firewall-cmd --add-rich-rule='rule log prefix="DROP " level="info" drop'`                                    |

---

# ICMP / Ping Control

| Action           | Command                                              |
| ---------------- | ---------------------------------------------------- |
| List ICMP types  | `sudo firewall-cmd --get-icmptypes`                  |
| Block ping       | `sudo firewall-cmd --add-icmp-block=echo-request`    |
| Unblock ping     | `sudo firewall-cmd --remove-icmp-block=echo-request` |
| Query ICMP block | `sudo firewall-cmd --query-icmp-block=echo-request`  |

---

# Direct Rules (iptables/nft passthrough)

| Action             | Command                                                                                      |
| ------------------ | -------------------------------------------------------------------------------------------- |
| List direct rules  | `sudo firewall-cmd --direct --get-all-rules`                                                 |
| Add direct rule    | `sudo firewall-cmd --direct --add-rule ipv4 filter INPUT 0 -p tcp --dport 8443 -j ACCEPT`    |
| Remove direct rule | `sudo firewall-cmd --direct --remove-rule ipv4 filter INPUT 0 -p tcp --dport 8443 -j ACCEPT` |

---

# Panic Mode

| Action             | Command                           |
| ------------------ | --------------------------------- |
| Enable panic mode  | `sudo firewall-cmd --panic-on`    |
| Disable panic mode | `sudo firewall-cmd --panic-off`   |
| Query panic mode   | `sudo firewall-cmd --query-panic` |

---

# Logging & Diagnostics

| Action                 | Command                                    |
| ---------------------- | ------------------------------------------ |
| Current configuration  | `sudo firewall-cmd --list-all`             |
| All zones              | `sudo firewall-cmd --list-all-zones`       |
| Runtime config         | `sudo firewall-cmd --runtime-to-permanent` |
| Check daemon           | `sudo firewall-cmd --check-config`         |
| Firewalld logs         | `sudo journalctl -u firewalld`             |
| Kernel firewall logs   | `sudo journalctl -k`                       |
| Active listening ports | `sudo ss -tulnp`                           |
| Legacy netstat         | `sudo netstat -tulnp`                      |
| nftables rules         | `sudo nft list ruleset`                    |
| iptables rules         | `sudo iptables -L -n -v`                   |

---

# Common Networking Scenarios

## Web Server

| Requirement   | Command                                             |
| ------------- | --------------------------------------------------- |
| Enable HTTP   | `sudo firewall-cmd --permanent --add-service=http`  |
| Enable HTTPS  | `sudo firewall-cmd --permanent --add-service=https` |
| Apply changes | `sudo firewall-cmd --reload`                        |

---

## SSH Server

| Requirement         | Command                                                                                                            |
| ------------------- | ------------------------------------------------------------------------------------------------------------------ |
| Enable SSH          | `sudo firewall-cmd --permanent --add-service=ssh`                                                                  |
| Restrict SSH subnet | `sudo firewall-cmd --add-rich-rule='rule family="ipv4" source address="192.168.1.0/24" service name="ssh" accept'` |

---

## Printer Sharing

| Requirement           | Command                                            |
| --------------------- | -------------------------------------------------- |
| Enable IPP printers   | `sudo firewall-cmd --permanent --add-service=ipp`  |
| Enable mDNS discovery | `sudo firewall-cmd --permanent --add-service=mdns` |
| Reload firewall       | `sudo firewall-cmd --reload`                       |

---

## Samba File Server

| Requirement  | Command                                             |
| ------------ | --------------------------------------------------- |
| Enable Samba | `sudo firewall-cmd --permanent --add-service=samba` |
| Reload rules | `sudo firewall-cmd --reload`                        |

---

## NFS Server

| Requirement     | Command                                                |
| --------------- | ------------------------------------------------------ |
| Enable NFS      | `sudo firewall-cmd --permanent --add-service=nfs`      |
| Enable mountd   | `sudo firewall-cmd --permanent --add-service=mountd`   |
| Enable rpc-bind | `sudo firewall-cmd --permanent --add-service=rpc-bind` |

---

## Database Exposure

| Database   | Command                                                  |
| ---------- | -------------------------------------------------------- |
| MySQL      | `sudo firewall-cmd --permanent --add-service=mysql`      |
| PostgreSQL | `sudo firewall-cmd --permanent --add-service=postgresql` |
| MongoDB    | `sudo firewall-cmd --permanent --add-port=27017/tcp`     |
| Redis      | `sudo firewall-cmd --permanent --add-port=6379/tcp`      |

---

# Service Enablement via systemctl

| Service       | Enable Command                         | Start Command                         |
| ------------- | -------------------------------------- | ------------------------------------- |
| Apache        | `sudo systemctl enable httpd`          | `sudo systemctl start httpd`          |
| Nginx         | `sudo systemctl enable nginx`          | `sudo systemctl start nginx`          |
| SSH           | `sudo systemctl enable sshd`           | `sudo systemctl start sshd`           |
| Samba         | `sudo systemctl enable smb`            | `sudo systemctl start smb`            |
| CUPS Printing | `sudo systemctl enable cups`           | `sudo systemctl start cups`           |
| MariaDB       | `sudo systemctl enable mariadb`        | `sudo systemctl start mariadb`        |
| PostgreSQL    | `sudo systemctl enable postgresql`     | `sudo systemctl start postgresql`     |
| Cockpit       | `sudo systemctl enable cockpit.socket` | `sudo systemctl start cockpit.socket` |

---

# Useful Inspection Commands

| Purpose                      | Command                 |
| ---------------------------- | ----------------------- |
| Show listening sockets       | `sudo ss -tulnp`        |
| Show established connections | `sudo ss -tunap`        |
| Show routing table           | `ip route`              |
| Show interfaces              | `ip addr`               |
| Test connectivity            | `ping 8.8.8.8`          |
| Trace route                  | `traceroute google.com` |
| DNS lookup                   | `dig google.com`        |
| Open ports scan              | `nmap localhost`        |
| Scan remote ports            | `nmap 192.168.1.10`     |

---

# Common Flags & Verbs Reference

| Flag / Verb              | Meaning                 |
| ------------------------ | ----------------------- |
| `--add-service`          | Enable named service    |
| `--remove-service`       | Disable named service   |
| `--query-service`        | Check service state     |
| `--add-port`             | Open port               |
| `--remove-port`          | Close port              |
| `--query-port`           | Check port              |
| `--permanent`            | Save config permanently |
| `--reload`               | Apply permanent rules   |
| `--zone=`                | Specify firewall zone   |
| `--list-all`             | Display current config  |
| `--list-services`        | Show enabled services   |
| `--list-ports`           | Show open ports         |
| `--runtime-to-permanent` | Persist runtime config  |
| `--panic-on`             | Block all traffic       |
| `--panic-off`            | Restore traffic         |
| `--add-rich-rule`        | Advanced filtering      |
| `--remove-rich-rule`     | Remove advanced rule    |
| `--add-forward-port`     | Forward traffic         |
| `--add-masquerade`       | Enable NAT              |
| `--change-interface`     | Assign NIC to zone      |
| `--add-source`           | Assign subnet to zone   |

---

# Security Best Practices

| Practice                          | Recommendation                    |
| --------------------------------- | --------------------------------- |
| Minimize exposed ports            | Only open required services       |
| Prefer services over raw ports    | Easier management                 |
| Restrict SSH access               | Use rich rules/subnets            |
| Use permanent rules carefully     | Reload after validation           |
| Audit listening ports             | `ss -tulnp` regularly             |
| Use zones properly                | Separate trust levels             |
| Log suspicious traffic            | Rich rules + journald             |
| Avoid exposing databases publicly | Bind internally whenever possible |
| Use HTTPS                         | Encrypt traffic                   |
| Regularly review rules            | Remove stale entries              |

---

# Quick Reference Cheat Sheet

## Open Web Server

```
sudo firewall-cmd --permanent --add-service=httpsudo firewall-cmd --permanent --add-service=httpssudo firewall-cmd --reload
```

---

## Open Custom Port

```
sudo firewall-cmd --permanent --add-port=8080/tcpsudo firewall-cmd --reload
```

---

## Close Port

```
sudo firewall-cmd --permanent --remove-port=8080/tcpsudo firewall-cmd --reload
```

---

## List Everything

```
sudo firewall-cmd --list-allsudo firewall-cmd --list-all-zonessudo ss -tulnp
```

---

## Printer Sharing

```
sudo firewall-cmd --permanent --add-service=ippsudo firewall-cmd --permanent --add-service=mdnssudo firewall-cmd --reload
```

---

## Samba Server

```
sudo firewall-cmd --permanent --add-service=sambasudo firewall-cmd --reload
```

---

## Save Runtime Rules

```
sudo firewall-cmd --runtime-to-permanent
```
