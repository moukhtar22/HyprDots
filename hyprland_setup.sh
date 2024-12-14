#!/bin/bash

set -e

# Update the system
sudo pacman -Syu --noconfirm || true

# Install AUR helper if not already installed
if ! command -v yay &>/dev/null; then
  git clone https://aur.archlinux.org/yay.git || true
  cd yay
  makepkg -si --noconfirm || true
  cd ..
  rm -rf yay
fi

# Install all packages via yay
yay -S --noconfirm \
  hyprland \
  waybar \
  kitty \
  rofi-wayland \
  dunst \
  hyprlock \
  hypridle \
  ttf-nerd-fonts-symbols \
  ttf-nerd-fonts-symbols-common \
  ttf-nerd-fonts-symbols-mono \
  ttf-noto-nerd \
  ttf-ubuntu-mono-nerd \
  ttf-font-awesome \
  ttf-cascadia-code-nerd \
  ttf-cascadia-mono-nerd \
  ttf-jetbrains-mono-nerd \
  ttf-ibmplex-mono-nerd \
  ttf-liberation-mono-nerd \
  ttf-iawriter-nerd \
  ttf-iosevka-nerd \
  neovim \
  zsh \
  zsh-autosuggestions \
  zsh-completions \
  zsh-syntax-highlighting \
  firefox \
  firefox-adblock-plus \
  firefox-dark-reader \
  zenity \
  yad \
  sddm \
  cliphist \
  dolphin \
  dolphin-plugins \
  swww \
  mpv \
  vlc \
  okular \
  zathura \
  zathura-pdf-mupdf \
  elisa \
  rhythmbox \
  aria2 \
  qbittorrent \
  fasd \
  grim\
  wl-clipboard \
  xdg-desktop-portal-hyprland \
  polkit-kde-agent \
  brightnessctl \
  pipewire \
  pipewire-pulse \
  pipewire-alsa \
  wireplumber \
  ibwireplumber \
  nmcli \
  networkmanager \
  libreoffice-fresh \
  udiskie \
  mojave-gtk-theme \
  fluent-icon-theme \
  eza \
  rofi-emoji-git \
  zeroc-ice \
  zeromq \
  fastfetch 


# Set zsh as default shell
chsh -s $(which zsh) || true

# Apply themes and icons
mkdir -p ~/.themes ~/.icons || true

git clone https://github.com/vinceliuice/Mojave-gtk-theme.git ~/Mojave-gtk-theme || true
~/Mojave-gtk-theme/install.sh || true

git clone https://github.com/vinceliuice/Fluent-icon-theme.git ~/Fluent-icon-theme || true
~/Fluent-icon-theme/install.sh || true


# Install Vesktop from GitHub
git clone https://github.com/Vencord/Vesktop.git ~/Vesktop || true
cd ~/Vesktop || true
npm install || true  # Assuming Vesktop uses Node.js/npm
npm run build || true
sudo npm install -g vesktop || true
cd ~ || true


# Clone and apply HyprDots configuration
git clone https://github.com/moukhtar22/HyprDots.git ~/HyprDots || true
cd ~/HyprDots
cp -r .local/* $HOME/.local || true
cp -r .config/* $HOME/.config || true 
mkdir $HOME/Pictures || true 
cp -r .walls/* $HOME/Pictures || true

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
