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

# Check if the script is run as root
if [[ $EUID -ne 0 ]]; then
    print_error "This script must be run as root. Use sudo."
fi

# Update the system
print_message "Updating the system..."
pacman -Syu --noconfirm || print_error "Failed to update the system."

# Install essential tools
print_message "Installing essential tools..."
pacman -S --needed --noconfirm git base-devel || print_error "Failed to install essential tools."

# Clone the repository
REPO_URL="https://github.com/Pahasara/HyprDots.git"
INSTALL_DIR="$HOME/HyprDots"

if [[ -d "$INSTALL_DIR" ]]; then
    print_warning "Directory $INSTALL_DIR already exists. Skipping clone."
else
    print_message "Cloning repository from $REPO_URL..."
    git clone "$REPO_URL" "$INSTALL_DIR" || print_error "Failed to clone the repository."
fi

# Install dependencies
print_message "Installing dependencies..."
DEPENDENCIES=(
    hyprland waybar rofi alacritty swaylock-effects mako wofi
    pamixer scrot grim slurp xdg-desktop-portal-hyprland
    zsh ttf-font-awesome ttf-nerd-fonts-symbols-common
)

pacman -S --needed --noconfirm "${DEPENDENCIES[@]}" || print_error "Failed to install dependencies."

# Copy configuration files
print_message "Copying configuration files..."
CONFIG_DIR="$HOME/.config"
mkdir -p "$CONFIG_DIR"

cp -r "$INSTALL_DIR/hypr" "$CONFIG_DIR/" || print_error "Failed to copy Hyprland config."
cp -r "$INSTALL_DIR/waybar" "$CONFIG_DIR/" || print_error "Failed to copy Waybar config."
cp -r "$INSTALL_DIR/alacritty" "$CONFIG_DIR/" || print_error "Failed to copy Alacritty config."
cp -r "$INSTALL_DIR/rofi" "$CONFIG_DIR/" || print_error "Failed to copy Rofi config."

cp "$INSTALL_DIR/.zshrc" "$HOME/" || print_error "Failed to copy .zshrc."

# Set Zsh as the default shell
print_message "Setting Zsh as the default shell..."
chsh -s /bin/zsh || print_warning "Failed to set Zsh as the default shell."

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
