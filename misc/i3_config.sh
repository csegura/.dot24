echo "Installing i3 window manager fonts..."
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/JetBrains/JetBrainsMono/master/install_manual.sh)"
sudo apt install fonts-font-awesome
cp -r ~/.dotfiles/misc/.config/* ~/.config
