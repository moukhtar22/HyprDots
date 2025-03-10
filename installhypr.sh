#!/bin/bash

# ================================
# Automatic Installation Script for Hyprland
# Repository: https://github.com/Pahasara/HyprDots
# Author: Moukhtar Morsy 
# ================================

# Exit on error
set -e

# Colors for better readability
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color

# Function to print messages
print_message() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
    exit 1
}

# Update the system
print_message "Updating the system..."
sudo pacman -Syu --noconfirm || print_error "Failed to update the system."

# Install essential tools
print_message "Installing essential tools..."
sudo pacman -S --needed --noconfirm git base-devel || print_error "Failed to install essential tools."

# Install AUR helper (yay) if not present
if ! command -v yay &> /dev/null; then
    print_message "Installing Yay AUR helper..."
    git clone https://aur.archlinux.org/yay.git
    cd yay
    makepkg -si --noconfirm
    cd ..
    rm -rf yay
fi

# Install dependencies (including AUR packages)
print_message "Installing dependencies..."
DEPENDENCIES=(
    kitty uwsm zsh curl wget powerline-fonts fastfetch
)

AUR_DEPENDENCIES=(
    hyprland-meta-git swaylock-effects rofi-wayland rofi-themes-collection-git waybar dunst-git hyprlock-git 
    hypridle-git ttf-cascadia-mono-nerd ttf-jetbrains-mono-nerd ttf-ubuntu-nerd ttf-font-awesome 
    neovim zen-browser-bin cliphist yazi dolphin dolphin-plugins swww mpv zathura okular musikcube rofi-calc qbittorrent-git rofi-emoji-git
)

# Install official packages
sudo pacman -S --needed --noconfirm "${DEPENDENCIES[@]}" || print_error "Failed to install dependencies."

# Install AUR packages
yay -S --needed --noconfirm "${AUR_DEPENDENCIES[@]}" || print_error "Failed to install AUR dependencies."

# Clone the repository
REPO_URL="https://github.com/Pahasara/HyprDots.git"
INSTALL_DIR="$HOME/HyprDots"

if [[ -d "$INSTALL_DIR" ]]; then
    print_warning "Directory $INSTALL_DIR already exists. Skipping clone."
else
    print_message "Cloning repository from $REPO_URL..."
    git clone "$REPO_URL" "$INSTALL_DIR" || print_error "Failed to clone the repository."
fi

# Copy configuration files
print_message "Copying configuration files..."
CONFIG_DIR="$HOME/.config"
LOCAL_DIR="$HOME/.local"
WALL_DIR="$HOME/Pictures"

# Backup functions
backup_dir() {
    local dir=$1
    if [ -d "$dir" ]; then
        local backup="${dir}.bak"
        if [ -d "$backup" ]; then
            print_warning "Backup already exists: $backup"
        else
            print_warning "Backing up existing $dir to $backup"
            mv "$dir" "$backup"
        fi
    fi
}

# Create directories
mkdir -p "$CONFIG_DIR"
mkdir -p "$LOCAL_DIR"
mkdir -p "$WALL_DIR"

# Backup existing configurations
backup_dir "$CONFIG_DIR"
backup_dir "$LOCAL_DIR"

# Copy new configurations
print_message "Copying .config files..."
cp -r "$INSTALL_DIR/.config"/* "$CONFIG_DIR/" || print_error "Failed to copy config files."

print_message "Copying .local files..."
cp -r "$INSTALL_DIR/.local"/* "$LOCAL_DIR/" || print_error "Failed to copy local files."

print_message "Copying wallpapers..."
cp -r "$INSTALL_DIR/.wall"/* "$WALL_DIR/" || print_error "Failed to copy wallpapers."

# Handle .zshrc
if [ -f "$HOME/.zshrc" ]; then
    print_warning "Backing up existing .zshrc to .zshrc.bak"
    mv "$HOME/.zshrc" "$HOME/.zshrc.bak"
fi
cp "$INSTALL_DIR/.zshrc" "$HOME/" || print_error "Failed to copy .zshrc."

# Set Zsh as the default shell for the user
print_message "Setting Zsh as the default shell..."
if ! chsh -s /bin/zsh; then
    print_warning "Failed to set Zsh as default shell. You might need to run 'chsh -s /bin/zsh' manually."
fi

# Install Oh My Zsh (optional)
if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
    print_message "Installing Oh My Zsh..."
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
else
    print_warning "Oh My Zsh is already installed. Skipping."
fi

# Post-installation message
print_message "Installation completed successfully!"
print_message "You can now start Hyprland by selecting it in your display manager or running 'Hyprland'."
