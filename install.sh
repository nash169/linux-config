#!/bin/sh

DISTRO=$(awk '/DISTRIB_ID=/' /etc/*-release | sed 's/DISTRIB_ID=//' | tr '[:upper:]' '[:lower:]')
AURHELPER=yay

error() {
    printf "%s\n" "$1" >&2
    return
}

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
            tput 
            rm -rf "/tmp/$item"
            sudo -u "$username" mkdir -p "/tmp/$item"
            sudo -u "$username" git -C "/tmp" clone --depth 1 --single-branch --no-tags -q "https://aur.archlinux.org/$item.git" "/tmp/$item" ||
                {
                    cd "/tmp/$item" || return 1
                    sudo -u "$username" git pull --force origin master
                }
            cd "/tmp/$item" || exit 1
            sudo -u "$username" makepkg --noconfirm -si >/dev/null 2>&1 || return 1
	    fi
	fi
    done
}

sudooff() {
    sed -i '/%wheel ALL=(ALL:ALL) NOPASSWD: ALL/s/^#//g' /etc/sudoers
}

sudoon() {
    sed -i '/%wheel ALL=(ALL:ALL) NOPASSWD: ALL/s/^/#/g' /etc/sudoers
}

basicutils() {
    pacman --noconfirm --needed -Sy libnewt
	
    whiptail --title "Install Basics" --yesno "Install basic packages?" 8 78 || return

    pacman --noconfirm -Sy archlinux-keyring >/dev/null 2>&1

    base=(base base-devel sudo sed curl stow unzip git)
    pkginstall root ${base[@]} || "Error: could not install BASIC packages."
}

adduser() {
    whiptail --title "Add User" --yesno "Add new user?" 8 78 || return

    NAME=$(whiptail --inputbox "Enter username" 8 78 --title "Add User" 3>&1 1>&2 2>&3) || return
    while ! echo "$NAME" | grep -q "^[a-z_][a-z0-9_-]*$"; do
	NAME=$(whiptail --inputbox "Username not valid. Give a username beginning with a letter, with only lowercase letters, - or _." 8 78 --title "Add User" 3>&1 1>&2 2>&3 3>&1) || return
    done

    if id -u "$NAME" >/dev/null 2>&1; then 
	whiptail --title "Warning" --msgbox "The user already exist." 8 78
	return
    fi

    PASS=$(whiptail --passwordbox "Enter password" 8 78 --title "Add User" 3>&1 1>&2 2>&3) || return

    useradd -m -g wheel -s /bin/zsh "$NAME" >/dev/null 2>&1 || usermod -a -G wheel "$NAME" && mkdir -p /home/"$NAME" && chown "$NAME":wheel /home/"$NAME"
    echo "$NAME:$PASS" | chpasswd
    unset PASS 
}

username() {
    if [ -z ${NAME+x} ]; then
	NAME=$(whiptail --inputbox "Enter the username." 8 78 3>&1 1>&2 2>&3) || return
    fi
}

userrepo() {
    username || error "Could not get username."
    if [ -z "$REPODIR" ]; then
	    REPODIR=/home/$NAME/$(whiptail --inputbox "Enter repository directory." 8 78 3>&1 1>&2 2>&3) || return
    fi
    if [ ! -d "$REPODIR" ]; then
        sudo -u "$NAME" mkdir -p "$REPODIR"
    fi
}

aurhelper() {
    whiptail --title "Install the AUR helper?" --yesno "AUR helper" 8 78 || return

    username || error "Could not get username."

    pkginstall "$NAME" "$AURHELPER"
}


dotfiles() {
    userrepo || error "Could not get repository directory."

    if [ ! -d "$REPODIR/dotfiles" ]; then
        whiptail --title "Dotfiles" --yesno "Install Dofiles?" 8 78 || return

        sudo -u "$NAME" git clone https://github.com/nash169/dotfiles.git "$REPODIR/dotfiles"

        if [ ! -d "/home/$NAME/.config" ]; then
	        sudo -u "$NAME" mkdir -p "/home/$NAME/.config"
        fi
    fi
}

desktop() {
    whiptail --title "Desktop" --yesno "Install Desktop?" 8 78 || return
    dotfiles || error "Could not fetch the dotfiles."

    desktop=(xorg-server xorg-xwininfo xorg-xinit xorg-xprop xorg-xdpyinfo xorg-xbacklight xorg-xrandr xorg-xrdb xorg-xbacklight xcompmgr feh slock dmenu)
    pkginstall $NAME ${desktop[@]} || "Error: could not install XORG packages."

    sudo -u $NAME git clone https://github.com/nash169/dwm.git $REPODIR/dwm 
    sudo -u $NAME git -C $REPODIR/dwm remote add upstream git://git.suckless.org/dwm 
    # sudo -u $NAME git -C $REPODIR/dwm fetch upstream
    # sudo -u $NAME git -C $REPODIR/dwm merge upstream/master
    sudo -u $NAME git -C $REPODIR/dwm checkout custom
    # sudo -u $NAME git -C $REPODIR/dwm rebase upstream/master
    
    if [ -d "$REPODIR/dotfiles" ]; then
        cd $REPODIR/dotfiles && sudo -u $NAME stow font -t /home/$NAME 
        cd $REPODIR/dotfiles && sudo -u $NAME stow walls -t /home/$NAME 
        cd $REPODIR/dotfiles && sudo -u $NAME stow xserver -t /home/$NAME 
        cd $REPODIR/dotfiles && sudo -u $NAME stow dwm -t $REPODIR/dwm 
    fi

    cd $REPODIR/dwm && make install

    sudo -u $NAME git clone https://github.com/nash169/dwmstatus.git $REPODIR/dwmstatus 
    sudo -u $NAME git -C $REPODIR/dwmstatus remote add upstream git://git.suckless.org/dwmstatus 
    # sudo -u $NAME git -C $REPODIR/dwmstatus fetch upstream
    # sudo -u $NAME git -C $REPODIR/dwmstatus rebase upstream/master
    cd $REPODIR/dwmstatus && make install
}

terminal() {
    whiptail --title "Terminal" --yesno "Install Terminal?" 8 78 || return
    dotfiles || error "Could not fetch the dotfiles."

    sudo -u $NAME git clone https://github.com/nash169/st.git $REPODIR/st 
    sudo -u $NAME git -C $REPODIR/st remote add upstream git://git.suckless.org/st 
    # sudo -u $NAME git -C $REPODIR/st fetch upstream
    # sudo -u $NAME git -C $REPODIR/st merge upstream/master
    sudo -u $NAME git -C $REPODIR/st checkout custom
    # sudo -u $NAME git -C $REPODIR/st rebase upstream/master

    if [ -d "$REPODIR/dotfiles" ]; then
        cd $REPODIR/dotfiles && sudo -u stow font -t /home/$NAME 
        cd $REPODIR/dotfiles && sudo -u stow st -t $REPODIR/st 
    fi

    cd $REPODIR/st && make install
}

shell() {
    whiptail --title "Shell" --yesno "Install Shell?" 8 78 || return
    dotfiles || error "Could not fetch the dotfiles."

    shell=(tmux exa bat zsh zsh-completions zsh-autosuggestions zsh-syntax-highlighting)
    pkginstall $NAME ${shell[@]} || "Error: could not install SHELL packages."
    chsh -s /bin/zsh "$NAME" >/dev/null 2>&1

    if [ -d "$REPODIR/dotfiles" ]; then
	    cd $REPODIR/dotfiles && sudo -u $NAME stow zsh -t /home/$NAME
    fi
}

explorer() {
    whiptail --title "Explorer" --yesno "Install Explorer?" 8 78 || return
    dotfiles || error "Could not fetch the dotfiles."

    explorer=(ripgrep fzf lf-git ueberzug)
    pkginstall $NAME ${explorer[@]} || "Error: could not install EXPLORER packages."

    if [ -d "$REPODIR/dotfiles" ]; then
	    cd $REPODIR/dotfiles && sudo -u $NAME stow lf -t /home/$NAME
    fi
}

editor() {
    whiptail --title "Editor" --yesno "Install Editor?" 8 78 || return
    dotfiles || error "Could not fetch the dotfiles."

    editor=(neovim python-pynvim texlive-bin texlive-fontsrecomended texlive-latexextra texlive-latexrecomended texlive-latex texlive-basic texlive-xetex texlive-mathscience texlive-fontsextra texlive-langenglish texlive-context texlive-luatex texlive-plaingeneric texlive-binextra texlive-bibtexextra texlive-pictures texlive-langfrench texlive-langgerman texlive-fontutils) # ninja tree-sitter lua luarocks
    pkginstall $NAME ${editor[@]} || "Error: could not install EDITOR packages."

    if [ ! -d "$REPODIR/dotfiles" ]; then
	    cd $REPODIR/dotfiles && sudo -u $NAME stow nvim -t /home/$NAME
        cd $REPODIR/dotfiles && sudo -u $NAME stow format -t /home/$NAME
    fi
}

email() {
    email=(mutt-wizard-git)
    pkginstall $NAME ${email[@]} || "Error: could not install EMAIL packages."
}

mediasuite() {
    multimedia=(sxiv mpd mpc mpv)
    pkginstall $NAME ${multimedia[@]} || "Error: could not install MULTIMEDIA packages."

    reader=(zathura zathura-pdf-mupdf zotero)
    pkginstall $NAME ${reader[@]} || "Error: could not install READER packages."
}

download() {
    whiptail --title "Install Download Tools?" --yesno "Download" 8 78 || return
    dotfiles || error "Could not fetch the dotfiles."

    download=(rtorrent youtube-dl)
    pkginstall $NAME ${download[@]} || "Error: could not install DOWNLOAD packages."
}

bluetooth() {
    bluetooth=(pulseaudio-bluetooth bluez bluez-libs bluez-utils blueberry)
    pkginstall $NAME ${bluetooth[@]} || "Error: could not install BLUETOOTH packages."
    systemctl enable bluetooth.service
    systemctl start bluetooth.service
    sed -i 's/'#AutoEnable=false'/'AutoEnable=true'/g' /etc/bluetooth/main.conf
}

audio() {
    audio=(wireplumber pipewire-pulse pulsemixer)
    pkginstall $NAME ${audio[@]} || "Error: could not install AUDIO packages."
}

browser() {
    browser=(firefox)
    pkginstall $NAME ${browser[@]} || "Error: could not install BROWSER packages."
}

devtools() {
    develop=(cmake eigen clang)
    pkginstall $NAME ${develop[@]} || "Error: could not install DEVELOP packages."
}

sshclient() {
    ssh=(openssh keychain)
    pkginstall $NAME ${ssh[@]} || "Error: could not install SSH packages."
    read -p "Insert your email: " email
    sudo -u $NAME ssh-keygen -t ed25519 -C "$email"
    sudo -u $NAME git config --global user.email "$email"
}

# sed -i '/%wheel ALL=(ALL:ALL) NOPASSWD: ALL/s/^#//g' /etc/sudoers
# 
