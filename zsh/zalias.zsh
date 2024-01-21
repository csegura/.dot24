
# The following lines were added by compinstall
alias reload="source ~/.zshrc"

alias lh='ls -d .* --color' # show hidden files/directories only
alias lsd='ls -aFhlG --color'
alias l='ls -al --color'
alias ls='ls -Fh --color' # Colorize output, add file type indicator, and put sizes in human readable format
alias ll='ls -GFhl --color' # Same as above, but in long listing format
# modified and new
alias ltd='ls *(m0)' # files & directories modified in last day
alias lt='ls *(.m0)' # files (no directories) modified in last day
alias lnew='ls *(.om[1,3])' # list three newest

# Information
# heavy files
alias hf='du -cks * | sort -rn | head -15' 
# open ports
alias openports='lsof -iTCP -sTCP:LISTEN -P'


# fdfind
alias fd='fdfind'
# bat
alias bat='batcat'

# History grep
alias hg='history | grep'

# alias for navigation
alias d="dirs -v"
for index ({1..9}) alias "$index"="cd +${index}"; unset index

# alias commands
alias rm='rm -i'
alias mv='mv -i'
alias cp='cp -i'
alias df='df -h'

# fzf
ifzf-history-widget-accept() {
  fzf-history-widget
  zle accept-line
}
zle     -N     fzf-history-widget-accept
bindkey '^X^R' fzf-history-widget-accept

# network
alias ips="ip addr show |egrep 'inet '| awk '{print $2 \" \" $NF}'" 
alias ipp="curl -s http://whatismyip.akamai.com/"

# misc
alias wiki='dig +short txt $1.wp.dg.cx'
