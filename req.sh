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
check_package zsh
check_package zsh-autosuggestions 
check_package zsh-syntax-highlighting
check_package fzf
