#!/bin/bash

AURHELPER=paru

# Check package -> $1: package
pkgcheck() {
    if pacman -Qi $1 &> /dev/null; then
        tput setaf 2
        echo "The package "$1" is already installed"
        tput sgr0
        true
    else
        tput setaf 1
        echo "Package "$1" has NOT been installed"
        tput sgr0
        false
    fi
}

# Install package -> $1: user, $@: packages
pkginstall() {
	username=$1
	shift
	for item in "$@"; do
		if ! pkgcheck $item; then
			# pacman installation
			if pacman -Ss $item &> /dev/null; then
				tput setaf 3
				echo "Installing package "$item" with pacman"
				tput sgr0
				pacman -S --noconfirm --needed $item
			# Aur helper installation
			elif pacman -Qi $AURHELPER &> /dev/null; then
				tput setaf 3
				echo "Installing package "$item" with "$AURHELPER""
				tput sgr0
				sudo -u "$username" $AURHELPER -S --noconfirm $item
			else
				tput setaf 3
				echo "Installing package "$item" from source"
				tput sgr0
				sudo -u "$username" mkdir -p "/tmp/$item"
				sudo -u "$username" git -C "/tmp" clone --depth 1 --single-branch --no-tags -q "https://aur.archlinux.org/$item.git" "/tmp/$item" ||
					{
						cd "/tmp/$item" || return 1
						sudo -u "$name" git pull --force origin master
					}
				cd "/tmp/$item" || exit 1
				sudo -u "$username" -D "/tmp/$item" makepkg --noconfirm -si >/dev/null 2>&1 || return 1
			fi
		fi
	done
}