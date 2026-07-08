# SSH Cheatsheet

SSH (Secure Shell) is used for encrypted remote login, command execution,
tunneling, and secure file transfer.

## Basic Connection

```bash
ssh user@host                        # connect as user
ssh host                              # connect using current username
ssh -p 2222 user@host                 # connect on non-default port
ssh -v user@host                      # verbose output (debugging)
ssh -vvv user@host                    # maximum verbosity
ssh -o StrictHostKeyChecking=no host  # skip host key verification
ssh -6 user@host                      # force IPv6
ssh -4 user@host                      # force IPv4
```

## Running Remote Commands

```bash
ssh user@host "ls -la /var/log"           # run single command
ssh user@host "cd /tmp && ls"             # chain commands remotely
ssh user@host < local_script.sh           # pipe script to remote shell
ssh user@host 'bash -s' < script.sh       # explicit remote bash
ssh user@host "sudo systemctl restart nginx"  # run with sudo remotely
```

## SSH Keys

```bash
ssh-keygen -t ed25519 -C "you@example.com"   # generate ed25519 key (preferred)
ssh-keygen -t rsa -b 4096                     # generate RSA key, 4096 bits
ssh-keygen -t ed25519 -f ~/.ssh/id_deploy     # generate with custom filename
ssh-copy-id user@host                          # copy public key to remote authorized_keys
ssh-copy-id -i ~/.ssh/id_deploy.pub user@host  # copy specific key
cat ~/.ssh/id_ed25519.pub                      # print public key
ssh-keygen -lf ~/.ssh/id_ed25519.pub           # show key fingerprint
ssh-keygen -p -f ~/.ssh/id_ed25519             # change key passphrase
```

## SSH Agent

```bash
eval "$(ssh-agent -s)"              # start ssh-agent
ssh-add ~/.ssh/id_ed25519           # add key to agent
ssh-add -l                           # list loaded keys
ssh-add -D                           # remove all keys from agent
ssh-add -t 3600 ~/.ssh/id_ed25519    # add key with 1-hour timeout
```

## SSH Config File (~/.ssh/config)

```
Host myserver
    HostName 203.0.113.10
    User deploy
    Port 2222
    IdentityFile ~/.ssh/id_deploy
    ForwardAgent yes

Host bastion
    HostName bastion.example.com
    User admin
    IdentityFile ~/.ssh/id_bastion

Host internal
    HostName 10.0.0.5
    User admin
    ProxyJump bastion
```

With this config: `ssh myserver` connects using all specified options.

### Common Config Options

| Option | Purpose |
|---|---|
| `HostName` | Actual address to connect to |
| `User` | Default username |
| `Port` | Non-default SSH port |
| `IdentityFile` | Path to private key |
| `ProxyJump` | Connect through a bastion/jump host |
| `ForwardAgent` | Forward local SSH agent to remote host |
| `ServerAliveInterval` | Keepalive interval in seconds |
| `StrictHostKeyChecking` | Enable/disable host key verification |
| `LocalForward` | Persistent local port forward |

## Port Forwarding / Tunneling

```bash
# Local forward: access remote_port on host via localhost:local_port
ssh -L 8080:localhost:80 user@host

# Local forward to a third machine's port, via host
ssh -L 5432:db.internal:5432 user@bastion

# Remote forward: expose local_port on the remote machine
ssh -R 9000:localhost:3000 user@host

# Dynamic forward (SOCKS proxy)
ssh -D 1080 user@host

# Run tunnel in background without executing a remote command
ssh -f -N -L 8080:localhost:80 user@host
```

## Jump Hosts / Bastions

```bash
ssh -J bastion user@internal-host          # jump through one host
ssh -J bastion1,bastion2 user@internal     # jump through multiple hosts
```

## Copying Files (see also rsync/scp)

```bash
scp file.txt user@host:/remote/path/          # copy file to remote
scp user@host:/remote/file.txt .              # copy file from remote
scp -r dir/ user@host:/remote/path/           # copy directory recursively
scp -P 2222 file.txt user@host:/path/         # non-default port
scp -i ~/.ssh/id_deploy file.txt user@host:/path/  # specific key
```

## SSH Multiplexing (Speed Up Repeated Connections)

Add to `~/.ssh/config`:

```
Host *
    ControlMaster auto
    ControlPath ~/.ssh/sockets/%r@%h-%p
    ControlPersist 600
```

```bash
mkdir -p ~/.ssh/sockets      # required directory for socket files
```

## Host Keys

```bash
ssh-keyscan host >> ~/.ssh/known_hosts       # add host key without connecting
ssh-keygen -R host                            # remove a host's cached key
cat ~/.ssh/known_hosts                        # view known hosts
```

## X11 Forwarding

```bash
ssh -X user@host          # enable X11 forwarding
ssh -Y user@host          # trusted X11 forwarding (less restricted)
```

## Persistent Sessions

```bash
ssh user@host
tmux new -s work           # start a detachable session on the remote host
# detach: Ctrl-b then d
tmux attach -t work        # reattach later
```

Alternative: `screen -S work` / `screen -r work`.

## Useful Flags Summary

| Flag | Purpose |
|---|---|
| `-p PORT` | Specify port |
| `-i FILE` | Specify identity (private key) file |
| `-L` | Local port forward |
| `-R` | Remote port forward |
| `-D` | Dynamic SOCKS proxy |
| `-J` | Jump host |
| `-N` | Do not execute remote command (tunnel only) |
| `-f` | Background after auth |
| `-C` | Enable compression |
| `-o Option=value` | Set arbitrary config option |
| `-q` | Quiet mode |
| `-A` | Forward agent |

## Server-Side Configuration (/etc/ssh/sshd_config)

```
Port 22
PermitRootLogin no
PasswordAuthentication no
PubkeyAuthentication yes
AllowUsers deploy admin
MaxAuthTries 3
ClientAliveInterval 300
ClientAliveCountMax 2
```

```bash
sudo systemctl restart sshd       # apply sshd config changes
sudo sshd -t                      # test config syntax before restarting
```

## Troubleshooting

```bash
ssh -v user@host                        # see handshake and auth steps
ssh -o BatchMode=yes user@host echo ok  # test non-interactive auth (for scripts)
ssh -T git@github.com                   # test auth without shell (git-style)
chmod 600 ~/.ssh/id_ed25519             # private key must not be group/world readable
chmod 700 ~/.ssh                        # ssh directory permissions
```

Common causes of failure: wrong key permissions, wrong username, firewall
blocking the port, `authorized_keys` not writable by the correct user, or a
stale `known_hosts` entry after a server rebuild.
