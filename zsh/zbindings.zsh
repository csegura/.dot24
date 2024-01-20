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

# required by syntax hightlighting
zle -N backwards-delete-part

# Improve movements
bindkey "^[^H" 	    backwards-delete-part  # urxvt: Alt+BackSpace
bindkey "^H" 	      backward-delete-char  # C-H: Backspace
bindkey "^[[3^"     delete-word  # urxvt: C-delete
bindkey "^[[3"      delete-word  # urxvt: Alt-delete
bindkey "^[Od" 	    backward-word # urxvt: C-Left
bindkey "^[Oc" 	    forward-word  # urxvt: C-Right
bindkey "^F" 	      forward-word  # urxvt: C-F
bindkey "^B" 	      backward-word # urxvt: C-B

# Go normal mode double ESC
bindkey -rpM viins '^[^['

bindkey -- "^A" beginning-of-line
bindkey -- "^B" backward-char
bindkey -- "^E" end-of-line
bindkey -- "^W" backward-kill-word

# History search 
autoload -U up-line-or-beginning-search
autoload -U down-line-or-beginning-search
zle -N up-line-or-beginning-search
zle -N down-line-or-beginning-search
bindkey "^[[A"      up-line-or-beginning-search # Up
bindkey "^[[B"      down-line-or-beginning-search # Down

# Uncomment if no fzf
#bindkey "^r" 	      history-incremental-search-backward

# Sudo a command
bindkey "^[s"  	    sudo-command-line 

