
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
# batcat
alias bat='batcat --color=always --style=numbers'
#alias -g -- -h='-h 2>&1 | batcat --language=help --style=plain'
alias -g -- --help='--help 2>&1 | batcat --language=help --style=plain'

# Force tmux to use 256 colors
alias tmux='TERM=screen-256color-bce tmux'

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

# Edit files with vim
alias vf='vim -O $(fzf --multi)'

# network local ips/public ip/open ports
alias ips="ip addr show |egrep 'inet '| awk '{print $2 \" \" $NF}'" 
alias ipp="curl -s http://whatismyip.akamai.com/"

# system info
alias cpu="awk -v OFMT='%5.3g' '\$1 == \"cpu\" { print( \"Used Cpu: \", 100*(\$2+\$4)/(\$2+\$4+\$5),\"%\" ) }' /proc/stat"
alias mem="free | grep Mem | awk '{print(\"Used Mem:\", \$3/\$2 * 100.0,\"%\")}'"
alias opp="netstat -tulanp"

# misc
alias wiki='dig +short txt $1.wp.dg.cx'

# git
alias gs="git status -sb"
alias gl='git log --date=short --format="%C(green)%C(bold)%cd %C(auto)%h%d %s (%an)" --graph --color=always'

