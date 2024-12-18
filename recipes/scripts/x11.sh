#!/bin/bash
#DOC: Install base X11 server without window manager

#  xserver-xorg-video-intel \  # check video card
#  x11-xserver-utils \         # xset, xrand
#  x11-utils \                 # xkill, xprops, xwinfo
#  xfonts-base \               # fonts
#  rxvt-unicode \              # term

# X11
sudo apt install \
  xorg \
  xserver-xorg-core \
  xserver-xorg-video-intel \  
  x11-xserver-utils \         
  x11-utils \                 
  xfonts-base \               
  rxvt-unicode \              
  xterm           

