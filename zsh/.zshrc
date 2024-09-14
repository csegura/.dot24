
source ${HOME}/.dotfiles/zsh/zfunctions.zsh
source ${HOME}/.dotfiles/zsh/zalias.zsh
source ${HOME}/.dotfiles/zsh/zcompletion.zsh
source ${HOME}/.dotfiles/zsh/zvcs.zsh
source ${HOME}/.dotfiles/zsh/zexports.zsh
source ${HOME}/.dotfiles/zsh/zbindings.zsh

# Enable fzf
load_file /usr/share/doc/fzf/examples/completion.zsh
load_file /usr/share/doc/fzf/examples/key-bindings.zsh

# Basic zsh stuff 
load_file /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh
load_file /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# Zoxide (aka z)
eval "$(zoxide init zsh)"

# Navigation
setopt AUTO_CD              # Go to folder path without using cd.
setopt AUTO_PUSHD           # Push the old directory onto the stack on cd.
setopt PUSHD_IGNORE_DUPS    # Do not store duplicates in the stack.
setopt PUSHD_SILENT         # Do not print the directory stack after pushd or popd.
setopt CORRECT              # Spelling correction
setopt CDABLE_VARS          # Change directory to a path stored in a variable.
setopt EXTENDED_GLOB        # Use extended globbing syntax.
setopt AUTO_LIST            # automatically list choices on ambiguous completion
setopt AUTO_MENU            # automatically use menu completion
setopt ALWAYS_TO_END        # move cursor to end if word had one match

unsetopt BEEP               # Disable beeps
unsetopt CORRECT		 	      # Disable corrector

# History
HISTSIZE=10000
SAVEHIST=10000
HISTFILE=~/.cache/zsh/history
setopt appendhistory

setopt AUTOCD
setopt EXTENDED_HISTORY          # Write the history file in the ":start:elapsed;command" format.
setopt SHARE_HISTORY             # Share history between all sessions.
setopt HIST_EXPIRE_DUPS_FIRST    # Expire a duplicate event first when trimming history.
setopt HIST_IGNORE_DUPS          # Do not record an event that was just recorded again.
setopt HIST_IGNORE_ALL_DUPS      # Delete an old recorded event if a new event is a duplicate.
setopt HIST_FIND_NO_DUPS         # Do not display a previously found event.
setopt HIST_IGNORE_SPACE         # Do not record an event starting with a space.
setopt HIST_SAVE_NO_DUPS         # Do not write a duplicate event to the history file.
setopt HIST_VERIFY               # Do not execute immediately upon history expansion.
setopt BANG_HIST                 # Treat '!' specially

# show colors
# for code in {000..255}; do print -P -- "$code: %F{$code}Color%f"; done
PROMPT="%{%F{green}%}%n%{%f%}@%{%F{blue}%}%m %{%F{yellow}%}%~%{%f%}"'${vcs_info_msg_0_}'"%(?.%{%F{green}%}%#%{%f%}.%{%F{red}%}%#%{%f%}) %{%f%}" 

# load custom .dircolors
eval "$(dircolors ./.dotfiles/misc/.dircolors )"