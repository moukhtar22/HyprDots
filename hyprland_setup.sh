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
  grim \
  wl-clipboard \
  xdg-desktop-portal-hyprland \
  polkit-kde-agent \
  brightnessctl \
  pipewire \
  pipewire-pulse \
  pipewire-alsa \
  wireplumber \
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
  fastfetch \
  nodejs \
  npm

# Set zsh as default shell
if [ "$SHELL" != "$(which zsh)" ]; then
  echo "Changing default shell to zsh..."
  chsh -s "$(which zsh)"
fi

# Apply themes and icons
mkdir -p ~/.themes ~/.icons || true

# Install Mojave GTK theme from GitHub
if [ ! -d ~/Mojave-gtk-theme ]; then
  git clone https://github.com/vinceliuice/Mojave-gtk-theme.git ~/Mojave-gtk-theme || true
fi
~/Mojave-gtk-theme/install.sh || true

# Install Fluent Icon Theme from GitHub
if [ ! -d ~/Fluent-icon-theme ]; then
  git clone https://github.com/vinceliuice/Fluent-icon-theme.git ~/Fluent-icon-theme || true
fi
~/Fluent-icon-theme/install.sh || true

# Install Vesktop from GitHub
if [ ! -d ~/Vesktop ]; then
  git clone https://github.com/Vencord/Vesktop.git ~/Vesktop || true
fi
cd ~/Vesktop || true
npm install || {
  echo "Error: npm install failed for Vesktop."
  exit 1
}
npm run build || {
  echo "Error: npm run build failed for Vesktop."
  exit 1
}
sudo npm install -g vesktop || true
cd ~ || true

# Clone and apply HyprDots configuration
if [ ! -d ~/HyprDots ]; then
  git clone https://github.com/moukhtar22/HyprDots.git ~/HyprDots || true
fi
cd ~/HyprDots || true
cp -r .local/* $HOME/.local || true
cp -r .config/* $HOME/.config || true
mkdir -p $HOME/Pictures || true
cp -r .walls/* $HOME/Pictures || true
cd ~

# Configure pipewire
if command -v pipewire &>/dev/null; then
  systemctl --user enable --now pipewire pipewire-pulse wireplumber || true
else
  echo "Warning: Pipewire is not installed or configured correctly."
fi

# Enable Hyprland to start automatically
mkdir -p ~/.config/systemd/user || true
cat <<EOL | tee ~/.config/systemd/user/hyprland.service
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
if systemctl list-unit-files | grep -q bluetooth.service; then
  sudo systemctl enable --now bluetooth.service || true
else
  echo "Warning: Bluetooth service not found."
fi

# Final message with reboot prompt
echo "Installation complete. Do you want to reboot now? (y/N)"
read -r response
if [[ "$response" =~ ^[Yy]$ ]]; then
  sudo reboot
else
  echo "You can reboot manually later to apply all changes."
fi
