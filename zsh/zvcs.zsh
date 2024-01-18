
# Load version control information
autoload -U colors && colors
autoload -Uz vcs_info

# Prompt
setopt prompt_subst

precmd() { 
  vcs_info 
}

# Enable git
zstyle ':vcs_info:*' enable git

zstyle ':vcs_info:git*:*' get-revision false
zstyle ':vcs_info:git*:*' check-for-changes true
zstyle ':vcs_info:git*:*' stagedstr     "%{$fg[green]%}↑ "
zstyle ':vcs_info:git*:*' unstagedstr   "%{$fg[red]%}⚡ "
zstyle ':vcs_info:git*'   formats       "%u%c%b %{$fg[blue]%}%m "

