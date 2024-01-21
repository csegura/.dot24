
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

zstyle ':vcs_info:git*:*' get-revision true
zstyle ':vcs_info:git*:*' check-for-changes true

zstyle ':vcs_info:git:*' formats " %c%u %F{blue}%b%{%f%} %m"
zstyle ':vcs_info:git:*' actionformats "(%a) %c%u %b %m"

## customize vcs_info
zstyle ':vcs_info:git*:*' check-for-changes true
zstyle ':vcs_info:git*:*' unstagedstr '-'
zstyle ':vcs_info:git*:*' stagedstr '+'

# ↑(unpushed commits)

# enable hooks, requires Zsh >=4.3.11
if [[ $ZSH_VERSION == 4.3.<11->* || $ZSH_VERSION == 4.<4->* || $ZSH_VERSION == <5->* ]] ; then
  
  # hook for untracked files (prefix uFiles)
  +vi-untracked() {
    local files=$(git status --porcelain | grep "??" |  wc -l)
    if [[ "$files" -gt 0 ]];  then
       hook_com[misc]+="%F{red}u$files%{%f%}"
    fi
  }

  # local modified files
  +vi-modified() {
    local files=$(git status --porcelain | grep "^ M" |  wc -l)
    if [[ "$files" -gt 0 ]];  then
       hook_com[misc]+="%F{cyan}m$files%{%f%}"
    fi
  }
  
  # local modified files
  +vi-pending() {
    local gitdir="$(git rev-parse --git-dir 2>/dev/null)"
    local branch="$(cat ${gitdir}/HEAD 2>/dev/null)"
    branch=${branch##*/heads/}
    local files="$(git log ${branch}..origin/${branch} --oneline | wc -l)"
    if [[ "$files" -gt 0 ]];  then
       hook_com[misc]+="%F{red}↓$files%{%f%}"
    fi
  }

  # local staged files pendig commit 
  +vi-tocommit() {
    local files=$(git status --porcelain | grep "^M" |  wc -l)
    if [[ "$files" -gt 0 ]];  then
       hook_com[misc]+="%F{yellow}s$files%{%f%}"
    fi
    local files=$(git status --porcelain | grep "^MM" |  wc -l)
    if [[ "$files" -gt 0 ]];  then
       hook_com[misc]+="%F{magenta}c$files%{%f%}"
    fi
  }

  # unpushed commits
  +vi-outgoing() {
    local gitdir="$(git rev-parse --git-dir 2>/dev/null)"
    [ -n "$gitdir" ] || return 0

    if [ -r "${gitdir}/refs/remotes/git-svn" ] ; then
      local count=$(git rev-list remotes/git-svn.. 2>/dev/null | wc -l)
    else
      local branch="$(cat ${gitdir}/HEAD 2>/dev/null)"
      branch=${branch##*/heads/}
      local count=$(git rev-list remotes/origin/${branch}.. 2>/dev/null | wc -l)
    fi

    if [[ "$count" -gt 0 ]] ; then
      hook_com[misc]+="%F{green}↑$count%{%f%}"
    fi
  }

  # hook for stashed files
  +vi-stashed() {
    if git rev-parse --verify refs/stash &>/dev/null ; then
      hook_com[staged]+='s'
    fi
  }

  zstyle ':vcs_info:git*+set-message:*' hooks stashed untracked outgoing modified tocommit pending
fi

