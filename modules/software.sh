#!/bin/bash

source ../utils.sh

###############################################################################

package_category Accessories

list=(
# variety
# thunar
# thunar-archive-plugin
# thunar-volman
ranger
)

count=0
for name in "${list[@]}" ; do
	count=$[count+1]
	tput setaf 3;echo "Installing package nr.  "$count " " $name;tput sgr0;
	package_install $name
done

###############################################################################

package_category Development

list=(
# meld # compare and merge file/directory
neovim
python-pynvim
)

count=0
for name in "${list[@]}" ; do
	count=$[count+1]
	tput setaf 3;echo "Installing package nr.  "$count " " $name;tput sgr0;
	package_install $name
done

###############################################################################

package_category Graphics

list=(
gimp
inkscape
# nomacs
)

count=0
for name in "${list[@]}" ; do
	count=$[count+1]
	tput setaf 3;echo "Installing package nr.  "$count " " $name;tput sgr0;
	package_install $name
done

###############################################################################

package_category Internet

list=(
brave-bin
qbittorrent
youtube-dl
)

count=0
for name in "${list[@]}" ; do
	count=$[count+1]
	tput setaf 3;echo "Installing package nr.  "$count " " $name;tput sgr0;
	package_install $name
done

###############################################################################

package_category Multimedia

list=(
mpv #vlc
spotify
)

count=0
for name in "${list[@]}" ; do
	count=$[count+1]
	tput setaf 3;echo "Installing package nr.  "$count " " $name;tput sgr0;
	package_install $name
done

###############################################################################

package_category Social

list=(
telegram-desktop
whatsapp-nativefier
)

count=0
for name in "${list[@]}" ; do
	count=$[count+1]
	tput setaf 3;echo "Installing package nr.  "$count " " $name;tput sgr0;
	package_install $name
done

###############################################################################

package_category Office

list=(
# evince
zotero
zathura
)

count=0
for name in "${list[@]}" ; do
	count=$[count+1]
	tput setaf 3;echo "Installing package nr.  "$count " " $name;tput sgr0;
	package_install $name
done

###############################################################################

package_category System

list=(
# dconf-editor
# arc-gtk-theme
# downgrade
# pamac-aur
gparted
)

count=0
for name in "${list[@]}" ; do
	count=$[count+1]
	tput setaf 3;echo "Installing package nr.  "$count " " $name;tput sgr0;
	package_install $name
done

###############################################################################

package_category Unpack

list=(
# unace
unrar
# zip
unzip
# sharutils
# uudeview
# arj
# cabextract
# file-roller
)

count=0
for name in "${list[@]}" ; do
	count=$[count+1]
	tput setaf 3;echo "Installing package nr.  "$count " " $name;tput sgr0;
	package_install $name
done

###############################################################################

package_category Utilities

list=(
stow
keychain
wget
curl
# xbindkeys
# xautomation
# watchman
)

count=0
for name in "${list[@]}" ; do
	count=$[count+1]
	tput setaf 3;echo "Installing package nr.  "$count " " $name;tput sgr0;
	package_install $name
done

###############################################################################

package_category Terminal

list=(
alacritty
fzf
tmux
exa
zsh
zsh-completions
zsh-syntax-highlighting
zsh-autosuggestions
neofetch
)

count=0
for name in "${list[@]}" ; do
	count=$[count+1]
	tput setaf 3;echo "Installing package nr.  "$count " " $name;tput sgr0;
	package_install $name
done

wget https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh -O - | sh

###############################################################################

package_category Fonts

list=(
nerd-fonts-hack
)

count=0
for name in "${list[@]}" ; do
	count=$[count+1]
	tput setaf 3;echo "Installing package nr.  "$count " " $name;tput sgr0;
	package_install $name
done