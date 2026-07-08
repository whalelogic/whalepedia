# Linux Built-in Commands Cheatsheet

Core commands every Linux user relies on daily: filesystem navigation, text
processing, process management, permissions, and system inspection.

## Navigation and Filesystem

```bash
pwd                     # print working directory
cd /path/to/dir         # change directory
cd -                    # go to previous directory
cd ~                    # go to home directory
ls -la                  # list all files, long format
ls -lh                  # human-readable sizes
ls -lt                  # sort by modification time
ls -lS                  # sort by size
tree -L 2               # show directory tree, 2 levels deep
find / -name "*.log"    # find files by name
find . -type f -mtime -7 # files modified in last 7 days
find . -type d -empty   # empty directories
find . -size +100M      # files larger than 100MB
```

## File Operations

```bash
cp file1 file2                # copy file
cp -r dir1 dir2                # copy directory recursively
cp -a src dst                  # archive copy (preserves attributes)
mv old new                     # move/rename
rm file                        # remove file
rm -rf dir                     # remove directory recursively, force
mkdir -p a/b/c                 # create nested directories
rmdir dir                      # remove empty directory
touch file                     # create empty file / update timestamp
ln -s target linkname          # create symbolic link
ln target linkname             # create hard link
stat file                      # detailed file metadata
file file                      # detect file type
readlink -f symlink            # resolve symlink to absolute path
```

## Viewing File Contents

```bash
cat file                       # print entire file
cat -n file                    # print with line numbers
tac file                       # print file in reverse
less file                      # paginated viewer (q to quit)
more file                      # simpler pager
head file                      # first 10 lines
head -n 20 file                # first 20 lines
tail file                      # last 10 lines
tail -n 50 file                # last 50 lines
tail -f file                   # follow file as it grows (logs)
tail -F file                   # follow, re-attach if file rotates
wc -l file                     # count lines
wc -w file                     # count words
wc -c file                     # count bytes
```

## Text Processing

```bash
grep "pattern" file                 # search for pattern
grep -i "pattern" file              # case-insensitive
grep -r "pattern" dir/              # recursive search
grep -v "pattern" file              # invert match (exclude)
grep -n "pattern" file              # show line numbers
grep -c "pattern" file              # count matches
grep -E "pat1|pat2" file            # extended regex (OR)
grep -A 3 -B 3 "pattern" file       # 3 lines after/before match
sed 's/foo/bar/' file               # replace first occurrence per line
sed 's/foo/bar/g' file              # replace all occurrences
sed -i 's/foo/bar/g' file           # edit file in place
sed -n '5,10p' file                 # print lines 5-10
sed '/pattern/d' file               # delete matching lines
sort file                           # sort lines alphabetically
sort -n file                        # numeric sort
sort -r file                        # reverse sort
sort -k2 file                       # sort by 2nd field
sort -u file                        # sort and remove duplicates
uniq file                           # remove adjacent duplicate lines
uniq -c file                        # count occurrences
cut -d',' -f1,3 file                # extract fields 1 and 3 (CSV)
cut -c1-10 file                     # extract characters 1-10
tr 'a-z' 'A-Z' < file               # translate lowercase to uppercase
tr -d '\n' < file                   # delete newlines
paste file1 file2                   # merge lines side by side
diff file1 file2                    # show differences
diff -u file1 file2                 # unified diff format
```

## Permissions and Ownership

```bash
chmod 755 file                 # rwxr-xr-x
chmod +x script.sh             # add execute permission
chmod -R 644 dir/              # recursive permission change
chown user:group file          # change owner and group
chown -R user dir/             # recursive ownership change
chgrp group file                # change group only
umask                           # show default permission mask
umask 022                       # set default permission mask
```

### Permission Reference

| Symbol | Octal | Meaning |
|---|---|---|
| `r` | 4 | Read |
| `w` | 2 | Write |
| `x` | 1 | Execute |
| `rwx` | 7 | All |
| `rw-` | 6 | Read + write |
| `r-x` | 5 | Read + execute |

## Process Management

```bash
ps aux                          # list all running processes
ps -ef                          # alternate format
top                             # live process viewer
htop                            # improved interactive process viewer
kill PID                        # terminate process (SIGTERM)
kill -9 PID                     # force kill (SIGKILL)
killall processname             # kill by name
pkill -f "pattern"              # kill by matching command line
jobs                            # list background jobs
bg                               # resume job in background
fg                                # bring job to foreground
nohup command &                  # run immune to hangups
disown                            # detach job from shell
nice -n 10 command                 # run with lower priority
renice -n 5 -p PID                  # change priority of running process
```

## System Information

```bash
uname -a                        # kernel and system info
hostname                        # show hostname
uptime                          # system uptime and load average
free -h                         # memory usage, human-readable
df -h                           # disk space usage
du -sh dir/                     # directory size summary
du -sh * | sort -h              # size of each item, sorted
lscpu                           # CPU information
lsblk                           # list block devices
mount                           # show mounted filesystems
who                              # logged in users
w                                # who + what they're doing
last                             # login history
whoami                           # current user
id                                # user and group IDs
```

## Networking

```bash
ip a                             # show network interfaces
ip route                         # show routing table
ping host                        # test connectivity
curl -I https://example.com      # fetch HTTP headers
netstat -tulpn                   # listening ports (older systems)
ss -tulpn                        # listening ports (modern replacement)
dig example.com                  # DNS lookup
nslookup example.com             # DNS lookup, alternate tool
traceroute host                  # trace network path
hostname -I                      # local IP addresses
```

## Archiving and Compression

```bash
tar -cvf archive.tar dir/            # create tar archive
tar -xvf archive.tar                 # extract tar archive
tar -czvf archive.tar.gz dir/        # create gzip-compressed archive
tar -xzvf archive.tar.gz             # extract gzip archive
tar -cjvf archive.tar.bz2 dir/       # create bzip2 archive
tar -tvf archive.tar                 # list contents without extracting
zip -r archive.zip dir/              # create zip archive
unzip archive.zip                    # extract zip archive
gzip file                             # compress single file
gunzip file.gz                        # decompress
```

## Environment and Shell

```bash
echo $PATH                       # show PATH variable
export VAR=value                 # set environment variable
env                                # list all environment variables
alias ll='ls -la'                  # create alias
unalias ll                          # remove alias
which command                       # show path to executable
type command                        # show how shell interprets command
history                              # show command history
!!                                    # rerun last command
!123                                  # rerun history item 123
source ~/.bashrc                     # reload shell config
```

## Searching and Locating

```bash
locate filename                  # fast file search (needs updatedb)
updatedb                          # update locate database
whereis command                    # locate binary, source, man page
find / -perm -4000                 # find setuid files
```

## Disk and Filesystem

```bash
fdisk -l                          # list disk partitions
mkfs.ext4 /dev/sdX1                # format partition
mount /dev/sdX1 /mnt               # mount a filesystem
umount /mnt                         # unmount
fsck /dev/sdX1                      # check filesystem
```

## Useful Combos

```bash
ps aux | grep nginx                          # find process by name
du -sh * | sort -rh | head -10               # top 10 largest items
find . -name "*.tmp" -delete                 # delete matching files
history | grep ssh                            # find past ssh commands
cat /etc/passwd | cut -d: -f1                # list all usernames
df -h | awk '$5+0 > 80 {print}'              # partitions over 80% full
```
