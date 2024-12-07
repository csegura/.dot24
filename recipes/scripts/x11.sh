#!/bin/bash
#DOC: Install base X11 server without window manager

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

