#!/bin/bash

set -e

# Update the system
sudo pacman -Syu --noconfirm || true

# Install base packages
sudo pacman -S --noconfirm \
  hyprland \
  waybar \
  kitty \
  rofi \
  dunst \
  hyprlock \
  hypridle \
  ttf-cascadia-code \
  ttf-jetbrains-mono \
  ttf-ubuntu-font-family \
  ttf-font-awesome \
  noto-fonts noto-fonts-cjk noto-fonts-emoji \
  neovim \
  zsh \
  zenity \
  cliphist \
  dolphin \
  swww \
  mpv \
  vlc \
  okular \
  zathura zathura-pdf-mupdf \
  musikcube \
  aria2 \
  qbittorrent \
  fasd \
  grimblast wl-clipboard \
  xdg-desktop-portal-hyprland \
  polkit-kde-agent \
  brightnessctl \
  pipewire pipewire-pulse pipewire-alsa \
  wireplumber \
  nmcli \
  networkmanager \
  libreoffice-fresh \
  udiskie || true

# Install AUR helper if not already installed
if ! command -v yay &>/dev/null; then
  git clone https://aur.archlinux.org/yay.git || true
  cd yay
  makepkg -si --noconfirm || true
  cd ..
  rm -rf yay
fi

# Install AUR packages
yay -S --noconfirm \
  rofi-lbonn-wayland \
  mojave-gtk-theme \
  fluent-icon-theme \
  eza \
  vesktop \
  rofi-emoji-git \
  zero-v3 \
  fastfetch || true

# Set zsh as default shell
chsh -s $(which zsh) || true

# Apply themes and icons
mkdir -p ~/.themes ~/.icons || true

git clone https://github.com/vinceliuice/Mojave-gtk-theme.git ~/Mojave-gtk-theme || true
~/Mojave-gtk-theme/install.sh || true

git clone https://github.com/vinceliuice/Fluent-icon-theme.git ~/Fluent-icon-theme || true
~/Fluent-icon-theme/install.sh || true

# Clone and apply HyprDots configuration
git clone https://github.com/moukhtar22/HyprDots.git ~/HyprDots || true
cd ~/HyprDots
chmod +x install.sh || true
./install.sh || true

# Configure pipewire
systemctl --user enable --now pipewire pipewire-pulse wireplumber || true

# Enable Hyprland to start automatically
mkdir -p ~/.config/systemd/user
cat <<EOL > ~/.config/systemd/user/hyprland.service
[Unit]
Description=Hyprland Wayland Compositor
After=graphical.target

[Service]
ExecStart=/usr/bin/Hyprland
Restart=always

[Install]
WantedBy=default.target
EOL

systemctl --user enable hyprland.service || true

# Enable Bluetooth on startup
sudo systemctl enable --now bluetooth.service || true

# Final message
echo "Installation complete. Please reboot your system to apply all changes."
