# Rsync Cheatsheet

`rsync` synchronizes files and directories efficiently by transferring only
the differences between source and destination.

## Basic Syntax

```bash
rsync [options] source destination
```

Trailing slash on the source matters:

```bash
rsync -av dir/ /dest/     # copies CONTENTS of dir into /dest/
rsync -av dir  /dest/     # copies dir ITSELF into /dest/dir
```

## Common Flags

| Flag | Meaning |
|---|---|
| `-a` | Archive mode (recursive, preserves permissions, times, symlinks, etc.) |
| `-v` | Verbose |
| `-vv` | Extra verbose |
| `-z` | Compress data during transfer |
| `-h` | Human-readable sizes |
| `-P` | Show progress + allow resuming partial transfers |
| `-r` | Recursive (implied by `-a`) |
| `-n` | Dry run (show what would happen, no changes) |
| `-u` | Skip files newer on destination |
| `--delete` | Delete files on destination not present in source |
| `-e` | Specify remote shell (e.g. ssh) |
| `-p` | Preserve permissions |
| `-t` | Preserve modification times |
| `-l` | Preserve symlinks |
| `-g` | Preserve group |
| `-o` | Preserve owner (requires root) |

## Local Sync

```bash
rsync -av source/ dest/                  # sync directory contents
rsync -av --delete source/ dest/         # mirror exactly (deletes extras)
rsync -avn source/ dest/                 # dry run, see what would change
```

## Remote Sync over SSH

```bash
rsync -avz -e ssh source/ user@host:/remote/path/
rsync -avz -e "ssh -p 2222" source/ user@host:/remote/path/
rsync -avz source/ user@host:/remote/path/      # ssh is default remote shell
rsync -avz user@host:/remote/path/ local/       # pull from remote to local
```

## Progress and Resuming

```bash
rsync -avP source/ dest/                 # show per-file progress, allow resume
rsync -avz --partial --progress source/ user@host:/dest/
rsync --append-verify -avz bigfile user@host:/dest/  # resume partial large file
```

## Excluding Files

```bash
rsync -av --exclude '*.log' source/ dest/
rsync -av --exclude '*.log' --exclude '*.tmp' source/ dest/
rsync -av --exclude-from='exclude-list.txt' source/ dest/
rsync -av --include='*.txt' --exclude='*' source/ dest/   # only .txt files
```

Example `exclude-list.txt`:

```
*.log
*.tmp
node_modules/
.git/
```

## Deletion and Mirroring

```bash
rsync -av --delete source/ dest/            # exact mirror
rsync -av --delete --dry-run source/ dest/  # preview deletions first
rsync -av --delete-excluded --exclude '*.tmp' source/ dest/  # also delete excluded files at dest
```

## Backup Instead of Overwrite

```bash
rsync -av --backup --backup-dir=/backups/$(date +%F) source/ dest/
rsync -av --suffix=.bak --backup source/ dest/
```

## Bandwidth and Performance

```bash
rsync -avz --bwlimit=1000 source/ user@host:/dest/    # limit to 1000 KB/s
rsync -av --whole-file source/ dest/                   # skip delta-transfer (fast on local disks)
rsync -avz --compress-level=9 source/ user@host:/dest/ # max compression
```

## Filtering by Size / Time

```bash
rsync -av --max-size=100M source/ dest/       # skip files over 100MB
rsync -av --min-size=1K source/ dest/          # skip tiny files
rsync -av --modify-window=1 source/ dest/      # tolerate 1-second time differences (FAT filesystems)
```

## Checksums and Verification

```bash
rsync -avc source/ dest/          # use checksums instead of mtime+size to detect changes
rsync -avz --dry-run --itemize-changes source/ dest/   # detailed change summary
```

### itemize-changes Output Codes

```
>f.st...... file.txt     # file transferred, size+time differ
.d..t...... dir/         # directory, only time differs
*deleting   old.txt      # file will be deleted
```

## Common Combos

```bash
# Standard remote backup
rsync -avz --delete -e ssh /local/www/ user@host:/var/www/

# Safe dry run before a destructive mirror
rsync -avn --delete source/ dest/

# Sync excluding VCS and dependency directories
rsync -av --exclude '.git' --exclude 'node_modules' src/ dest/

# Copy preserving hard links
rsync -avH source/ dest/

# Sync only newer files
rsync -avu source/ dest/
```

## Rsync Daemon Mode

```bash
rsync --daemon --config=/etc/rsyncd.conf     # start rsync as a daemon
rsync -av rsync://host/module/ dest/          # sync from an rsync daemon module
```

Example `/etc/rsyncd.conf`:

```
[backup]
    path = /srv/backup
    read only = yes
    comment = Backup share
```

## Excluding via .rsync-filter

```bash
rsync -av --filter=':- .gitignore' source/ dest/   # honor .gitignore-style rules
```

## Useful One-Liners

```bash
# Copy only files changed in the last day
rsync -av --files-from=<(find . -mtime -1 -type f) . dest/

# Sync two directories both ways is NOT native; use unison or two rsync passes carefully
rsync -av dirA/ dirB/
rsync -avu dirB/ dirA/

# Test connectivity and permissions without transferring
rsync -avn --stats source/ user@host:/dest/

# Show a transfer summary
rsync -av --stats source/ dest/
```

## Exit Codes

| Code | Meaning |
|---|---|
| 0 | Success |
| 1 | Syntax or usage error |
| 11 | Error in file I/O |
| 12 | Error in rsync protocol data stream |
| 23 | Partial transfer due to error |
| 24 | Partial transfer due to vanished source files |
| 30 | Timeout in data send/receive |

## Tips

- Always test destructive operations (`--delete`) with `-n` (dry run) first.
- Trailing slashes on the *source* change behavior; be deliberate about them.
- Use `-z` for slow networks, skip it on fast LANs or already-compressed data.
- `-P` is shorthand for `--partial --progress`, ideal for large or flaky transfers.
- Combine `--exclude` with `--delete` carefully; excluded files are normally left alone unless `--delete-excluded` is set.
