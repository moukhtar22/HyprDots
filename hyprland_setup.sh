#!/bin/bash

set -e  # Exit immediately on error

# Check for root permissions
if [ "$(id -u)" -ne 0 ]; then
  echo "This script must be run as root. Use 'sudo ./script_name.sh'."
  exit 1
fi

# Update the system
echo "Updating system packages..."
pacman -Syu --noconfirm || true

# Install AUR helper (yay) if not already installed
if ! command -v yay &>/dev/null; then
  echo "Installing yay (AUR helper)..."
  git clone https://aur.archlinux.org/yay.git || true
  cd yay
  makepkg -si --noconfirm || true
  cd ..
  rm -rf yay
fi

# Install all required packages via yay
echo "Installing required packages..."
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

# Set zsh as default shell for the current user
echo "Setting zsh as the default shell..."
if [ "$SHELL" != "$(which zsh)" ]; then
  chsh -s "$(which zsh)" "$USER"
fi

# Apply themes and icons
echo "Applying Mojave GTK and Fluent Icon themes..."
mkdir -p ~/.themes ~/.icons

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
echo "Installing Vesktop..."
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
cd ~

# Clone and apply HyprDots configuration
echo "Applying HyprDots configuration..."
if [ ! -d ~/HyprDots ]; then
  git clone https://github.com/moukhtar22/HyprDots.git ~/HyprDots || true
fi
cd ~/HyprDots || true
cp -r .local/* ~/.local || true
cp -r .config/* ~/.config || true
mkdir -p ~/Pictures
cp -r .walls/* ~/Pictures || true
cd ~

# Configure pipewire
echo "Configuring PipeWire..."
if command -v pipewire &>/dev/null; then
  systemctl --user enable --now pipewire pipewire-pulse wireplumber || true
else
  echo "Warning: Pipewire is not installed or configured correctly."
fi

# Enable Hyprland to start automatically
echo "Configuring Hyprland to start automatically..."
mkdir -p ~/.config/systemd/user
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
echo "Enabling Bluetooth service..."
if systemctl list-unit-files | grep -q bluetooth.service; then
  sudo systemctl enable --now bluetooth.service || true
else
  echo "Warning: Bluetooth service not found."
fi

# Final reboot prompt
echo -e "\nInstallation complete. It's recommended to reboot now to apply all changes."
read -rp "Reboot now? (y/N): " response
if [[ "$response" =~ ^[Yy]$ ]]; then
  sudo reboot
else
  echo "You can reboot later to complete the setup."
fi
