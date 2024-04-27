# Exports
export CLICOLOR=1
export LSCOLORS=Gxfxcxdxbxegedabagacad
export TERM=xterm-256color
export TERM=screen-256color
export LESS="--ignore-case --raw-control-chars"
export PAGER="less"
export EDITOR="vim"
export ZDOTDIR=~/.dotfiles/zsh
export SHELL=/usr/bin/zsh

# options
export GREP_OPTIONS="--color=always"
export GREP_COLORS='ms=01;34:mc=01;34:sl=:cx=:fn=35:ln=32:bn=32:se=36'

# fzf
export FZF_CTRL_T_COMMAND="fdfind \
--strip-cwd-prefix \
--hidden \
--follow \
--exclude .git \
--exclude node_modules \
. $1 \
"
export FZF_ALT_C_COMMAND="fdfind \
-t d \
--strip-cwd-prefix \
--hidden \
--follow \
--exclude .git \
--exclude node_modules \
. $1 \
"

export FZF_DEFAULT_OPTS="--layout=reverse --info=inline --height=80% --preview 'batcat --style=numbers --color=always --line-range :500 {}' --color='hl:148,hl+:154,pointer:032,marker:010,bg+:237,gutter:008' --prompt='∼ ' --pointer='▶' --marker='✓' --bind '?:toggle-preview' --bind 'ctrl-a:select-all' --bind 'ctrl-y:execute-silent(echo {+} | pbcopy)' --bind 'ctrl-e:execute(echo {+} | xargs -o vim)' --bind 'ctrl-v:execute(code {+})'"

export FZF_CTRL_T_OPTS="--preview 'batcat -n --color=always {}' --bind '?:toggle-preview' "

export BAT_THEME="Visual Studio Dark+"

