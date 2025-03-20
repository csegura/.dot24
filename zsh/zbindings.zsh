# Keyboard vi-mode
bindkey -v
export KEYTIMEOUT=1

# setup key accordingly
[[ -n "${key[Home]}"      ]] && bindkey -- "${key[Home]}"       beginning-of-line
[[ -n "${key[End]}"       ]] && bindkey -- "${key[End]}"        end-of-line
[[ -n "${key[Insert]}"    ]] && bindkey -- "${key[Insert]}"     overwrite-mode
[[ -n "${key[Backspace]}" ]] && bindkey -- "${key[Backspace]}"  backward-delete-char
[[ -n "${key[Delete]}"    ]] && bindkey -- "${key[Delete]}"     delete-char
[[ -n "${key[Up]}"        ]] && bindkey -- "${key[Up]}"         up-line-or-history
[[ -n "${key[Down]}"      ]] && bindkey -- "${key[Down]}"       down-line-or-history
[[ -n "${key[Left]}"      ]] && bindkey -- "${key[Left]}"       backward-char
[[ -n "${key[Right]}"     ]] && bindkey -- "${key[Right]}"      forward-char
[[ -n "${key[PageUp]}"    ]] && bindkey -- "${key[PageUp]}"     beginning-of-buffer-or-history
[[ -n "${key[PageDown]}"  ]] && bindkey -- "${key[PageDown]}"   end-of-buffer-or-history
[[ -n "${key[Shift-Tab]}" ]] && bindkey -- "${key[Shift-Tab]}"  reverse-menu-complete
[[ -n "${key[CRTLL]}"     ]] && bindkey -- "${key[CRTLL]}"      backward-word
[[ -n "${key[CRTLR]}"     ]] && bindkey -- "${key[CRTLR]}"      forward-word

bindkey "\e[7~" beginning-of-line
bindkey "\e[8~" end-of-line

# required by syntax hightlighting
zle -N backwards-delete-part

# Improve delete movements
bindkey "^[^H" 	    backwards-delete-part  # urxvt: Alt+BackSpace
bindkey "^H" 	      backward-delete-char  # C-H: Backspace
bindkey "^[[3^"     delete-word  # urxvt: C-delete
bindkey "^[[3"      delete-word  # urxvt: Alt-delete
bindkey '^U'        backward-kill-line
bindkey '^K'        kill-line
# Ctrl -> Ctrl <-
# others
bindkey "^F" 	      forward-word
bindkey "^B" 	      backward-word
# term (ssh)
bindkey "^[[1;5D"   backward-word
bindkey "^[[1;5C"   forward-word
# others urxvt
bindkey "^[Od"	    backward-word
bindkey "^[Oc"	    forward-word

# History search 
autoload -U    up-line-or-beginning-search
autoload -U    down-line-or-beginning-search
zle -N         up-line-or-beginning-search
zle -N         down-line-or-beginning-search
bindkey "^p"   up-line-or-beginning-search 
bindkey "^n"   down-line-or-beginning-search 
#bindkey "^[[A"      up-line-or-beginning-search # Up
#bindkey "^[[B"      down-line-or-beginning-search # Down

# Movements for compinit
bindkey -M menuselect 'h' vi-backward-char
bindkey -M menuselect 'k' vi-up-line-or-history
bindkey -M menuselect 'j' vi-down-line-or-history
bindkey -M menuselect 'l' vi-forward-char

# Uncomment if no fzf
#bindkey "^r" 	      history-incremental-search-backward

# Sudo a command
bindkey "^[s"  	    sudo-command-line 

