# ZSH Configuration (Modernized)

This configuration replaces oh-my-zsh with a modern, performant setup using:
- **Sheldon**: Fast plugin manager with lock files
- **Starship**: Blazing-fast, customizable prompt
- **Fast syntax highlighting**: Better performance than zsh-syntax-highlighting
- **Zsh-autocomplete**: Advanced autocompletion

## Key Changes

1. **Removed oh-my-zsh** - Reduced shell startup time from ~3.5s to <0.5s
2. **Unified configuration** - All configs under `zsh/` directory
3. **Cross-platform support** - Works on macOS and Linux
4. **Symbolic links** - Configs linked to XDG standard locations

## Directory Structure

```
zsh/
├── .zshrc                    # Main configuration
├── .zshrc.local.example     # Local overrides template
├── starship/                # Starship prompt config
│   └── starship.toml        # Rose-pine-moon theme
├── sheldon/                 # Plugin manager config
│   └── plugins.toml         # Plugin definitions
└── scripts/                 # Installation/utility scripts
    ├── setup-sheldon.sh     # Sheldon installer
    ├── install-starship.sh  # Starship installer
    ├── setup-starship.zsh   # Starship config setup
    └── setup-zsh-environment.sh # Complete setup
```

## Installation

### Quick Setup (Recommended)
```bash
# Run the complete setup script
./zsh/scripts/setup-zsh-environment.sh
```

### Manual Setup
1. **Install sheldon**:
   ```bash
   ./zsh/scripts/setup-sheldon.sh
   ```

2. **Install starship**:
   ```bash
   ./zsh/scripts/install-starship.sh
   ```

3. **Reload configuration**:
   ```bash
   source ~/.zshrc
   ```

### Cross-Platform Notes
- **macOS**: Uses Homebrew for installation
- **Linux**: Uses official installers or Cargo
- **Config paths**: Automatically linked to `~/.config/`

## Plugins

Managed by sheldon in `zsh/sheldon/plugins.toml`:

1. **fast-syntax-highlighting** - Better performance than zsh-syntax-highlighting
2. **zsh-autocomplete** - Advanced command completion
3. **starship** - Prompt (via setup script)

## Configuration

### Starship Prompt
- Config: `zsh/starship/starship.toml`
- Theme: Rose-pine-moon
- Features: Git status, language detection, time, etc.
- Customize: Edit the TOML file or run `starship config`

### Sheldon Plugins
- Add/remove plugins in `plugins.toml`
- Update lock file: `sheldon lock --update`
- Reload: `source ~/.zshrc`

### Custom Aliases and Functions
Add to `.zshrc.local` (not tracked in git):
```bash
# Example local overrides
alias myalias='some command'
export MY_VAR="value"
```

## Performance

Expected improvements:
- **Startup time**: ~3.5s → <0.5s
- **Memory usage**: Reduced by ~50%
- **Interactive speed**: Faster tab completion

## Troubleshooting

### Sheldon not found
```bash
# Check installation
command -v sheldon
# Reinstall if needed
./zsh/scripts/setup-sheldon.sh
```

### Starship not showing
```bash
# Check installation
command -v starship
# Check config
echo $STARSHIP_CONFIG
ls -la ~/.config/starship.toml
```

### Plugin issues
```bash
# Update plugins
sheldon lock --update
# Clear cache
rm -rf ~/.cache/sheldon
```

### Revert to oh-my-zsh
```bash
# Backup first
cp zsh/.zshrc zsh/.zshrc.backup
# Restore original
git checkout -- zsh/.zshrc
# Remove symlinks
rm ~/.config/starship.toml ~/.config/sheldon 2>/dev/null || true
```

## Migration from oh-my-zsh

### What was removed
- oh-my-zsh framework
- git plugin (use custom aliases if needed)
- zsh-syntax-highlighting (replaced with faster version)
- zsh-autosuggestions (replaced with zsh-autocomplete)
- rust plugin (use cargo env directly)

### What was kept
- vi mode configuration
- macOS clipboard integration
- All tool initializations (zoxide, atuin, fzf, nvm)
- PATH and environment settings
- Custom aliases and functions

## Updating

1. **Update plugins**:
   ```bash
   sheldon lock --update
   ```

2. **Update starship**:
   ```bash
   ./zsh/scripts/install-starship.sh
   ```

3. **Update sheldon**:
   ```bash
   ./zsh/scripts/setup-sheldon.sh
   ```

## Contributing

1. Edit configuration files in `zsh/`
2. Test changes locally
3. Update documentation if needed
4. Commit changes

## License

Part of the dotfiles repository. See main README for license information.