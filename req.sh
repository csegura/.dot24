#!/bin/bash

# check if a package is installed if not install it
# Usage: check_package <package_name_x86> <package_name_arm>
function check_package () {
  local PKG=$1
  if [[ $ARCH = "arm" && ! -z $2 ]]; then
      PKG=$2
  fi
  echo "Check $PKG ..."
  if ! dpkg -l "$PKG" 2>/dev/null | grep -q "^ii"; then
      echo "Package $PKG is not installed"
      echo "Installing $PKG ($ARCH)"
      sudo apt-get install "$PKG"
  else
      echo "Already installed $PKG ($ARCH)"
  fi
}

function set_arch () {
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
echo $(uname -m)
echo $ARCH

mkdir -p ~/.cache/zsh
mkdir -p ~/.cache/vim

# fzf.vim plugin (native vim pack)
mkdir -p ~/.vim/pack/plugins/start
if [ ! -d ~/.vim/pack/plugins/start/fzf.vim ]; then
  git clone https://github.com/junegunn/fzf.vim ~/.vim/pack/plugins/start/fzf.vim
fi

# Check and install
check_package zsh                       # zsh shell
check_package zsh-autosuggestions       # zsh autosuggestions
check_package zsh-syntax-highlighting   # zsh syntax-highlighting command line
check_package fd-find                   # better find (use with fuzzy find)
# fzf from git (apt version is too old for fzf.vim)
if [ ! -d ~/.fzf ]; then
  git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
  ~/.fzf/install --bin
fi
check_package vim                       # vim
check_package batcat bat                # better cat (used with fzf)
check_package wget
check_package zoxide                    # z jumper
check_package git                       # git
check_package tmux                      # terminal multiplexer
check_package curl                      # for install rgrc
check_package jq                        # json-processor
check_package unzip                     # for unziping files
check_package rgrc                      # rusty generic colouriser

# install rgrc (https://github.com/lazywalker/rgrc)
# NOTE: curl-pipe-sh pattern — review script before running
curl -sS https://raw.githubusercontent.com/lazywalker/rgrc/master/script/install.sh | sudo sh -s -- --yes

# check if we have /usr/bin/bat
if [ -f /usr/bin/bat ]; then
  sudo ln -s /usr/bin/bat /usr/bin/batcat
fi

# Link config files
ln -s -f ~/.dotfiles/zsh/.zshrc ~/.zshrc
ln -s -f ~/.dotfiles/vim/vimrc ~/.vimrc
ln -s -f ~/.dotfiles/zsh/.zprofile ~/.zprofile
ln -s -f ~/.dotfiles/tmux/tmux.conf ~/.tmux.conf

ln -s -f ~/.dotfiles/.Xdefaults ~/.Xdefaults
ln -s -f ~/.dotfiles/git/.gitconfig ~/.gitconfig

# change shell
sudo chsh --shell /bin/zsh $(whoami)
