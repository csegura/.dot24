#!/bin/bash
#DOC: Install Google Chrome browser

mkdir -p "~/tmp"
cd "~/tmp"
# Download the Chrome debian package
wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
sudo dpkg -i google-chrome-stable_current_amd64.deb
# Cleanup
rm -f google-chrome-stable_current_amd64.deb
cd -