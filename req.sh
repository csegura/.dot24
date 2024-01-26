#!/bin/bash

# check if a package is installed if not install it
# Usage: check_package <package_name_x86> <package_name_arm>
function check_package() {
  if [ -z "$2" ]; then
      $2=$1
  fi
  if [ arch = "arm" ]; then
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
  if (uname -m | grep -q x86_64); then
      arch = "x86_64"
  elif (uname -m | grep -q arm); then
      arch = "arm"
  fi
}

set_arch

mkdir -p ~/.cache/zsh
mkdir -p ~/.cache/vim

# Check and install
check_package zsh                       # zsh shell
check_package zsh-autosuggestions       # zsh autosuggestions
check_package zsh-syntax-highlighting   # zsh syntax-highlighting command line
check_package fd-find                   # better find (use with fuzzy find)
check_package fzf                       # fuzzy find
check_package batcat bat                # better cat (used with fzf)

# Link config files
ln -s ~/.dotfiles/zsh/zshrc ~/.zshrc
ln -s ~/.dotfiles/vim/vimrc ~/.vimrc
ln -s ~/.dotfiles/tmux/tmux.conf ~/.tmux.conf

ln -s ~/.dotfiles/.Xdefaults ~/.Xdefaults
ln -s ~/.dotfiles/git/.gitconfig ~/.gitconfig

