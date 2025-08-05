
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
  +vi-git_status() {
    local gitstatus=$(git status --porcelain) 
    # parse status
    local untrack=$(echo "$gitstatus" | grep "^??" |  wc -l)
    local modified=$(echo "$gitstatus" | grep "^ M" |  wc -l)
    local staged=$(echo "$gitstatus" | grep "^M" |  wc -l)
    local tocommit=$(echo "$gitstatus" | grep "^MM" |  wc -l)
    local outgoing=0
    local pulls=0
    local branch=""
    local stashed=0
    if [[ -n $(git remote) ]]; then
      outgoing=$(git rev-list origin/main..HEAD 2>/dev/null | wc -l)
      stashed=$(git rev-parse --verify refs/stash &>/dev/null ; echo $?)
      gitdir="$(git rev-parse --git-dir 2>/dev/null)"
      branch="$(cat ${gitdir}/HEAD 2>/dev/null)"
      branch=${branch##*/heads/}
      pulls="$(git log ${branch}..origin/${branch} --oneline | wc -l)"
    else
      # if no remote, we assume no outgoing commits
    fi
    # local outgoing=$(git rev-list remotes/origin/main.. 2>/dev/null | wc -l)

    # print
    if [[ "$untrack" -gt 0 ]];  then
        hook_com[misc]+="%F{red}u$untrack%{%f%}"
    fi
    if [[ "$modified" -gt 0 ]];  then
        hook_com[misc]+="%F{cyan}m$modified%{%f%}"
    fi
    if [[ "$staged" -gt 0 ]];  then
        hook_com[misc]+="%F{yellow}s$staged%{%f%}"
    fi
    if [[ "$tocommit" -gt 0 ]];  then
        hook_com[misc]+="%F{magenta}c$tocommit%{%f%}"
    fi
    if [[ "$outgoing" -gt 0 ]];  then
        hook_com[misc]+="%F{green}↑$outgoing%{%f%}"
    fi
    #if [[ "$stashed" -eq 0 ]];  then
    #    hook_com[misc]+="%F{green}s%{%f%}"
    #fi
    if [[ "$pulls" -gt 0 ]];  then
        hook_com[misc]+="%F{red}↓$pulls%{%f%}"
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

  zstyle ':vcs_info:git*+set-message:*' hooks git_status
fi

