
# Load version control information
autoload -Uz vcs_info

# Prompt
setopt prompt_subst

precmd() { 
  vcs_info 
}

# Format the vcs_info_msg_0_ variable
zstyle ":vcs_info:git:*" check-for-changes true
zstyle ":vcs_info:git:*" formats        "%{%F{cyan}%b%u%c%}%f"     # branch/unstaged/staged
zstyle ":vcs_info:git:*" actionformats  "[%b|%a%u%c]"              # branch|patches/unstaged/staged
zstyle ":vcs_info:git:*" stagedstr      "%{%F{green}%B%}+%{%b%f%}"
zstyle ":vcs_info:git:*" unstagedstr    "%{%F{red}%B%}!%{%b%f%}"
