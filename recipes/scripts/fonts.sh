#!/bin/bash
#DOC: Install fonts

mkdir -p "~/tmp"
cd "~/tmp"
# Fonts
wget https://download.jetbrains.com/fonts/JetBrainsMono-1.0.0.zip
unzip JetBrainsMono-1.0.0.zip
sudo mv JetBrainsMono-*.ttf /usr/share/fonts/
rm -f JetBrainsMono-1.0.0.zip

# Fonts awesome - i3status
sudo apt install fonts-font-awesome

cd -