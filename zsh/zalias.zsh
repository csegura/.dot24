
# The following lines were added by compinstall
alias reload="source ~/.zshrc"

alias lh='ls -d .* --color' # show hidden files/directories only
alias lsd='ls -aFhlG --color'
alias l='ls -al --color'
alias ls='ls -Fh --color' # Colorize output, add file type indicator, and put sizes in human readable format
alias ll='ls -GFhl --color' # Same as above, but in long listing format

alias hg='history | grep'

# alias for navigation
alias d="dirs -v"
for index ({1..9}) alias "$index"="cd +${index}"; unset index

# alias commands
alias rm='rm -i'
alias mv='mv -i'
alias cp='cp -i'

# fzf
ifzf-history-widget-accept() {
  fzf-history-widget
  zle accept-line
}
zle     -N     fzf-history-widget-accept
bindkey '^X^R' fzf-history-widget-accept

