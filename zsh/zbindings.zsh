
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
# Fix Ctrl Left/Right
#bindkey "^[Od" backward-word
#bindkey "^[Oc" forward-word
#bindkey "^[[1;5D" backward-word
#bindkey "^[[1;5C" forward-word

# required by syntax hightlighting
zle -N backwards-delete-part

bindkey "^[^H" 	    backwards-delete-part  # urxvt: Alt+BackSpace
bindkey "^H" 	      backward-delete-char  # C-H: Backspace
bindkey "^[[3^"     delete-word  # urxvt: C-delete
bindkey "^[[3"      delete-word  # urxvt: Alt-delete
bindkey "^[Od" 	    backward-word # urxvt: C-Left
bindkey "^[Oc" 	    forward-word  # urxvt: C-Right
bindkey "^F" 	      forward-word  # urxvt: C-F
bindkey "^B" 	      backward-word # urxvt: C-B

# History search 
autoload -U up-line-or-beginning-search
autoload -U down-line-or-beginning-search
zle -N up-line-or-beginning-search
zle -N down-line-or-beginning-search

bindkey "^[[A"      up-line-or-beginning-search # Up
bindkey "^[[B"      down-line-or-beginning-search # Down

#bindkey "^[OA" 	  up-line-or-history # up
#bindkey "^[OB" 	  down-line-or-history # down
#bindkey -- "^[[A" 	history-search-backward # up
#bindkey -- "^[[B" 	history-search-forward # down

bindkey "^r" 	      history-incremental-search-backward
bindkey "^[s"  	    sudo-command-line # alt+s (zfunctions.zsh)

# Custom ZSH Binds
#bindkey "^ "        autosuggest-accept
