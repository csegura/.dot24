#!/bin/bash

# Basic
sudo apt install \
  git \
  curl \
  wget \
  gpg \
  unzip \
  psmisc \
  bc \
  jq \                        # json-processor
  tmux  

# Net tools
sudo apt install \
  iproute2 \                  # ip
  net_tools                   # nmtui

# X11
sudo apt install \
  xorg \
  xserver-xorg-core \
  xserver-xorg-video-intel \  # check video card
  x11-xserver-utils \         # xset, xrand
  x11-utils \                 # xkill, xprops, xwinfo
  xfonts-base \               # fonts
  rxvt-unicode \              # term
  xterm           

# i3 window manager
sudo apt install \
  i3-wm \
  i3-status \
  i3-lock \
  brightnessctl \             # ctrl bright
  dmenu \                     # menu launcher
  autorandr \                 # monitors setup 



# Install Visual Studio Code
wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > packages.microsoft.gpg \
sudo install -D -o root -g root -m 644 packages.microsoft.gpg /etc/apt/keyrings/packages.microsoft.gpg \
sh -c 'echo "deb [arch=amd64,arm64,armhf signed-by=/etc/apt/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" > /etc/apt/sources.list.d/vscode.list' \
rm -f packages.microsoft.gpg
sudo apt install apt-transport-https
sudo apt update
sudo apt install code

# Chrome
sudo apt install google-chrome

# Chrome Stable
mkdir tmp
cd tmp
wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
dpkg -i google-chrome-stable_current_amd64.deb
cd ..


# Misc Tools
sudo apt install \
  solaar \                    # logitech usb dongle manager 

# Delta diff viewer
mkdir -p ~/tmp
cd ~/tmp
wget https://github.com/dandavison/delta/releases/download/0.16.5/git-delta_0.16.5_amd64.deb
sudo dpkg -i git-delta_0.16.5_amd64.debb


# Fonts
wget https://download.jetbrains.com/fonts/JetBrainsMono-1.0.0.zip
unzip JetBrainsMono-1.0.0.zip
sudo mv JetBrainsMono-*.ttf /usr/share/fonts/

# Fonts awesome - i3status
sudo apt install fonts-font-awesome

# Screen capture
sudo apt install flameshot

