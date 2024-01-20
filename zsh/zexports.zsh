# Exports
export CLICOLOR=1
export LSCOLORS=Gxfxcxdxbxegedabagacad
export TERM=xterm-256color
export LESS="--ignore-case --raw-control-chars"
export PAGER="less"

# fzf
export FZF_COMPLETION_TRIGGER='**'
export FZF_DEFAULT_COMMAND='fdfind --type f --strip-cwd-prefix --hidden --follow --exclude .git --exclude node_modules'
export FZF_DEFAULT_OPTS="--layout=reverse --info=inline --height=80%"

# --multi --preview-window=:hidden \
#--preview '([[ -f {} ]] && (bat --style=numbers --color=always {} || cat {})) || ([[ -d {} ]] && (tree -C {} | less)) || echo {} 2> /dev/null | head -200' \
#--color='hl:148,hl+:154,pointer:032,marker:010,bg+:237,gutter:008' \
#--prompt='∼ ' --pointer='▶' --marker='✓' \
#--bind '?:toggle-preview' \
#--bind 'ctrl-a:select-all' \
#--bind 'ctrl-y:execute-silent(echo {+} | pbcopy)' \
#--bind 'ctrl-e:execute(echo {+} | xargs -o vim)' \
#--bind 'ctrl-v:execute(code {+})' \
#"
# Using highlight (http://www.andre-simon.de/doku/highlight/en/highlight.html)
#export FZF_CTRL_T_OPTS="--preview '(highlight -O ansi -l {} 2> /dev/null || cat {} || tree -C {}) 2> /dev/null | head -200'"
#export FZF_CTRL_R_OPTS='--no-sort --exact'
#export FZF_CTRL_R_OPTS="--preview 'echo {}' --preview-window down:3:hidden:wrap --bind '?:toggle-preview'"

