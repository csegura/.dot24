# 2025 Config files

Minimal dotfiles setup — zsh, vim, tmux, fzf — with as few third-party tools as possible.

## zsh

### Functions / Aliases

```
Navigation
  reload        Reload zshrc
  d             dirs -v
  1-9           cd +N (directory stack)
  cz            Zoxide fzf jumper
  proj          Project jumper (~/prj)
  fm            fzf file manager (Ctrl+E to launch as widget)

Files
  l             ls -al
  ls            ls -Fh
  ll            ls -GFhl
  lh            ls -d .* (hidden only)
  lsd           ls -aFhlG
  lt            Files modified today
  ltd           Files & dirs modified today
  lnew          Three newest files
  lso           ls with octal permissions
  fd            fdfind
  bat           batcat with colors
  vf            vim $(fzf --multi)

Info
  ips           Private IPs
  ipp           Public IP
  openports     lsof TCP listeners
  opp           netstat -tulanp
  hf            Heavy files (top 15)
  cpu           CPU usage %
  mem           Memory usage %
  inspect       Process info by PID or name

Git
  gs            git status -sb
  gl            git log (graph, short)
  gdiff         git diff with batcat
  gwt           Worktree switcher (fzf)
  gwta          Worktree add (fzf branch)
  gwtd          Worktree remove (fzf)
  glog          fzf commit log (copies hash)
  gbr           fzf branch switcher
  ggrep TERM    fzf search commits by content
  gconflict     fzf conflict file opener

Git aliases (git config)
  Staging
    addm          Fuzzy add modified files
    addmp         Fuzzy add modified files (patch)
    ia            Fuzzy add modified/untracked

  Browsing
    cb            Fuzzy checkout branch
    cs            Fuzzy apply stash
    is            Fuzzy show commit
    lg            Graph log (aligned columns)
    today         Today's commits
    yesterday     Yesterday's commits

  Editing
    edit          Fuzzy edit modified files
    ie            Fuzzy edit modified/untracked
    id            Fuzzy diff modified/untracked

  Cleanup
    db / Db       Fuzzy delete branch (safe / force)
    dm            Delete merged branches
    ds            Fuzzy delete stash
    resetm        Fuzzy unstage files

  Workflow
    append        Amend last commit (all changes)
    fixup         Fuzzy fixup commit
    frb           Fetch + rebase on default branch
    main          Checkout origin/main
    undo          Soft reset last commit

Processes
  killport N    Kill process on port N
  kport [N]     fzf kill by port (ss)
  fkill         fzf kill any process
  showlog N     Tail log of process on port N

Network
  fssh          fzf SSH/SCP history

Docker
  dk            docker
  dkc           docker compose
  dkps          docker ps (formatted)
  dklog         docker logs -f
  dksh          docker exec -it

Tools
  vman          Man pages in vim
  btail         tail -f with batcat
  pmount        Partition mount (fzf)
  man           fzf man page browser (no args)
  lcolors       Show terminal colors
  timer         Toggle command timer in RPROMPT
  top           btop

System
  dpkglist      Installed packages
  dpkgsearch    Search packages
  installed     dpkg -l installed
  wiki          DNS TXT lookup (wp.dg.cx)
  o             wsl open (cmd.exe /c start)
```

### Keyboard (vi-mode)

```
History
  Ctrl+P        Previous history match
  Ctrl+N        Next history match

Movement (insert mode)
  Home          beginning-of-line
  End           end-of-line
  Insert        overwrite-mode
  Backspace     backward-delete-char
  Delete        delete-char
  Up/Down       up/down-line-or-history
  Left/Right    backward/forward-char
  PageUp        beginning-of-buffer-or-history
  PageDown      end-of-buffer-or-history
  Shift-Tab     reverse-menu-complete
  Ctrl+Left     backward-word
  Ctrl+Right    forward-word

Editing
  Alt+Backspace backwards-delete-part
  Ctrl+H        backward-delete-char
  Ctrl+Delete   delete-word
  Alt+Delete    delete-word
  Ctrl+U        backward-kill-line
  Ctrl+K        kill-line
  Ctrl+F        forward-word
  Ctrl+B        backward-word

Widgets
  Ctrl+E        fm-widget (file manager)
  Alt+S         sudo prefix

Menu select (completion)
  h j k l       Navigate completion menu
```

### Fzf (fdfind / batcat)

```
Shell bindings
  **<Tab>       Expansion
  Ctrl+T        Files
  Ctrl+R        History
  Alt+C         Directory nav

FZF_DEFAULT_OPTS bindings
  ?             Toggle preview
  Ctrl+A        Select all
  Ctrl+Y        Copy to clipboard (xclip)
  Ctrl+E        Open in vim
  Ctrl+V        Open in code
```

### tmux

```
Prefix: Ctrl+A

Windows
  c             New window
  t / T         Next / previous window
  space         Next window
  bspace        Previous window
  n             Rename window

Panes
  s             Split horizontal
  v             Split vertical
  enter         Split horizontal (also next-layout)
  h j k l       Select pane
  a             Last pane
  q             Display panes
  C-o           Rotate windows

Layouts
  /             main-horizontal
  =             main-vertical
  *             tiled

Resize (repeatable)
  <             Resize left
  >             Resize right
  -             Resize down
  +             Resize up

No prefix
  Alt+Arrows    Select pane

Session
  R             Reload config
  X             Kill session (confirm)
  L             Clear history

Copy mode
  [             Enter copy mode
  ]             Paste buffer
  v             Begin selection (copy-mode-vi)
  y             Copy to clipboard (copy-mode-vi)
```

## Vim (custom bindings)

```
Leader: ,

Splits / Navigation
  ,v            Vertical split
  ,h            Horizontal split
  C-h/j/k/l    Navigate splits
  gn            Buffer next
  gp            Buffer previous
  gd            Buffer delete

Navigation concepts
  Ctrl+O        Jump back (after gf, searches, etc.)
  Ctrl+I        Jump forward
  gn / gp / gd  Buffer next / prev / delete (custom)
  C-h/j/k/l    Navigate splits (custom)
  gt / gT       Next / prev tab (built-in)
  :ls           List buffers
  :tabe file    Open file in new tab

Vimrc
  ,ev           Edit vimrc (new tab)
  ,V            Reload vimrc

Editing
  jj            Escape (insert mode)
  A-Up / A-Down Move line up/down (normal)
  C-j / C-k     Move line up/down (insert/visual)
  F2            Paste toggle
  _$            Strip trailing whitespace
  _=            Reindent file

Search
  ,/            Clear search highlight
  ,i            Toggle listchars

Fzf (fzf.vim)
  ,f            Files
  ,b            Buffers
  ,rg           Ripgrep search
  ,gc           Git commits
  ,gf           Git changed files
  ,l            Buffer lines

Run
  ,r            Run interactive shell command
  ,o            Run line under cursor

Completion
  Tab           Smart complete (insert tab or C-p)
  S-Tab         Next completion (C-n)

Command
  :Sw           Save as sudo
```

## Utils

```
monitor.sh    laptopon laptopoff external all
```
