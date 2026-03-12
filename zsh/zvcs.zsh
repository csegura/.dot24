
# Load version control information
autoload -U colors && colors
autoload -Uz vcs_info

# Prompt
setopt prompt_subst

precmd_functions+=(vcs_info)

# Enable git
zstyle ':vcs_info:*' enable git

zstyle ':vcs_info:git*:*' get-revision false
zstyle ':vcs_info:git*:*' check-for-changes false

zstyle ':vcs_info:git:*' formats " %K{237}%F{11}%b%{%f%%k%} %m"
zstyle ':vcs_info:git:*' actionformats "(%a) %b %m"

# enable hooks, requires Zsh >=4.3.11
if [[ $ZSH_VERSION == 4.3.<11->* || $ZSH_VERSION == 4.<4->* || $ZSH_VERSION == <5->* ]] ; then

  +vi-git_status() {
    local -A counts
    counts=(untrack 0 modified 0 staged 0 tocommit 0)

    eval "$(git status --porcelain 2>/dev/null | awk '
      /^\?\?/ {u++}
      /^ M/   {m++}
      /^M/    {s++}
      /^MM/   {c++}
      END { printf "counts[untrack]=%d counts[modified]=%d counts[staged]=%d counts[tocommit]=%d", u+0, m+0, s+0, c+0 }
    ')"

    local outgoing=0 pulls=0

    git rev-parse --verify refs/stash &>/dev/null && local stashed=0 || local stashed=1

    if git rev-parse --verify @{upstream} &>/dev/null; then
      local ahead_behind
      ahead_behind=$(git rev-list --left-right --count @{upstream}...HEAD 2>/dev/null)
      pulls=${ahead_behind%%$'\t'*}
      outgoing=${ahead_behind##*$'\t'}
    fi

    local indicators=()
    (( counts[untrack]  )) && indicators+=("%F{red}u${counts[untrack]}%f")
    (( counts[modified] )) && indicators+=("%F{cyan}m${counts[modified]}%f")
    (( counts[staged]   )) && indicators+=("%F{yellow}s${counts[staged]}%f")
    (( counts[tocommit] )) && indicators+=("%F{magenta}c${counts[tocommit]}%f")
    (( outgoing         )) && indicators+=("%F{green}↑${outgoing}%f")
    (( pulls            )) && indicators+=("%F{red}↓${pulls}%f")
    hook_com[misc]+="${(j: :)indicators}"
  }

  zstyle ':vcs_info:git*+set-message:*' hooks git_status
fi
