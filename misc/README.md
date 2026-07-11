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
