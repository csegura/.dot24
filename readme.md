# 2024 Config files

It's time to reorganise my .dotfiles to keep a clean and functional configuration by using as few third party tools as possible. The goal is to have a neat and clean configuration as possible.

## zsh

Historial (vi insert)
- `ctrl-p` Prev entry from history
- `ctrl-n` Next entry from history

Movement (vi insert)
- `Home` beginning-of-line
- `End` end-of-line
- `Insert` overwrite-mode
- `Backspace` backward-delete-char
- `Delete` delete-char
- `Up` up-line-or-history
- `Down` down-line-or-history
- `Left` backward-char
- `Right` forward-char
- `PageUp` beginning-of-buffer-or-history
- `PageDown` end-of-buffer-or-history
- `Shift-Tab` reverse-menu-complete
- `CRTLL` backward-word
- `CRTLR` forward-word

- `Alt-Backspace` backwards-delete-part
- `Ctrl-H` backward-delete-char
- `delete` delete-word
- `alt-delete` delete-word  
- `Ctrl-U` backward-kill-line
- `Ctrl-Left` backward-word
- `Ctrl-Right` forward-word

# Fzf (use fdfind / bat[cat])

- `**` expansion
- `Ctrl-T` Files
- `Ctrl-R` History
- `Alt-C` Directory nav

## tmux

- Prefix **Ctrl-a**
- R         reload config
- s         split horizontal
- v         split vertical
- hjkl      select-pane
- o         rotate windows
- +         main-horizontal
- =         main-vertical

# Resize

- Prefix + Ctrl + ArrowKeys

## i3wm

# Resize

bindsym $mod+Ctrl+Shift+Right resize shrink width 10 px or 10 ppt
bindsym $mod+Ctrl+Shift+Up resize grow height 10 px or 10 ppt
bindsym $mod+Ctrl+Shift+Down resize shrink height 10 px or 10 ppt
bindsym $mod+Ctrl+Shift+Left resize grow width 10 px or 10 ppt
