
# Load version control information
autoload -U colors && colors
autoload -Uz vcs_info

# Prompt
setopt prompt_subst

precmd_functions+=(vcs_info)

# Enable git
zstyle ':vcs_info:*' enable git

zstyle ':vcs_info:git*:*' get-revision true
zstyle ':vcs_info:git*:*' check-for-changes true

zstyle ':vcs_info:git:*' formats " %K{237}%F{11}%b%{%f%%k%} %m"
zstyle ':vcs_info:git:*' actionformats "(%a) %b %m"

# enable hooks, requires Zsh >=4.3.11
if [[ $ZSH_VERSION == 4.3.<11->* || $ZSH_VERSION == 4.<4->* || $ZSH_VERSION == <5->* ]] ; then

  +vi-git_status() {
    local gitstatus=$(git status --porcelain)
    local untrack=$(echo "$gitstatus" | grep "^??" |  wc -l)
    local modified=$(echo "$gitstatus" | grep "^ M" |  wc -l)
    local staged=$(echo "$gitstatus" | grep "^M" |  wc -l)
    local tocommit=$(echo "$gitstatus" | grep "^MM" |  wc -l)
    local outgoing=0
    local pulls=0
    local stashed=0
    if [[ -n $(git remote) ]]; then
      outgoing=$(git rev-list @{upstream}..HEAD 2>/dev/null | wc -l)
      stashed=$(git rev-parse --verify refs/stash &>/dev/null ; echo $?)
      local branch=$(git rev-parse --abbrev-ref HEAD 2>/dev/null)
      pulls=$(git rev-list HEAD..origin/${branch} --count 2>/dev/null)
    fi

    local indicators=()
    if [[ "$untrack" -gt 0 ]];  then
        indicators+=("%F{red}u$untrack%f")
    fi
    if [[ "$modified" -gt 0 ]];  then
        indicators+=("%F{cyan}m$modified%f")
    fi
    if [[ "$staged" -gt 0 ]];  then
        indicators+=("%F{yellow}s$staged%f")
    fi
    if [[ "$tocommit" -gt 0 ]];  then
        indicators+=("%F{magenta}c$tocommit%f")
    fi
    if [[ "$outgoing" -gt 0 ]];  then
        indicators+=("%F{green}↑$outgoing%f")
    fi
    if [[ "$pulls" -gt 0 ]];  then
        indicators+=("%F{red}↓$pulls%f")
    fi
    hook_com[misc]+="${(j: :)indicators}"
  }

  zstyle ':vcs_info:git*+set-message:*' hooks git_status
fi
