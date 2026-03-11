if (( $+commands[rgrc] )); then
    eval "$(rgrc --aliases)"
    f_fc() { rgrc "$@"; }
else
    f_fc() { "$@"; }
fi

# The following lines were added by compinstall
alias reload="source ~/.zshrc"

alias lh='f_fc ls -d .* --color' # show hidden files/directories only
alias lsd='f_fc ls -aFhlG --color'
alias l='f_fc ls -al --color'
alias ls='f_fc ls -Fh --color' # Colorize output, add file type indicator, and put sizes in human readable format
alias ll='f_fc ls -GFhl --color' # Same as above, but in long listing format
# modified and new
alias ltd='f_fc ls *(m0)' # files & directories modified in last day
alias lt='f_fc ls *(.m0)' # files (no directories) modified in last day
alias lnew='f_fc ls *(.om[1,3])' # list three newest

# Information
# heavy files
alias hf='f_fc du -cks * | sort -rn | head -15' 
# open ports
alias openports='f_fc lsof -iTCP -sTCP:LISTEN -P'

# fdfind
alias fd='fdfind'
# batcat
alias bat='batcat --color=always --style=numbers'
#alias -g -- -h='-h 2>&1 | batcat --language=help --style=plain'
alias -g -- --help='--help 2>&1 | batcat --language=help --style=plain'

# Force tmux to use 256 colors
alias tmux='TERM=screen-256color-bce tmux'

# History grep
alias grep='grep --color=auto'
alias hg='history | grep'

# alias for navigation
alias d="dirs -v"
for index ({1..9}) alias "$index"="cd +${index}"; unset index

# alias commands
alias rm='rm -i'
alias mv='mv -i'
alias cp='cp -i'
alias df='f_fc df -h'

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

# colors
alias showcolors='for x in {0..8}; do for i in {30..37}; do for a in {40..47}; do echo -ne "\e[$x;$i;$a""m\\\e[$x;$i;$a""m\e[0;37;40m "; done; echo; done; done; echo ""'

# wsl
alias o="cmd.exe /c start"

# docker
alias dk='docker'
alias dkc='docker compose'
alias dkps='docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"'
alias dklog='docker logs -f'
alias dksh='docker exec -it'

# btop
alias top='btop'

# dpkg
alias dpkglist='dpkg --get-selections | grep -v deinstall'
alias dpkgsearch='dpkg --get-selections | grep -i'  
alias installed='dpkg -l | grep ^ii'

