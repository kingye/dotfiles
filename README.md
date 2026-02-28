# Dotfiles

Personal configuration files for macOS development environment.

## Overview

This repository contains configuration files and settings for various development tools, terminal emulators, editors, and window managers. The setup is optimized for macOS with a focus on productivity and aesthetic consistency using the Catppuccin color scheme.

## Terminal Emulators

### WezTerm
Modern GPU-accelerated terminal emulator with extensive Lua-based configuration.
- Config: `wezterm/`
- Features: Custom keybindings, font size controls, workspace management
- Documentation: See [wezterm/README.md](wezterm/README.md) for detailed keybindings and configuration

### Ghostty
Fast, native macOS terminal emulator.
- Config: `ghostty/`

### Alacritty
Minimal, GPU-accelerated terminal emulator.
- Config: `alacritty/alacritty.toml`
- Install: `brew install alacritty`

## Shell Configuration

### Zsh
- Config: `zsh/`
- Recommended plugins:
  - `zsh-autosuggestions`: `git clone https://github.com/zsh-users/zsh-autosuggestions ~/.oh-my-zsh/custom/plugins/zsh-autosuggestions`
  - `zsh-syntax-highlighting`: `git clone https://github.com/zsh-users/zsh-syntax-highlighting ~/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting`
- Enable in `~/.zshrc`:
  ```zsh
  plugins=(git zsh-syntax-highlighting zsh-autosuggestions kubectl docker vi-mode nvm)
  ```

### Starship Prompt
Cross-shell prompt with customizable segments.
- Config: `starship/starship.toml`
- Install: `brew install starship`
- Add to `~/.zshrc`:
  ```zsh
  eval "$(starship init zsh)"
  ```
- Setup: `mkdir -p ~/.config && ln -s $(pwd)/starship/starship.toml ~/.config/starship.toml`

## Editors

### Neovim
Main text editor with LazyVim distribution.
- Config: `nvim/`
- Based on LazyVim with custom plugins and keybindings
- Setup: `ln -s $(pwd)/nvim ~/.config/nvim`

### Zed
Modern collaborative code editor.
- Config: `zed/`
- Settings: `zed/settings.json`
- Keymaps: `zed/keymap.json`

### VS Code
- Config: `vscode/`
- Includes custom keybindings and settings

## Window Management

### AeroSpace
Tiling window manager for macOS.
- Config: `aerospace/`

### Hammerspoon
Powerful automation tool for macOS.
- Config: `hammerspoon/`
- Custom Spoons for window management and focus modes

### Karabiner Elements
Keyboard customizer for macOS.
- Config: `karabiner-config/`
- TypeScript-based configuration

## Terminal Multiplexers

### Tmux
Terminal multiplexer with plugin support.
- Config: `tmux/`
- Install TPM: `git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm`

### Zellij
Modern terminal workspace with layouts.
- Config: `zellij/`

## Development Tools

### Git
- Config: `git/`
- Includes aliases and custom settings

### Lazygit
Terminal UI for git commands.
- Install: `brew install lazygit`

### Atuin
Shell history sync and search.
- Config: `atuin/`

### Yazi
Terminal file manager.
- Config: `yazi/`

### Navi
Interactive cheatsheet tool.
- Config: `navi/`

## Language-Specific

### Zig
- Documentation: `zig/LazyVim_Zig.md`

### Node.js/TypeScript
- ESLint config: `eslint/`

## Other Tools

### Stormy
- Config: `stormy/stormy.toml`

### Rsync
Custom rsync configurations.
- Config: `rsync/`

### Podman
Container management configurations.
- Config: `podman/`

## Installation

1. Clone this repository:
   ```bash
   git clone https://github.com/yourusername/dotfiles.git ~/dotfiles
   cd ~/dotfiles
   ```

2. Create symbolic links for desired configurations:
   ```bash
   # Example for nvim
   ln -s ~/dotfiles/nvim ~/.config/nvim

   # Example for wezterm
   ln -s ~/dotfiles/wezterm ~/.config/wezterm
   ```

3. Install required tools via Homebrew:
   ```bash
   brew install neovim starship alacritty lazygit atuin yazi
   ```

## Theme

Most configurations use the **Catppuccin** color scheme for consistency across tools. Variants used include Mocha, Macchiato, Frappe, and Latte depending on the tool.

## Notes

- This setup is designed for macOS (Darwin)
- Some configurations may require additional setup or dependencies
- Review individual config directories for tool-specific documentation
