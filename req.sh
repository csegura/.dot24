#!/bin/bash

# check if a package is installed if not install it
# Usage: check_package <package_name_x86> <package_name_arm>
function check_package() {
  if [ -z "$2" ]; then
      $2=$1
  fi
  if [[ $ARCH == "arm" ]]; then
      $1=$2
  fi
  if [ -z "$(dpkg -l | grep $1)" ]; then
      echo "Package $1 is not installed"
      echo "Installing $1"
      sudo apt-get install $1
  else
      echo "Skip $1"
  fi
}

function set_arch() {
  ARCH=$(uname -m)
  case $ARCH in
    armv5*) ARCH="arm";;
    armv6*) ARCH="arm";;
    armv7*) ARCH="arm";;
    aarch64) ARCH="arm";;
    x86) ARCH="386";;
    x86_64) ARCH="amd64";;
    i686) ARCH="386";;
    i386) ARCH="386";;
  esac
}
set_arch
echo $ARCH

mkdir -p ~/.cache/zsh
mkdir -p ~/.cache/vim

# Check and install
check_package zsh                       # zsh shell
check_package zsh-autosuggestions       # zsh autosuggestions
check_package zsh-syntax-highlighting   # zsh syntax-highlighting command line
check_package fd-find                   # better find (use with fuzzy find)
check_package fzf                       # fuzzy find
check_package vim                       # vim
check_package batcat bat                # better cat (used with fzf)

# Link config files
ln -s -f ~/.dotfiles/zsh/zshrc ~/.zshrc
ln -s -f ~/.dotfiles/vim/vimrc ~/.vimrc
ln -s -f ~/.dotfiles/tmux/tmux.conf ~/.tmux.conf

ln -s -f ~/.dotfiles/.Xdefaults ~/.Xdefaults
ln -s -f ~/.dotfiles/git/.gitconfig ~/.gitconfig

sudo chsh --shell /bin/zsh $(whoami)
