#!/bin/bash

GREEN="\e[32m"
RED="\e[31m"
RESET="\e[0m"
PASS="${GREEN}PASS${RESET}"
FAIL="${RED}FAIL${RESET}"

errors=0

check() {
  local label="$1"
  shift
  if "$@" >/dev/null 2>&1; then
    echo -e "  [${PASS}] ${label}"
  else
    echo -e "  [${FAIL}] ${label}"
    ((errors++))
  fi
}

check_symlink() {
  local link="$1"
  local target="$2"
  local actual
  actual=$(readlink -f "$link" 2>/dev/null)
  local expected
  expected=$(readlink -f "$target" 2>/dev/null)
  if [[ "$actual" == "$expected" ]]; then
    echo -e "  [${PASS}] ${link} -> ${target}"
  else
    echo -e "  [${FAIL}] ${link} -> ${target} (got: ${actual:-missing})"
    ((errors++))
  fi
}

DOTFILES="$(cd "$(dirname "$0")" && pwd)"

echo "Symlinks"
check_symlink "$HOME/.zshrc" "$DOTFILES/zsh/.zshrc"
check_symlink "$HOME/.vimrc" "$DOTFILES/vim/vimrc"
check_symlink "$HOME/.tmux.conf" "$DOTFILES/tmux/tmux.conf"
check_symlink "$HOME/.gitconfig" "$DOTFILES/git/.gitconfig"
echo ""

echo "Required tools"
for cmd in zsh fzf fdfind batcat zoxide vim git tmux btop docker; do
  check "$cmd" command -v "$cmd"
done
echo ""

echo "Config directories"
check "~/.cache/zsh" test -d "$HOME/.cache/zsh"
echo ""

if [[ $errors -eq 0 ]]; then
  echo -e "${GREEN}All checks passed.${RESET}"
else
  echo -e "${RED}${errors} check(s) failed.${RESET}"
  exit 1
fi
