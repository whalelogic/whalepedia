### Linux Command Reference

> 200+ commands across 12 categories. Format: `command` — description — example

---

## File System

|Command|Description|Example|
|---|---|---|
|`ls`|List directory contents|`ls -lah /home`|
|`cd`|Change the current directory|`cd /var/log`|
|`pwd`|Print working directory path|`pwd`|
|`mkdir`|Create directories|`mkdir -p /tmp/a/b/c`|
|`rmdir`|Remove empty directories|`rmdir olddir`|
|`rm`|Remove files or directories|`rm -rf /tmp/junk`|
|`cp`|Copy files or directories|`cp -r src/ dest/`|
|`mv`|Move or rename files|`mv old.txt new.txt`|
|`touch`|Create empty file or update timestamp|`touch newfile.txt`|
|`ln`|Create hard or symbolic links|`ln -s /etc/nginx nginx`|
|`readlink`|Print resolved symlink target|`readlink -f /etc/alternatives/python`|
|`stat`|Display file or filesystem status|`stat /etc/passwd`|
|`file`|Determine file type|`file unknown.bin`|
|`tree`|List contents of directory in tree format|`tree -L 3 /etc`|
|`xattr`|Display and manipulate extended file attributes|`xattr -l file.txt`|
|`inotifywait`|Wait for filesystem events|`inotifywait -m -r /var/www`|

---

## Search

|Command|Description|Example|
|---|---|---|
|`find`|Search for files in a directory hierarchy|`find / -name '*.log' -mtime -7`|
|`locate`|Find files by name using a database|`locate nginx.conf`|
|`which`|Show full path of a shell command|`which python3`|
|`whereis`|Locate binary, source, and man pages|`whereis bash`|
|`grep`|Search text using patterns|`grep -rn 'error' /var/log/`|
|`egrep`|Extended grep with regex support|`egrep '(foo\|bar)' file`|

---

## Text Processing

|Command|Description|Example|
|---|---|---|
|`cat`|Concatenate and display file contents|`cat /etc/hosts`|
|`less`|View file contents one page at a time|`less /var/log/syslog`|
|`more`|View file contents with forward navigation|`more /etc/fstab`|
|`head`|Output the first lines of a file|`head -n 20 file.txt`|
|`tail`|Output the last lines of a file|`tail -f /var/log/nginx/access.log`|
|`sed`|Stream editor for filtering and transforming text|`sed 's/foo/bar/g' file.txt`|
|`awk`|Pattern scanning and text processing language|`awk '{print $1}' access.log`|
|`sort`|Sort lines of text|`sort -k2 -n data.txt`|
|`uniq`|Report or filter out repeated lines|`sort file \| uniq -c`|
|`wc`|Print line, word, and byte counts|`wc -l /etc/passwd`|
|`cut`|Remove sections from each line of files|`cut -d: -f1 /etc/passwd`|
|`paste`|Merge lines of files side by side|`paste file1 file2`|
|`tr`|Translate or delete characters|`echo 'hello' \| tr a-z A-Z`|
|`diff`|Compare files line by line|`diff old.txt new.txt`|
|`patch`|Apply a diff file to an original|`patch < changes.patch`|
|`split`|Split a file into pieces|`split -b 50M huge.iso part_`|
|`join`|Join lines of two files on a common field|`join file1 file2`|
|`nl`|Number lines of files|`nl -ba script.sh`|
|`od`|Dump files in octal and other formats|`od -A x -t x1z file.bin`|
|`xxd`|Make a hex dump of a file|`xxd binary.bin \| head`|
|`strings`|Print printable strings in a binary file|`strings /usr/bin/ls`|
|`column`|Format stdin or file in columns|`column -t -s',' data.csv`|
|`fmt`|Reformat paragraph text|`fmt -w 72 essay.txt`|
|`fold`|Wrap each input line to fit a specified width|`fold -w 80 longline.txt`|
|`iconv`|Convert text from one encoding to another|`iconv -f latin1 -t utf8 f.txt`|

---

## Permissions

|Command|Description|Example|
|---|---|---|
|`chmod`|Change file mode bits|`chmod 755 script.sh`|
|`chown`|Change file owner and group|`chown www-data:www-data /var/www`|
|`chgrp`|Change group ownership|`chgrp developers project/`|
|`umask`|Set default file permission mask|`umask 022`|
|`lsattr`|List file attributes on ext filesystem|`lsattr /etc/shadow`|
|`chattr`|Change file attributes on ext filesystem|`chattr +i /etc/resolv.conf`|
|`getfacl`|Get file access control lists|`getfacl /var/www/html`|
|`setfacl`|Set file access control lists|`setfacl -m u:alice:rwx dir/`|

---

## Process Management

| Command   | Description                                      | Example                          |
| --------- | ------------------------------------------------ | -------------------------------- |
| `ps`      | Report a snapshot of running processes           | `ps aux \| grep nginx`           |
| `top`     | Dynamic real-time view of running processes      | `top -u www-data`                |
| `htop`    | Interactive process viewer (enhanced top)        | `htop`                           |
| `kill`    | Send a signal to a process                       | `kill -9 1234`                   |
| `killall` | Kill processes by name                           | `killall -HUP nginx`             |
| `pkill`   | Signal processes by name or attribute            | `pkill -u alice`                 |
| `pgrep`   | Find process IDs by name                         | `pgrep -a nginx`                 |
| `jobs`    | List active jobs in the current shell            | `jobs -l`                        |
| `bg`      | Resume a suspended job in the background         | `bg %1`                          |
| `fg`      | Bring a background job to the foreground         | `fg %2`                          |
| `nohup`   | Run a command immune to hangups                  | `nohup ./server.py &`            |
| `nice`    | Run a command with modified scheduling priority  | `nice -n 10 make`                |
| `renice`  | Alter priority of a running process              | `renice -n 5 -p 1234`            |
| `strace`  | Trace system calls and signals                   | `strace -p 1234`                 |
| `lsof`    | List open files and sockets                      | `lsof -i :80`                    |
| `watch`   | Execute a program periodically                   | `watch -n 2 free -h`             |
| `at`      | Schedule a one-time command                      | `echo 'reboot' \| at 03:00`      |
| `crontab` | Manage per-user cron jobs                        | `crontab -l`                     |
| `fuser`   | Identify processes using files or sockets        | `fuser -v /var/log/nginx`        |
| `pstree`  | Display a tree of processes                      | `pstree -p`                      |
| `pidstat` | Report statistics for Linux processes            | `pidstat -d 1 5`                 |
| `taskset` | Set or retrieve a process's CPU affinity         | `taskset -c 0,1 myprogram`       |
| `ionice`  | Set or get the I/O scheduling class and priority | `ionice -c 3 rsync -a /src /dst` |

---

## Network

|Command|Description|Example|
|---|---|---|
|`ssh`|OpenSSH remote login client|`ssh -i ~/.ssh/id_rsa user@host`|
|`ssh-keygen`|Generate SSH key pairs|`ssh-keygen -t ed25519 -C 'me@example.com'`|
|`ssh-copy-id`|Copy public key to a remote host|`ssh-copy-id user@host`|
|`scp`|Secure copy files between hosts over SSH|`scp file.txt user@host:/tmp/`|
|`sftp`|Secure file transfer over SSH|`sftp user@host`|
|`curl`|Transfer data from or to a server|`curl -o file.zip https://example.com/f.zip`|
|`wget`|Non-interactive network downloader|`wget -r https://example.com`|
|`ping`|Send ICMP ECHO_REQUEST to network hosts|`ping -c 4 8.8.8.8`|
|`traceroute`|Trace the route packets take to a host|`traceroute google.com`|
|`mtr`|Network diagnostic combining ping and traceroute|`mtr --report google.com`|
|`dig`|DNS lookup utility|`dig +short MX gmail.com`|
|`nslookup`|Query DNS interactively or non-interactively|`nslookup example.com 1.1.1.1`|
|`host`|DNS lookup utility (simpler)|`host -t A example.com`|
|`netstat`|Print network connections and statistics|`netstat -tulnp`|
|`ss`|Investigate sockets (modern netstat)|`ss -tulnp`|
|`ip`|Show and manipulate routing, devices, policy|`ip addr show eth0`|
|`ifconfig`|Configure network interface (legacy)|`ifconfig eth0 up`|
|`route`|Show or manipulate the IP routing table|`route -n`|
|`iptables`|Administer IPv4 packet filter rules|`iptables -L -n -v`|
|`nft`|Administer nftables firewall framework|`nft list ruleset`|
|`ufw`|Uncomplicated Firewall management tool|`ufw allow 443/tcp`|
|`tcpdump`|Dump network traffic on an interface|`tcpdump -i eth0 port 80`|
|`nmap`|Network exploration and security scanner|`nmap -sV -p 1-65535 host`|
|`nc`|Netcat — TCP/UDP networking Swiss army knife|`nc -lvp 4444`|
|`ftp`|File Transfer Protocol client|`ftp ftp.example.com`|

---

## System Info

|Command|Description|Example|
|---|---|---|
|`uname`|Print system information|`uname -a`|
|`hostname`|Show or set system hostname|`hostname -f`|
|`uptime`|Show how long the system has been running|`uptime`|
|`date`|Display or set the system date and time|`date '+%Y-%m-%d %H:%M:%S'`|
|`timedatectl`|Control system time and date via systemd|`timedatectl set-timezone UTC`|
|`dmesg`|Print kernel ring buffer messages|`dmesg \| tail -20`|
|`lspci`|List PCI devices|`lspci -v`|
|`lsusb`|List USB devices|`lsusb`|
|`lscpu`|Display CPU architecture information|`lscpu`|
|`lsmem`|Show memory layout of the system|`lsmem`|
|`free`|Display amount of free and used memory|`free -h`|
|`vmstat`|Report virtual memory statistics|`vmstat 1 5`|
|`iostat`|Report CPU and I/O statistics|`iostat -xz 1`|
|`sar`|Collect and report system activity|`sar -u 1 5`|
|`mpstat`|Report individual CPU statistics|`mpstat -P ALL 1 3`|
|`ldd`|Print shared library dependencies|`ldd /usr/bin/nginx`|
|`ldconfig`|Configure dynamic linker run-time bindings|`ldconfig -p \| grep libssl`|
|`lsmod`|Show the status of kernel modules|`lsmod \| grep ext4`|
|`modprobe`|Add or remove modules from the Linux kernel|`modprobe nf_conntrack`|
|`insmod`|Insert a module into the Linux kernel|`insmod mymodule.ko`|
|`rmmod`|Remove a module from the Linux kernel|`rmmod mymodule`|
|`sysctl`|Configure kernel parameters at runtime|`sysctl -w net.ipv4.ip_forward=1`|
|`ulimit`|Control resource limits for processes|`ulimit -n 65535`|
|`chroot`|Run command in a new root directory|`chroot /mnt/rescue /bin/bash`|
|`nsenter`|Run a program in specified namespaces|`nsenter -t 1234 -n`|
|`unshare`|Run a program with some namespaces unshared|`unshare --pid --fork bash`|
|`perf`|Linux performance analysis tool|`perf stat ls -la /`|
|`gdb`|GNU debugger for programs|`gdb ./program core`|
|`valgrind`|Memory debugging and profiling tool|`valgrind --leak-check=full ./prog`|
|`objdump`|Display information from object files|`objdump -d /usr/bin/ls \| head -40`|
|`nm`|List symbols from object files|`nm /usr/lib/libssl.a \| head`|
|`numactl`|Control NUMA policy for processes|`numactl --hardware`|
|`shutdown`|Shutdown or restart the system|`shutdown -r now`|
|`reboot`|Reboot the system|`reboot`|
|`halt`|Halt the system|`halt`|
|`systemctl`|Control systemd services and units|`systemctl restart nginx`|
|`journalctl`|Query the systemd journal|`journalctl -u nginx -f`|
|`service`|Run a SysV init script|`service apache2 status`|

---

## Disk

|Command|Description|Example|
|---|---|---|
|`df`|Report filesystem disk space usage|`df -h`|
|`du`|Estimate file space usage|`du -sh /var/*`|
|`mount`|Mount a filesystem|`mount /dev/sdb1 /mnt/usb`|
|`umount`|Unmount a filesystem|`umount /mnt/usb`|
|`fdisk`|Partition table manipulator|`fdisk -l /dev/sda`|
|`parted`|Partition manipulation program|`parted /dev/sda print`|
|`lsblk`|List block devices|`lsblk -f`|
|`blkid`|Locate and print block device attributes|`blkid /dev/sda1`|
|`mkfs`|Build a Linux filesystem|`mkfs.ext4 /dev/sdb1`|
|`fsck`|Check and repair a filesystem|`fsck -y /dev/sda1`|
|`dd`|Convert and copy files at the block level|`dd if=/dev/sda of=/backup.img bs=4M`|
|`sync`|Flush filesystem buffers to disk|`sync`|
|`swapon`|Enable devices and files for paging/swapping|`swapon -a`|
|`swapoff`|Disable devices and files for paging/swapping|`swapoff /swapfile`|
|`hdparm`|Set/get SATA/IDE hard disk drive parameters|`hdparm -Tt /dev/sda`|
|`smartctl`|Control and monitor storage with SMART|`smartctl -a /dev/sda`|

---

## Archive & Transfer

|Command|Description|Example|
|---|---|---|
|`tar`|Archive files (tape archiver)|`tar -czvf backup.tar.gz /etc`|
|`gzip`|Compress or expand files with gzip|`gzip largefile.log`|
|`gunzip`|Decompress gzip files|`gunzip archive.gz`|
|`bzip2`|Compress files with bzip2|`bzip2 -k file.txt`|
|`xz`|Compress files with xz (LZMA2)|`xz -9 bigfile`|
|`zip`|Package and compress files into zip archive|`zip -r project.zip src/`|
|`unzip`|Extract files from a zip archive|`unzip archive.zip -d /tmp/`|
|`7z`|High-compression archive utility|`7z a -mx9 out.7z dir/`|
|`rsync`|Fast, versatile remote/local file-copying tool|`rsync -avz src/ user@host:/dest/`|
|`ar`|Create, modify, and extract from archives|`ar rcs libfoo.a foo.o`|
|`cpio`|Copy files to/from archives|`find . \| cpio -o > archive.cpio`|

---

## Shell & Scripting

|Command|Description|Example|
|---|---|---|
|`echo`|Display a line of text|`echo $HOME`|
|`printf`|Format and print text|`printf '%s\n' hello world`|
|`read`|Read a line from stdin into a variable|`read -p 'Name: ' name`|
|`export`|Set environment variables for child processes|`export PATH=$PATH:/usr/local/bin`|
|`env`|Print or set environment variables|`env \| grep PATH`|
|`alias`|Create a shortcut for a command|`alias ll='ls -alh'`|
|`source`|Execute commands from a file in current shell|`source ~/.bashrc`|
|`history`|Show command history|`history \| grep ssh`|
|`man`|Display the manual page for a command|`man grep`|
|`info`|Read documentation in info format|`info coreutils`|
|`help`|Display help for shell builtins|`help cd`|
|`type`|Describe how a name is interpreted by the shell|`type ls`|
|`tee`|Read stdin and write to stdout and files|`ls \| tee output.txt`|
|`xargs`|Build and execute commands from stdin|`find . -name '*.tmp' \| xargs rm`|
|`bc`|Arbitrary precision calculator language|`echo '2^32' \| bc`|
|`expr`|Evaluate expressions|`expr 5 + 3 \* 2`|
|`test`|Evaluate conditional expressions|`test -f /etc/passwd && echo yes`|
|`sleep`|Suspend execution for an interval|`sleep 5`|
|`time`|Time a command's execution|`time find / -name '*.log'`|
|`timeout`|Run a command with a time limit|`timeout 10s ping google.com`|
|`yes`|Output a string repeatedly until killed|`yes \| apt-get install nginx`|
|`seq`|Print a sequence of numbers|`seq 1 2 20`|
|`shuf`|Generate random permutations|`shuf -n 5 wordlist.txt`|
|`tput`|Initialize terminal or query terminfo database|`tput cols`|
|`stty`|Change and print terminal line settings|`stty -a`|
|`clear`|Clear the terminal screen|`clear`|
|`reset`|Reset the terminal to a sane state|`reset`|
|`script`|Make a typescript of a terminal session|`script session.log`|
|`screen`|Terminal window manager (multiplexer)|`screen -S mysession`|
|`tmux`|Terminal multiplexer with sessions and panes|`tmux new -s work`|
|`make`|Build automation tool|`make -j$(nproc) install`|
|`gcc`|GNU C compiler|`gcc -O2 -o prog main.c`|
|`basename`|Strip directory and suffix from filenames|`basename /usr/bin/ls`|
|`dirname`|Strip last component from a file name|`dirname /usr/bin/ls`|
|`realpath`|Print the resolved absolute file path|`realpath ../config.yaml`|
|`mktemp`|Create a temporary file or directory|`mktemp /tmp/tmpXXXXXX`|
|`true`|Return a successful exit status|`true`|
|`false`|Return an unsuccessful exit status|`false \| echo 'failed'`|

---

## Package Management

|Command|Description|Example|
|---|---|---|
|`apt`|High-level package manager for Debian/Ubuntu|`apt install -y nginx`|
|`apt-get`|Low-level package manager for Debian/Ubuntu|`apt-get upgrade`|
|`dpkg`|Debian package manager (low-level)|`dpkg -i package.deb`|
|`yum`|Package manager for RHEL/CentOS (legacy)|`yum install httpd`|
|`dnf`|Package manager for Fedora/RHEL 8+|`dnf update --refresh`|
|`rpm`|RPM package manager (low-level)|`rpm -qa \| grep nginx`|
|`snap`|Install and manage snap packages|`snap install code --classic`|
|`flatpak`|Install and manage Flatpak apps|`flatpak install flathub org.gimp.GIMP`|
|`pip`|Python package installer|`pip install requests --break-system-packages`|
|`npm`|Node.js package manager|`npm install -g prettier`|

---

## User Management

|Command|Description|Example|
|---|---|---|
|`useradd`|Create a new user account|`useradd -m -s /bin/bash alice`|
|`userdel`|Delete a user account|`userdel -r bob`|
|`usermod`|Modify a user account|`usermod -aG sudo alice`|
|`groupadd`|Create a new group|`groupadd developers`|
|`groupdel`|Delete a group|`groupdel oldgroup`|
|`groupmod`|Modify a group definition|`groupmod -n newname oldname`|
|`passwd`|Change a user's password|`passwd alice`|
|`su`|Switch user identity|`su - root`|
|`sudo`|Execute a command as another user|`sudo systemctl restart sshd`|
|`visudo`|Safely edit the sudoers file|`visudo`|
|`id`|Print real and effective user and group IDs|`id alice`|
|`who`|Show who is logged in|`who -a`|
|`w`|Show who is logged in and what they are doing|`w`|
|`last`|Show listing of last logged-in users|`last -n 20`|
|`finger`|Look up information about system users|`finger alice`|

---

_Generated June 2026 — 200+ commands across 12 categories._