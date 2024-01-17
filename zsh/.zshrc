
source ~/.dotfiles/zsh/zfunctions.zsh
source ~/.dotfiles/zsh/zalias.zsh
source ~/.dotfiles/zsh/zcompletion.zsh

# alias for navigation
alias d="dirs -v"
for index ({1..9}) alias "$index"="cd +${index}"; unset index

# Exports
export CLICOLOR=1
export LSCOLORS=Gxfxcxdxbxegedabagacad
export TERM=xterm-256color
export LESS="--ignore-case --raw-control-chars"
export PAGER="less"

# Navigation
setopt AUTO_CD              # Go to folder path without using cd.
setopt AUTO_PUSHD           # Push the old directory onto the stack on cd.
setopt PUSHD_IGNORE_DUPS    # Do not store duplicates in the stack.
setopt PUSHD_SILENT         # Do not print the directory stack after pushd or popd.
setopt CORRECT              # Spelling correction
setopt CDABLE_VARS          # Change directory to a path stored in a variable.
setopt EXTENDED_GLOB        # Use extended globbing syntax.

unsetopt BEEP               # Disable beeps
unsetopt CORRECT		 	      # Disable corrector

# Completion
# Basic auto/tab complete:
#autoload -U compinit
#zstyle ":completion:*:*:*:*:*" menu select
#zstyle ":completion:*" list-colors "${(s.:.)LS_COLORS}"
##zmodload zsh/complist
#compinit
#_comp_options+=(globdots)               # Include hidden files.

# History
HISTSIZE=10000
SAVEHIST=10000
HISTFILE=~/.cache/zshhistory
setopt appendhistory

setopt autocd
setopt EXTENDED_HISTORY          # Write the history file in the ":start:elapsed;command" format.
setopt SHARE_HISTORY             # Share history between all sessions.
setopt HIST_EXPIRE_DUPS_FIRST    # Expire a duplicate event first when trimming history.
setopt HIST_IGNORE_DUPS          # Do not record an event that was just recorded again.
setopt HIST_IGNORE_ALL_DUPS      # Delete an old recorded event if a new event is a duplicate.
setopt HIST_FIND_NO_DUPS         # Do not display a previously found event.
setopt HIST_IGNORE_SPACE         # Do not record an event starting with a space.
setopt HIST_SAVE_NO_DUPS         # Do not write a duplicate event to the history file.
setopt HIST_VERIFY               # Do not execute immediately upon history expansion.

#autoload -U up-line-or-beginning-search
#autoload -U down-line-or-beginning-search

# Keyboard vi-mode
bindkey -v
export KEYTIMEOUT=1

# Custom ZSH Binds
bindkey "^ " autosuggest-accept

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

bindkey "^[^H" 	    backwards-delete-part  # urxvt: Alt+BackSpace
bindkey "^H" 	      backward-delete-char  # C-H: Backspace
bindkey "^[[3^"     delete-word  # urxvt: C-delete
bindkey "^[[3"      delete-word  # urxvt: Alt-delete
bindkey "^[Od" 	    backward-word # urxvt: C-Left
bindkey "^[Oc" 	    forward-word  # urxvt: C-Right
bindkey "^F" 	      forward-word  # urxvt: C-F
bindkey "^B" 	      backward-word # urxvt: C-B

bindkey "^[OA" 	    up-line-or-history # up
bindkey "^[OB" 	    down-line-or-history # down
bindkey -- "^[[A" 	history-search-backward # up
bindkey -- "^[[B" 	history-search-forward # down
bindkey "^r" 	      history-incremental-search-backward
bindkey "^[s"  	    sudo-command-line # alt+s

# Load version control information
autoload -Uz vcs_info

precmd() { 
  vcs_info 
  # Format the vcs_info_msg_0_ variable
  zstyle ":vcs_info:git:*" formats       "(%b%u%c)"
  zstyle ":vcs_info:git:*" actionformats "(%b|%a%u%c)"
}


# Prompt
setopt prompt_subst
# show colors
# for code in {000..255}; do print -P -- "$code: %F{$code}Color%f"; done
PROMPT="%{%F{green}%}%n%{%f%}@%{%F{blue}%}%m %{%F{yellow}%}%~ "'${vcs_info_msg_0_}'" %(?.%F{green}%#.%F{red}%#%f) %{$reset_color%} " 
