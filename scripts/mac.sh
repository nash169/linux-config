#!/bin/bash

# Install battery package
sudo pacman -S tlp

# Modify fstab for ssd longer life
sed ‘s/<relatime>/& ,data=ordered,discard/’ /etc/fstab

# Modules
sudo tee -a /etc/modules > /dev/null <<EOT
coretemp
applesmc
EOT

# Services to block interrupt
sudo cp ../rsc/disable-gpe4E.service  /etc/systemd/system/
sudo cp ../rsc/mask-gpe4E.service  /etc/systemd/system/

sudo systemctl enable disable-gpe4E.service
sudo systemctl enable mask-gpe4E.service

# Fix unwanted laptop resume after lid is closed
sudo tee -a /etc/udev/rules.d/90-xhc_sleep.rules > /dev/null <<EOT
# disable wake from S3 on XHC1
SUBSYSTEM=="pci", KERNEL=="0000:00:14.0", ATTR{power/wakeup}="disabled"
EOT

# Wireless driver
yay -S broadcom-wl

# Setup CPU governor and thermal daemons
yay -S mbpfan-git cpupower
sudo systemctl enable mbpfan
sudo systemctl enable cpupower

# Setup sound
sudo tee -a /etc/modprobe.d/snd_hda_intel.conf > /dev/null <<EOT
# Switch audio output from HDMI to PCH and Enable sound chipset powersaving
options snd-hda-intel index=1,0 power_save=1
EOT

# Install Facetime WebCam drivers
yay -S bcwc-pcie-git
