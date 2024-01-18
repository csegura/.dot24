# Exports
export CLICOLOR=1
export LSCOLORS=Gxfxcxdxbxegedabagacad
export TERM=xterm-256color
export LESS="--ignore-case --raw-control-chars"
export PAGER="less"

# fzf
export FZF_DEFAULT_OPTS='--no-height --no-reverse'
# Using highlight (http://www.andre-simon.de/doku/highlight/en/highlight.html)
export FZF_CTRL_T_OPTS="--preview '(highlight -O ansi -l {} 2> /dev/null || cat {} || tree -C {}) 2> /dev/null | head -200'"
export FZF_CTRL_R_OPTS='--no-sort --exact'
export FZF_CTRL_R_OPTS="--preview 'echo {}' --preview-window down:3:hidden:wrap --bind '?:toggle-preview'"

