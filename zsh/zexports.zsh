# Exports
export CLICOLOR=1
if [[ -z "$TMUX" ]]; then
  export TERM=xterm-256color
else
  export TERM=screen-256color
fi
export LESS="--ignore-case --raw-control-chars"
export EDITOR="vim"
export ZDOTDIR=~/.dotfiles/zsh
export SHELL=/usr/bin/zsh

# man
export MANPAGER="sh -c 'col -bx | batcat -l man -p'"
export MANROFFOPT="-c"

# options
export GREP_COLORS='ms=01;34:mc=01;34:sl=:cx=:fn=35:ln=32:bn=32:se=36'

# fzf
export FZF_DEFAULT_COMMAND="fdfind \
--strip-cwd-prefix \
--hidden \
--follow \
--exclude .venv \
--exclude .git \
--exclude node_modules \
"

export FZF_CTRL_T_COMMAND="fdfind \
--strip-cwd-prefix \
--hidden \
--follow \
--exclude .venv \
--exclude .git \
--exclude node_modules \
. $1 \
"

export FZF_ALT_C_COMMAND="fdfind \
-t d \
--strip-cwd-prefix \
--hidden \
--follow \
--exclude .venv \
--exclude .git \
--exclude node_modules \
. $1 \
"
export FZF_DEFAULT_OPTS=" \
  --ansi \
  --layout=reverse \
  --info=inline \
  --height=80% \
  --preview 'batcat --style=numbers --color=always --line-range :500 {}' \
  --color='hl:148,hl+:154,pointer:032,marker:010,bg+:237,gutter:008' \
  --prompt='∼ ' \
  --pointer='▶' \
  --marker='✓' \
  --bind '?:toggle-preview' \
  --bind 'ctrl-a:select-all' \
  --bind 'ctrl-y:execute-silent(echo {+} | xclip -selection clipboard)' \
  --bind 'shift-up:preview-half-page-up' \
  --bind 'shift-down:preview-half-page-down'"

export FZF_CTRL_T_OPTS="--ansi --preview 'batcat -n --color=always {}' --bind '?:toggle-preview' --bind 'ctrl-v:execute(code {+})' --bind 'ctrl-e:execute(echo {+} | xargs -o vim)'"
export FZF_CTRL_R_OPTS="--no-preview"

export BAT_THEME="Visual Studio Dark+"

export PAGER="less -SXR"

# nnn
export NNN_OPTS="cdesx"
export BMS="h:~;d:~/Documents;D:~/Downloads;l:~/dev_local;p:~/prj"
export NNN_PLUG='j:autojump;p:preview-tui;l:!git log;d:!git diff;f:fzcd;o:fzopen;P:mocq;t:nmount;v:imgview'
export NNN_FIFO=/tmp/nnn.fifo
