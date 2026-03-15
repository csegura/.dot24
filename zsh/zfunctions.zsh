
# load file
function load_file() {
    [ -f "$1" ] && source "$1"
}

# Insert sudo at begining
# Alt+s or ESC, s: inserts "sudo " at the start of line:
function sudo-command-line() {
    [[ -z $BUFFER ]] && zle up-history
    [[ $BUFFER != sudo\ * ]] && BUFFER="sudo $BUFFER"
    zle end-of-line
}
zle -N sudo-command-line

# Change cursor shape in vi mode
zle-keymap-select () {
    if [[ $KEYMAP == vicmd ]]; then
        # the command mode for vi (steady underline)
        echo -ne "\e[4 q"
    else
        # the insert mode for vi (blinking bar)
        echo -ne "\e[2 q"
    fi
}

precmd_functions+=(zle-keymap-select)
zle -N zle-keymap-select
echo -ne "\e[2 q"

# Read man pages with VIM
function vman() { 
  man $* | col -b | vim -c 'set ft=man nomod nolist' -; 
}

# Git diff with batcat
function gdiff() {
   git diff --name-only --relative --diff-filter=d $* | xargs batcat --diff
}
# Bat Tail 
function btail() {
  tail -f $* | batcat --paging=never -l log
}

# Partition mount
function pmount() { 
  sudo mount -o loop,offset=$(($(sudo fdisk -lu "$1" | sed -n '/^Device|Dispositiv/,/^$/p' | tail -n+2 | fzf | sed -E -e 's/[[:blank:]]+/ /g' | cut -d' ' -f2- | sed 's@^[^0-9]*\([0-9]\+\).*@\1@') * 512)) "$1" "$2"; 
}

function preexec() {
  [[ "$PROMPT_TIMER" != 1 ]] && return
  timer=${timer:-$SECONDS}
}

_timer_precmd() {
  if [[ "$PROMPT_TIMER" != 1 ]]; then
    unset timer
    RPROMPT=""
    return
  fi
  if [ $timer ]; then
    timer_show=$(($SECONDS - $timer))
    export RPROMPT="%F{cyan}${timer_show}s %{$reset_color%}"
    unset timer
  fi
}
precmd_functions+=(_timer_precmd)

timer() {
  if [[ "$PROMPT_TIMER" == 1 ]]; then
    PROMPT_TIMER=0
    unset timer
    RPROMPT=""
  else
    PROMPT_TIMER=1
  fi
}

# killport 
killport() {
  if [ -z "$1" ]; then
    kport 
  else
    kill -9 $(lsof -ti:$1)
  fi
}


kport() {
  local port_filter=""
  
  # If an argument is provided, create the filter string
  if [ -n "$1" ]; then
    port_filter="sport = :$1"
  fi

  # Run ss with the optional filter
  sudo ss -lptn $port_filter | \
    fzf --ansi --header-lines=1 --prompt="KILL PROCESS: " \
    --preview "echo {} | grep -oP 'pid=\K[0-9]+' | xargs ps -fp" \
    --preview-window=bottom:3:wrap | \
    grep -oP 'pid=\K[0-9]+' | xargs -r sudo kill -9
}

fkill() {
  local selected_pid
  selected_pid=$(ps -ef | fzf --ansi --header="Select a process to kill" --prompt="Kill PID: " --preview="echo {} | awk '{print \$2}' | xargs ps -fp" --preview-window=bottom:3:wrap | awk '{print $2}')
  
  if [ -n "$selected_pid" ]; then
    sudo kill -9 "$selected_pid"
    echo "Killed process with PID: $selected_pid"
  else
    echo "No process selected."
  fi
}


function man() {
  local MAN_BIN="/usr/bin/man"

  # If an argument is provided (e.g., man ls), run it normally
  if [[ -n "$1" ]]; then
    $MAN_BIN "$@"
    return $?
  fi

  # If no argument, open the fuzzy finder
  # 1. 'man -k .' lists all available pages
  # 2. {1} is the command name, {2} is the section (e.g., 1, 8)
  # 3. We strip the parentheses from {2} for the preview
  $MAN_BIN -k . | fzf \
    --reverse \
    --prompt="Manuals > " \
    --preview="echo {1} {2} | tr -d '()' | xargs $MAN_BIN | col -bx | batcat -l man -p --color always" \
    --preview-window="70%:wrap" \
    --bind="ctrl-p:toggle-preview,pgdn:preview-page-down,pgup:preview-page-up" \
    | awk '{print $1, $2}' | tr -d '()' | xargs -r $MAN_BIN
}

# A custom ls that includes octal permissions
lso() {
  # If no arguments ($# -eq 0), set the arguments to '*'
  [[ $# -eq 0 ]] && set -- *

  # Now loop through the arguments (either what you typed or the default '*')
  for item in "$@"; do
    local info=$(stat -c "%a %A %U %G %s" "$item" 2>/dev/null)
    if [ $? -eq 0 ]; then
      local colored_name=$(ls -d --color=always "$item")
      printf "%s %s\n" "$info" "$colored_name"
    fi
  done | column -t
}

inspect() {
  local pid=$1
  if [ -z "$pid" ]; then
    echo "Usage: inspect [PID]"
    return 1
  fi

  if [[ "$pid" =~ ^[0-9]+$ ]]; then
    echo "--- Process Information for PID: $pid ---"
    # Use ps for the header and basics
    ps -p "$pid" -o user,pcpu,pmem,etime,command | column -t
    
    echo -e "\n--- Executable Path ---"
    readlink "/proc/$pid/exe" || echo "Access Denied"
    
    echo -e "\n--- Open Network Connections ---"
    ss -tp | grep "pid=$pid," || echo "No active connections"
  else
    echo "--- Searching for processes matching: '$pid' ---"
    # The [^]] trick prevents grep from finding itself in the process list
    ps f -C "$pid" -o pid,user,pcpu,pmem,etime,command | grep --color=always "$pid" || echo "No matching processes found"
  fi
}

cz() {
  local selection
  
  # zoxide query -l lists your most frequent directories
  selection=$(zoxide query -l | fzf \
    --height=40% \
    --layout=reverse \
    --border=rounded \
    --prompt=$'\e[34mGo To > \e[0m' \
    --header=$'\e[2m(Zoxide Frequent Dirs)\e[0m' \
    --color='header:italic,pointer:4,hl:3' \
    --preview='tree -C -L 1 {} | head -20')

  if [[ -n "$selection" ]]; then
    cd "$selection" || return
    # Optional: Print the new path in a nice color
    echo -e "\e[32m✔\e[0m Moved to: \e[1m$PWD\e[0m"
  fi
}

# fzf-based mini file manager
fm() {
    local dir="${1:-.}"
    dir="$(realpath "$dir")"

    local selection key file
    while true; do
        selection=$(
            { echo ".."; ls -Ap "$dir"; } \
            | fzf --header="$dir" \
                  --preview="batcat --style=numbers --color=always --line-range :500 '$dir/{}'  2>/dev/null" \
                  --expect='ctrl-e,ctrl-x' \
                  --bind='ctrl-q:abort' \
                  --bind='ctrl-d:change-prompt(Directories> )+reload(find * -type d)' \
                  --bind='ctrl-f:change-prompt(Files> )+reload(find * -type f)' \
                  --prompt='> '
        )
        key="${selection%%$'\n'*}"
        file="${selection##*$'\n'}"

        [[ -z "$file" ]] && return

        if [[ "$key" == "ctrl-x" ]]; then
            cd "$dir"
            return
        fi

        if [[ "$key" == "ctrl-e" ]]; then
            local target="$dir/$file"
            [[ -f "$target" ]] && "${EDITOR:-vim}" "$target" < /dev/tty
            continue
        fi

        local target="$dir/$file"
        [[ -d "$target" ]] && dir="$(realpath "$target")"
    done
}

fm-widget() { fm; zle reset-prompt }
zle -N fm-widget

lcolors() {
  for code in {000..255}; do
    # \e[48;5;${code}m is the ANSI escape for background color
    # \e[0m resets all formatting
    printf "\e[48;5;%sm  %3s  \e[0m " "$code" "$code"
    
    # Every 8 colors, print a new line
    if [ $(( (code + 1) % 8 )) -eq 0 ]; then
      echo ""
    fi
  done

  autoload -U colors && colors
  for name code in "${(@kv)color}"; do
      # Filter out formatting like 'bold' to just see colors
      if [[ $code =~ ^[0-9]+$ ]]; then
          print -P "%K{$name}  %k %F{$name}$code: $name%f"
      fi
  done | sort -n
}

# Function to fuzzy-search and run previous SSH/SCP commands
fssh() {
  local selected_command
  
  # 1. Fetch history
  # 2. Filter for ssh or scp
  # 3. Use awk to remove the history line numbers
  # 4. Use fzf for selection
  selected_command=$(fc -l 1 | sed 's/^[[:space:]]*[0-9]*[[:space:]]*//' | grep -E "^(ssh|scp) " | fzf \
    --height=40% \
    --layout=reverse \
    --border=rounded \
    --no-preview \
    --prompt=$'\e[36mReconnect > \e[0m' \
    --header=$'\e[2mSelect a previous SSH or SCP command\e[0m' \
    --color='header:italic,pointer:6,hl:4')

  # If a command was selected, run it
  if [[ -n "$selected_command" ]]; then
    # Print the command so you know what is being executed
    echo -e "\e[33mRunning:\e[0m $selected_command"
    ${(z)selected_command}
  fi
}


# Zsh function to detect WSL
is_wsl() {
  # Check for 'Microsoft' in /proc/version, typical for WSL 1 and WSL 2
  if grep -qi microsoft /proc/version; then
    return 0
  fi
  # Alternatively, check uname -r for 'microsoft'
  if uname -r | grep -qi microsoft; then
    return 0
  fi
  return 1
}

# Function to find the log file path based on a port number and tail it.
# Assumes the process's standard error (2>) is redirected to the log file.
showlog() {
  # Check if a port number was provided
  if [ -z "$1" ]; then
    echo "Usage: showlog <PORT_NUMBER>"
    return 1
  fi

  PORT="$1"

  # 1. Find the Process ID (PID) listening on the specified port
  # Use 'lsof' to find the PID, filter for lines with 'LISTEN', and extract the PID.
  # Use 'sudo' as 'lsof' often requires it for full access.
  # The use of `lsof -i :$PORT` will typically show the PID in the second column.
  PID=$(sudo lsof -i :"$PORT" | awk '/LISTEN/ {print $2}')

  if [ -z "$PID" ]; then
    echo "Error: No process found listening on port $PORT."
    return 1
  fi

  echo "Found process (PID $PID) on port $PORT. Attempting to locate log file..."

  # 2. Locate the log file path using the process's file descriptor 2 (stderr)
  # The log file is the target of the symbolic link /proc/[PID]/fd/2.
  # The output of `ls -l` is piped to awk to extract the path after ' -> '.
  LOG_FILE=$(ls -l /proc/"$PID"/fd/2 2>/dev/null | awk -F ' -> ' '{print $2}')

  if [ -z "$LOG_FILE" ]; then
    echo "Error: Could not determine log file from file descriptor 2 for PID $PID."
    echo "This may mean the process's standard error is not redirected to a file."
    return 1
  fi

  echo "Log file located: $LOG_FILE"
  echo "--- Starting tail -f ---"
  
  # 3. Execute tail -f on the located file
  tail -f "$LOG_FILE"
}

proj() {
  local base_dir="${HOME}/prj"
  local selection
  selection=$(find "$base_dir" -mindepth 1 -maxdepth 1 -type d | fzf \
    --height=40% \
    --layout=reverse \
    --border=rounded \
    --prompt=$'\e[34mProject > \e[0m' \
    --header=$'\e[2m(~/prj)\e[0m' \
    --color='header:italic,pointer:4,hl:3' \
    --preview='cd {} && git -c color.status=always status -sb 2>/dev/null; echo ""; ls --color=always')

  if [[ -n "$selection" ]]; then
    cd "$selection" || return
    echo -e "\e[32m>\e[0m $(basename "$PWD") \e[2m($PWD)\e[0m"
  fi
}

gwt() {
  local selection
  selection=$(git worktree list | fzf \
    --height=40% \
    --layout=reverse \
    --border=rounded \
    --prompt=$'\e[34mWorktree > \e[0m' \
    --color='header:italic,pointer:4,hl:3' \
    --preview='cd {1} && git -c color.status=always status -sb 2>/dev/null; echo ""; ls --color=always' \
    | awk '{print $1}')

  if [[ -n "$selection" ]]; then
    cd "$selection" || return
    echo -e "\e[32m>\e[0m $(basename "$PWD") \e[2m($PWD)\e[0m"
  fi
}

gwta() {
  local branch
  branch=$(git branch -a --format='%(refname:short)' | fzf \
    --height=40% \
    --layout=reverse \
    --border=rounded \
    --prompt=$'\e[34mBranch > \e[0m' \
    --header=$'\e[2mSelect branch for worktree\e[0m' \
    --color='header:italic,pointer:4,hl:3')

  if [[ -n "$branch" ]]; then
    local name="${branch##*/}"
    git worktree add "../${name}" "$branch"
    echo -e "\e[32m>\e[0m Worktree created: ../${name}"
  fi
}

gwtd() {
  local selection
  selection=$(git worktree list | fzf \
    --height=40% \
    --layout=reverse \
    --border=rounded \
    --prompt=$'\e[31mRemove Worktree > \e[0m' \
    --color='header:italic,pointer:1,hl:3' \
    | awk '{print $1}')

  if [[ -n "$selection" ]]; then
    git worktree remove "$selection"
    echo -e "\e[33m>\e[0m Removed worktree: $selection"
  fi
}

glog() {
  local hash
  hash=$(git log --oneline --graph --color=always --decorate | fzf \
    --no-sort \
    --height=80% \
    --border=rounded \
    --prompt=$'\e[34mLog > \e[0m' \
    --header=$'\e[2mEnter: copy hash\e[0m' \
    --preview='git show --color=always $(echo {} | grep -oE "[a-f0-9]{7,}" | head -1)' \
    --color='header:italic,pointer:4,hl:3' \
    | grep -oE "[a-f0-9]{7,}" | head -1)

  if [[ -n "$hash" ]]; then
    echo -n "$hash" | xclip -selection clipboard
    echo -e "\e[32m>\e[0m Copied $hash"
  fi
}

gbr() {
  local branch
  branch=$(git branch --sort=-committerdate | sed 's/^[* ]*//' | fzf \
    --height=40% \
    --border=rounded \
    --prompt=$'\e[34mBranch > \e[0m' \
    --header=$'\e[2mEnter: checkout\e[0m' \
    --preview='git log --oneline --graph --color=always -20 {}' \
    --color='header:italic,pointer:4,hl:3')

  if [[ -n "$branch" ]]; then
    git checkout "$branch"
  fi
}

ggrep() {
  if [[ -z "$1" ]]; then
    echo "Usage: ggrep <term>"
    return 1
  fi

  local hash
  hash=$(git log --oneline --color=always -S "$1" | fzf \
    --no-sort \
    --height=80% \
    --border=rounded \
    --prompt=$'\e[34mGrep > \e[0m' \
    --header=$'\e[2mSearching: '"$1"'\e[0m' \
    --preview='git show --color=always $(echo {} | grep -oE "[a-f0-9]{7,}" | head -1)' \
    --color='header:italic,pointer:4,hl:3' \
    | grep -oE "[a-f0-9]{7,}" | head -1)

  if [[ -n "$hash" ]]; then
    echo -n "$hash" | xclip -selection clipboard
    echo -e "\e[32m>\e[0m Copied $hash"
  fi
}

gconflict() {
  local files
  files=$(git diff --name-only --diff-filter=U)

  if [[ -z "$files" ]]; then
    echo -e "\e[32m>\e[0m No conflicts"
    return
  fi

  local file
  file=$(echo "$files" | fzf \
    --height=60% \
    --border=rounded \
    --prompt=$'\e[31mConflict > \e[0m' \
    --header=$'\e[2mEnter: open in vim\e[0m' \
    --preview='batcat --color=always --highlight-line $(grep -n "^<<<<<<<" {} | head -1 | cut -d: -f1) {}' \
    --color='header:italic,pointer:1,hl:3')

  if [[ -n "$file" ]]; then
    vim "+/^<<<<<<<" "$file"
  fi
}
