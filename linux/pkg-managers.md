# Package Managers Cheatsheet: apt, dnf/yum, pacman, rpm

Side-by-side reference for the major Linux package managers, organized by
task so you can translate a command from one distro family to another.

## Distro Families

| Family | Distros | Package Manager | Low-level Tool |
|---|---|---|---|
| Debian-based | Debian, Ubuntu, Mint | `apt` / `apt-get` | `dpkg` |
| Red Hat-based | Fedora, RHEL, CentOS, Rocky | `dnf` (or `yum`) | `rpm` |
| Arch-based | Arch, Manjaro, EndeavourOS | `pacman` | — |

## Installing Packages

```bash
# apt (Debian/Ubuntu)
sudo apt install package
sudo apt install package1 package2

# dnf (Fedora/RHEL)
sudo dnf install package
sudo dnf install package1 package2

# pacman (Arch)
sudo pacman -S package
sudo pacman -S package1 package2
```

## Removing Packages

```bash
# apt
sudo apt remove package             # remove package, keep config files
sudo apt purge package              # remove package AND config files
sudo apt autoremove                 # remove unused dependencies

# dnf
sudo dnf remove package
sudo dnf autoremove

# pacman
sudo pacman -R package              # remove package
sudo pacman -Rs package             # remove package + unneeded deps
sudo pacman -Rns package            # remove package, deps, and config files
```

## Updating System / Packages

```bash
# apt
sudo apt update                     # refresh package index
sudo apt upgrade                    # upgrade all installed packages
sudo apt full-upgrade                # upgrade, allowing package removal if needed
sudo apt update && sudo apt upgrade -y   # common combo

# dnf
sudo dnf check-update                # check for available updates
sudo dnf upgrade                      # upgrade all packages
sudo dnf update                       # alias for upgrade in modern dnf

# pacman
sudo pacman -Sy                       # refresh package database only (avoid using alone)
sudo pacman -Syu                       # sync + full system upgrade (standard usage)
```

> **Arch tip:** never run `pacman -Sy package` (partial upgrade) — it can
> break dependency resolution. Always sync and upgrade together with `-Syu`.

## Searching for Packages

```bash
# apt
apt search keyword
apt-cache search keyword          # older/alternate

# dnf
dnf search keyword
dnf provides */filename            # find package providing a specific file

# pacman
pacman -Ss keyword                  # search repositories
pacman -Qs keyword                  # search installed packages
```

## Package Information

```bash
# apt
apt show package
dpkg -s package                      # installed package status
dpkg -L package                      # list files installed by package

# dnf / rpm
dnf info package
rpm -qi package                       # query installed package info
rpm -ql package                       # list files installed by package
rpm -qf /path/to/file                  # which package owns this file

# pacman
pacman -Si package                     # info from repo
pacman -Qi package                     # info for installed package
pacman -Ql package                     # list files installed by package
pacman -Qo /path/to/file                # which package owns this file
```

## Listing Installed Packages

```bash
# apt
apt list --installed
dpkg -l

# dnf / rpm
dnf list installed
rpm -qa

# pacman
pacman -Q                              # all installed packages
pacman -Qe                             # explicitly installed (not deps)
pacman -Qm                             # foreign/AUR packages
```

## Cleaning Up

```bash
# apt
sudo apt clean                       # clear downloaded package cache
sudo apt autoclean                   # clear only outdated cached packages
sudo apt autoremove                  # remove unused dependencies

# dnf
sudo dnf clean all
sudo dnf autoremove

# pacman
sudo pacman -Sc                       # clear cache of uninstalled package versions
sudo pacman -Scc                      # clear entire cache
sudo pacman -Qdt                       # list orphaned packages
sudo pacman -Rns $(pacman -Qdtq)       # remove all orphaned packages
```

## Installing Local Package Files

```bash
# apt (.deb)
sudo dpkg -i package.deb
sudo apt install -f                   # fix missing dependencies after dpkg -i

# dnf (.rpm)
sudo dnf install ./package.rpm
sudo rpm -ivh package.rpm             # low-level install

# pacman (.pkg.tar.zst)
sudo pacman -U package.pkg.tar.zst
```

## RPM Deep Dive

```bash
rpm -qa                              # list all installed packages
rpm -qi package                      # detailed info
rpm -ql package                      # files owned by package
rpm -qf /path/to/file                # find owning package
rpm -qpi package.rpm                 # info about an rpm file before installing
rpm -qpl package.rpm                 # list files inside an rpm file
rpm -ivh package.rpm                 # install, verbose, show hash progress
rpm -Uvh package.rpm                 # upgrade
rpm -e package                       # erase (remove)
rpm -V package                       # verify installed files against package db
rpm --rebuilddb                      # rebuild the rpm database
```

## Repository Management

```bash
# apt: repos live in /etc/apt/sources.list and /etc/apt/sources.list.d/
sudo add-apt-repository ppa:someppa/ppa
sudo apt update

# dnf: repos live in /etc/yum.repos.d/*.repo
sudo dnf config-manager --add-repo https://example.com/repo.repo
sudo dnf config-manager --set-enabled reponame

# pacman: repos configured in /etc/pacman.conf
# AUR requires a helper like yay or paru (not part of pacman itself)
yay -S package          # example AUR helper syntax
```

## Holding / Pinning Packages (Preventing Upgrades)

```bash
# apt
sudo apt-mark hold package
sudo apt-mark unhold package
apt-mark showhold

# dnf
sudo dnf versionlock add package
sudo dnf versionlock delete package

# pacman
# add to IgnorePkg in /etc/pacman.conf
# IgnorePkg = package
```

## Downgrading Packages

```bash
# apt
sudo apt install package=1.2.3-1

# dnf
sudo dnf downgrade package

# pacman
sudo pacman -U /var/cache/pacman/pkg/package-1.2.3-1-x86_64.pkg.tar.zst
```

## Dependency Queries

```bash
# apt
apt-cache depends package
apt-cache rdepends package          # what depends on this package

# dnf
dnf repoquery --requires package
dnf repoquery --whatrequires package

# pacman
pacman -Qi package | grep "Depends"
pacman -Qi package | grep "Required By"
```

## Command Cross-Reference Table

| Task | apt | dnf | pacman |
|---|---|---|---|
| Install | `apt install pkg` | `dnf install pkg` | `pacman -S pkg` |
| Remove | `apt remove pkg` | `dnf remove pkg` | `pacman -R pkg` |
| Update index | `apt update` | `dnf check-update` | `pacman -Sy` |
| Upgrade all | `apt upgrade` | `dnf upgrade` | `pacman -Syu` |
| Search | `apt search kw` | `dnf search kw` | `pacman -Ss kw` |
| Info | `apt show pkg` | `dnf info pkg` | `pacman -Si pkg` |
| List installed | `dpkg -l` | `rpm -qa` | `pacman -Q` |
| Files in package | `dpkg -L pkg` | `rpm -ql pkg` | `pacman -Ql pkg` |
| Owning package of file | `dpkg -S file` | `rpm -qf file` | `pacman -Qo file` |
| Clean cache | `apt clean` | `dnf clean all` | `pacman -Sc` |
| Install local file | `dpkg -i pkg.deb` | `rpm -ivh pkg.rpm` | `pacman -U pkg.pkg.tar.zst` |

## Snap and Flatpak (Cross-Distro)

```bash
# Snap
sudo snap install package
sudo snap remove package
snap list
sudo snap refresh

# Flatpak
flatpak install flathub org.example.App
flatpak run org.example.App
flatpak list
flatpak update
flatpak uninstall org.example.App
```

## Tips

- Always run the "refresh index" step (`apt update`, `dnf check-update`,
  `pacman -Sy` only as part of `-Syu`) before installing on a system that
  hasn't been touched recently.
- On Arch, avoid partial upgrades; sync and upgrade together.
- `rpm` and `dpkg` are the low-level tools underneath `dnf`/`yum` and `apt`
  respectively — use them for inspection, not routine installs.
- Use `apt-mark hold` / `dnf versionlock` / `IgnorePkg` to pin critical
  packages (e.g. kernel, database engines) during upgrades.
