
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
