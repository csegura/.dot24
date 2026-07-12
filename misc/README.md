# ~/.dotfiles/misc

Miscellaneous scripts, tools and reference notes.

---

## Scripts

### `backup/backup.sh` — Incremental rsync backup

Backs up local directories to a remote server via rsync, creating
space-efficient incremental snapshots with `--link-dest` (unchanged files
are hard-linked from the previous snapshot).

**Remote layout:**
```
~/usb/bak_acr/
  backup-home/
    2026-07-11T12:00:00/   ← timestamped snapshot
    current -> ...         ← symlink to latest
  backup-prj/
    ...
```

**Usage:**
```bash
backup.sh               # run backup
backup.sh -n            # dry-run (preview only, no transfer)
backup.sh -v            # verbose rsync output
```

**Setup on a new machine:**
```bash
mkdir -p ~/.config/backup
cp ~/.dotfiles/misc/backup/backup.conf.example ~/.config/backup/backup.conf
# Edit SOURCES and SSH_KEY for this machine
```

**Config search order:** `~/.config/backup/backup.conf` → `<script_dir>/backup.conf`

| Config key | Default | Description |
|---|---|---|
| `SSH_KEY` | `~/.ssh/nikita` | SSH key for remote |
| `REMOTE` | `romheat@nikita` | Remote host |
| `DEST_BASE` | `~/usb/bak_acr` | Base path on remote |
| `KEEP_SNAPSHOTS` | `30` | Number of snapshots to retain per source |
| `SOURCES` | *(required)* | Array of `"dest_name:local_path"` pairs |

**Features:** lock file (no concurrent runs), SSH connectivity check,
timestamped logs in `~/.local/share/backup-logs/`, per-source timing,
failure summary.

---

### `backup/server-backup.sh` — Local incremental system backup

Backs up local system paths to the mounted backup disk (`/srv/backups`) using
rsync `--link-dest` snapshots. Destination folders are named `$(hostname)-<name>`
so the same script works on any machine without config changes.

**Usage:**
```bash
sbak run              # run backup now
sbak run -n           # dry-run (preview only)
sbak run -v           # verbose rsync output
sbak enable           # install + enable systemd timer (uses sudo internally)
sbak disable          # disable timer (uses sudo internally)
sbak status           # timer state, last snapshot dates, disk usage
sbak list             # list all snapshots per source
```

**Setup on a new machine:**
```bash
cp ~/.dotfiles/misc/backup/server-backup.conf.example \
   ~/.config/backup/server-backup.conf
# Edit SOURCES, DEST_BASE, SCHEDULE as needed
sbak enable
```

**Snapshot layout:**
```
/srv/backups/
  adal-etc/
    2026-07-12T03:00:00/   ← timestamped snapshot
    current -> ...         ← symlink to latest
  adal-projects/
  adal-config/
  adal-dotfiles/
```

| Config key | Default | Description |
|---|---|---|
| `DEST_BASE` | `/srv/backups` | Backup disk mount point |
| `KEEP_SNAPSHOTS` | `30` | Snapshots to retain per source |
| `SCHEDULE` | `03:00` | Daily timer time (HH:MM) |
| `SOURCES` | *(required)* | Array of `"name:path"` pairs |

**Features:** lock file (no concurrent runs), rsync exit-23/24 treated as
warning (unreadable files), automatic snapshot pruning, systemd timer with
`Persistent=true` (catches up missed runs after downtime).

---

### `nfs/nfs_share.sh` — NFS export manager

Creates, removes and lists NFS exports under `/mnt/`. Auto-detects current
user for ownership. Uses `exportfs -ra` instead of full service restart.

**Usage:**
```bash
sudo nfs_share.sh add videos        # create /mnt/videos and export it
sudo nfs_share.sh add               # interactive prompt
sudo nfs_share.sh remove videos     # remove export (directory kept)
sudo nfs_share.sh list              # show current exports
```

**NFS export options applied:**
```
*(rw,all_squash,insecure,async,no_subtree_check,anonuid=<uid>,anongid=<gid>)
```

**Features:** root check, duplicate export detection (prompts to replace),
UID/GID auto-detected from current user, input validation (no `..`, no
absolute paths), non-interactive mode via argument.

---

## Reference

### `cheats.md`

Linux cheatsheet covering: networking, wifi, NFS/NTFS/CDROM mounts, vim
(movement, buffers, splits, folds, diffs), serial ports, Wireguard,
sysctl, sudo config, package management and more.

### `i3_config.sh`

Helper script for applying i3 window manager configuration.

### `.config/i3/` and `.config/i3status/`

i3 and i3status configuration files.

### `.dircolors`

Custom `ls` color scheme.

---

## req.sh

Located at `~/.dotfiles/req.sh` — run this on any new machine to bootstrap
the full environment:

```bash
bash ~/.dotfiles/req.sh
```

Installs: `zsh`, `zsh-autosuggestions`, `zsh-syntax-highlighting`,
`fd-find`, `fzf` (from git, apt version too old), `vim`, `bat`, `wget`,
`zoxide`, `git`, `tmux`, `curl`, `jq`, `unzip`, `rgrc`, `btop`.

Also: symlinks dotfiles, sets zsh as default shell, scaffolds
`~/.config/backup/backup.conf` from the example template.

---

### `energy/energy-setup.sh` — Headless server energy saving

Installs and configures TLP for a headless server. Run once on a new machine:

```bash
sudo ~/.dotfiles/misc/energy/energy-setup.sh
```

**What it does:**
- Installs TLP and deploys `tlp-server.conf`
- CPU governor → `powersave`, turbo boost disabled
- Disk APM level 128 (spindown allowed), SATA link → `med_power_with_dipm`
- PCIe ASPM → `powersupersave`
- Wake-on-LAN disabled (use Tailscale instead)
- Bluetooth disabled
- USB autosuspend enabled

Tune `energy/tlp-server.conf` for your specific disk names and spindown timeouts.
