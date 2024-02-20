
# load file
function load_file() {
    [ -f "$1" ] && source "$1"
}

# Insert sudo at begining
# Alt+s or ESC, s: inserts "sudo " at the start of line:
function sudo-command-line() {
    [[ -z $BUFFER ]] && zle up-history
    [[ $BUFFER != sudo\ * ]] && BUFFER="sudo $BUFFER"
    zle end-of-line
}
zle -N sudo-command-line

# Change cursor shape in vi mode
zle-keymap-select () {
    if [[ $KEYMAP == vicmd ]]; then
        # the command mode for vi
        echo -ne "\e[5 q"
    else
        # the insert mode for vi
        echo -ne "\e[2 q"
    fi
}

precmd_functions+=(zle-keymap-select)
zle -N zle-keymap-select
echo -ne "\e[2 q"

# Read man pages with VIM
function vman() { 
  man $* | col -b | vim -c 'set ft=man nomod nolist' -; 
}

# Git diff with batcat
function gdiff() {
   git diff --name-only --relative --diff-filter=d $* | xargs batcat --diff
}
# Bat Tail 
function btail() {
  tail -f $* | batcat --paging=never -l log
}

# Partition mount
function pmount() { 
  sudo mount -o loop,offset=$(($(sudo fdisk -lu "$1" | sed -n '/^Device|Dispositiv/,/^$/p' | tail -n+2 | fzf | sed -E -e 's/[[:blank:]]+/ /g' | cut -d' ' -f2- | sed 's@^[^0-9]*\([0-9]\+\).*@\1@') * 512)) "$1" "$2"; 
}


