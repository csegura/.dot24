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

# Check and install
check_package git
check_package curl wget
check_package unzip

# Network tools
check_package iproute2      # ip command
check_package net_tools     # ifconfig

# Fonts
wget https://download.jetbrains.com/fonts/JetBrainsMono-1.0.0.zip
unzip JetBrainsMono-1.0.0.zip
sudo mv JetBrainsMono-*.ttf /usr/share/fonts/
