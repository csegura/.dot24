#!/bin/bash

# check if a package is installed if not install it
# Usage: check_package <package_name>
function check_package() {
    if [ -z "$(dpkg -l | grep $1)" ]; then
        echo "Package $1 is not installed"
        echo "Installing $1"
        sudo apt-get install $1
        exit 1
    fi
}

mkdir -p ~/.cache/zsh
mkdir -p ~/.cache/vim

# Check and install
check_package zsh                       # zsh shell
check_package zsh-autosuggestions       # zsh autosuggestions
check_package zsh-syntax-highlighting   # zsh syntax-highlighting command line
check_package fd-find                   # better find (use with fuzzy find)
check_package fzf                       # fuzzy find

# Link config files
ln -s ~/.dotfiles/zsh/zshrc ~/.zshrc
ln -s ~/.dotfiles/vim/vimrc ~/.vimrc
ln -s ~/.dotfiles/tmux/tmux.conf ~/.tmux.conf


