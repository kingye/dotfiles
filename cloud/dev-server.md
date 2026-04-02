# Cloud Dev Server Bootstrap Guide

A step-by-step checklist for setting up a new Debian cloud server for Rust/Node.js development.

Dotfiles repo: `https://gitcode.com/kingye/dotfiles`

---

## Phase 1: First Login (as root)

### 1.1 Create a non-root user

```bash
adduser jiny
usermod -aG sudo jiny
```

**Troubleshooting: `jiny is not in the sudoers file`**

On some Debian installations (especially cloud provider images), the `sudo` group may not be enabled in the sudoers file, so `usermod -aG sudo` alone doesn't work. Fix this as root:

```bash
# Option 1: Edit sudoers safely with visudo
visudo
# Find the line: # %sudo ALL=(ALL:ALL) ALL
# Uncomment it (remove the #)

# Option 2: Add the user directly
echo 'jiny ALL=(ALL:ALL) ALL' > /etc/sudoers.d/jiny
chmod 440 /etc/sudoers.d/jiny
```

Option 2 is simpler — it creates a dedicated sudoers drop-in file for the user. Verify by switching to jiny:

```bash
su - jiny
sudo whoami  # should print: root
```

### 1.2 Set up SSH key-based auth

First, **on the server as jiny**, create the `.ssh` directory:

```bash
su - jiny
mkdir -p ~/.ssh
chmod 700 ~/.ssh
```

Then **from your local Mac**, copy your public key:

```bash
ssh-copy-id -i ~/.ssh/id_ed25519.pub jiny@SERVER_IP
```

Test that you can log in without a password:
```bash
ssh jiny@SERVER_IP
```

### 1.3 (Optional) Harden SSH

Edit `/etc/ssh/sshd_config` on the server:
```
PermitRootLogin no
PasswordAuthentication no
```

Then restart SSH:
```bash
sudo systemctl restart sshd
```

### 1.4 Configure SSH on your Mac

Add to `~/.ssh/config` on your **local Mac** for convenience and keepalive:
```
Host myserver
  HostName SERVER_IP
  User jiny
  ServerAliveInterval 60
  ServerAliveCountMax 3
```

Now you can just `ssh myserver`.

---

## Phase 2: System Setup (as jiny)

### 2.1 Add swap space (CRITICAL for servers <= 4GB RAM)

Do this **before** installing anything that compiles (Rust, cargo, brew, etc.)

```bash
sudo fallocate -l 2G /swapfile
sudo chmod 600 /swapfile
sudo mkswap /swapfile
sudo swapon /swapfile
echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab
free -h  # verify swap is active
```

### 2.2 Install base dependencies

```bash
sudo apt update
sudo apt install -y \
  git curl wget \
  build-essential \
  libclang-dev \
  unzip \
  ripgrep \
  fd-find \
  tmux
```

Notes:
- `build-essential` — C compiler, needed for treesitter and cargo builds
- `libclang-dev` — needed to compile `tree-sitter-cli` via cargo
- `ripgrep` and `fd-find` — needed by Neovim Telescope
- `tmux` — terminal multiplexer

### 2.3 (Optional) Set up GitHub mirror for China servers

If your server is in China and GitHub access is slow:

```bash
git config --global url."https://mirror.ghproxy.com/https://github.com/".insteadOf "https://github.com/"
```

To undo later:
```bash
git config --global --unset url."https://mirror.ghproxy.com/https://github.com/".insteadOf
```

---

## Phase 3: Shell Setup

### 3.1 Install zsh

```bash
sudo apt install -y zsh
chsh -s $(which zsh)
```

### 3.2 Install Oh My Zsh

```bash
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
```

### 3.3 Install Oh My Zsh plugins

```bash
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-syntax-highlighting ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
```

Note: These are installed but not in the current plugins list (`plugins=(git rust)`). Add them to the plugins list in `.zshrc` if desired.

---

## Phase 4: Dev Tools

Install all tools **before** symlinking dotfiles, because `.zshrc` references them.

### 4.1 Rust + rust-analyzer

```bash
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
source "$HOME/.cargo/env"
rustup component add rust-analyzer
```

Verify:
```bash
rustc --version
rust-analyzer --version
```

### 4.2 Neovim 0.11

```bash
curl -LO https://github.com/neovim/neovim/releases/download/v0.11.5/nvim-linux-x86_64.tar.gz
tar xzf nvim-linux-x86_64.tar.gz
sudo mv nvim-linux-x86_64 /opt/nvim
sudo ln -sf /opt/nvim/bin/nvim /usr/local/bin/nvim
rm nvim-linux-x86_64.tar.gz
```

For ARM64 servers, use `nvim-linux-arm64.tar.gz` instead.

### 4.3 CLI tools

#### Starship (prompt)
```bash
curl -sS https://starship.rs/install.sh | sh
```

#### zoxide (smart cd)
```bash
curl -sSfL https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | sh
```

#### atuin (shell history)
```bash
curl --proto '=https' --tlsv1.2 -LsSf https://setup.atuin.sh | sh
```

#### eza (modern ls)
```bash
cargo install eza
```

#### lazygit (git TUI)
```bash
LAZYGIT_VERSION=$(curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" | grep -Po '"tag_name": "v\K[^"]*')
curl -Lo lazygit.tar.gz "https://github.com/jesseduffield/lazygit/releases/latest/download/lazygit_${LAZYGIT_VERSION}_Linux_x86_64.tar.gz"
tar xf lazygit.tar.gz lazygit
sudo install lazygit /usr/local/bin
rm lazygit lazygit.tar.gz
```

#### fzf (fuzzy finder)

Debian apt ships fzf 0.38 which is too old (doesn't support `fzf --zsh`). Install from git:

```bash
git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
~/.fzf/install
```

Answer yes to all prompts during installation.

### 4.4 tree-sitter-cli (via cargo, avoids glibc mismatch)

```bash
cargo install tree-sitter-cli
```

If Mason auto-installs its own tree-sitter later, replace it with a symlink:
```bash
rm -f ~/.local/share/nvim/mason/bin/tree-sitter
mkdir -p ~/.local/share/nvim/mason/bin
ln -s ~/.cargo/bin/tree-sitter ~/.local/share/nvim/mason/bin/tree-sitter
```

### 4.5 tmux plugins (TPM)

```bash
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
```

Start tmux, then install plugins:
```bash
tmux
# Inside tmux: press prefix (Ctrl+s) then Shift+I to install plugins
```

### 4.6 Node.js via nvm (optional)

Run this to install:

```bash
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | zsh
```

Then reload shell and install Node:

```bash
source ~/.zshrc
nvm install 22
```

The `.zshrc` loads nvmv automatically on shell startup.

### 4.7 OpenCode (AI coding assistant)

```bash
curl -fsSL https://opencode.ai/install | bash
```

Verify:
```bash
opencode --version
```

### 4.8 Load cargo env in .zprofile

Important for tmux and Neovim to find Rust binaries:

```bash
echo '[[ -f "$HOME/.cargo/env" ]] && . "$HOME/.cargo/env"' >> ~/.zprofile
```

---

## Phase 5: Clone Dotfiles & Symlink

All tools are now installed, so `.zshrc` will load without errors.

### 5.1 Set up Git credential store (HTTPS + access token)

```bash
git config --global credential.helper store
```

The first time you `git clone`/`pull`/`push`, enter your username and **personal access token** as the password. Git will save it to `~/.git-credentials` and never ask again.

### 5.2 Clone dotfiles

```bash
mkdir -p ~/projects
git clone https://gitcode.com/kingye/dotfiles.git ~/projects/dotfiles
```

### 5.3 Create symlinks

```bash
DOTFILES=~/projects/dotfiles

# Zsh
ln -sf $DOTFILES/zsh/.zshrc ~/.zshrc

# Tmux
ln -sf $DOTFILES/tmux/.tmux.conf ~/.tmux.conf

# Starship
mkdir -p ~/.config
ln -sf $DOTFILES/starship/starship.toml ~/.config/starship.toml

# Atuin
mkdir -p ~/.config/atuin
ln -sf $DOTFILES/atuin/config.toml ~/.config/atuin/config.toml

# OpenCode
mkdir -p ~/.config/opencode
ln -sf $DOTFILES/opencode/opencode.jsonc ~/.config/opencode/opencode.jsonc
```

### 5.4 LazyVim + dotfiles nvim config

```bash
DOTFILES=~/projects/dotfiles

# First, clone LazyVim starter to bootstrap plugin installation
git clone https://github.com/LazyVim/starter ~/.config/nvim
rm -rf ~/.config/nvim/.git

# Launch nvim once to install all plugins, then quit
nvim --headless "+Lazy! sync" +qa

# Now replace with your dotfiles nvim config
rm -rf ~/.config/nvim
ln -sf $DOTFILES/nvim ~/.config/nvim
```

### 5.5 Create .zshrc.local for secrets

```bash
cp $DOTFILES/zsh/.zshrc.local.example ~/.zshrc.local
# Edit ~/.zshrc.local and fill in your API keys
```

### 5.6 Configure git identity (not symlinked — different per machine)

```bash
git config --global user.name "Your Name"
git config --global user.email "your@email.com"
```

Optionally copy aliases from the dotfiles gitconfig:
```bash
git config --global alias.s status
git config --global alias.co checkout
git config --global alias.br branch
git config --global alias.cm "commit -m"
git config --global alias.p pull
git config --global alias.pp push
git config --global alias.lo "log --graph --decorate --pretty=oneline --abbrev-commit"
```

### 5.7 Reload zsh

```bash
source ~/.zshrc
```

---

## Phase 6: Verification Checklist

After completing all phases, verify everything works:

```bash
# Shell
zsh --version          # zsh 5.9+
echo $SHELL            # /usr/bin/zsh

# Rust
rustc --version
cargo --version
rust-analyzer --version

# Neovim
nvim --version         # NVIM v0.11.5

# CLI tools
starship --version
zoxide --version
atuin --version
fzf --version
eza --version
lazygit --version
tree-sitter --version

# Inside Neovim — open a .rs file and check:
# :echo exepath('rust-analyzer')     → should show ~/.cargo/bin/rust-analyzer
# :echo exepath('tree-sitter')       → should show ~/.cargo/bin/tree-sitter (NOT mason)
# :RustAnalyzer start                → should start without errors
# gd on a type                       → should go to definition
```

---

## Phase 7: Known Issues & Fixes

### Server freezes during cargo build / rust-analyzer

**Cause:** RAM exhausted by compilation.

**Prevention:**
1. Add swap space (Phase 2.1)
2. `CARGO_BUILD_JOBS=1` is set automatically on Linux via `.zshrc`
3. Disable checkOnSave if still OOM — create `~/.config/nvim/lua/plugins/rust.lua`:

```lua
return {
  {
    "mrcjkb/rustaceanvim",
    opts = {
      server = {
        ["rust-analyzer"] = {
          checkOnSave = false,
          cargo = {
            allFeatures = false,
          },
        },
      },
    },
  },
}
```

### tree-sitter GLIBC_2.39 error

```
tree-sitter: /lib/x86_64-linux-gnu/libc.so.6: version `GLIBC_2.39' not found
```

**Cause:** Mason auto-installs a tree-sitter binary compiled against a newer glibc.

**Fix:** Already handled in Phase 4.4 — install via cargo and symlink over Mason's copy.

### "rust-analyzer not found in PATH"

**Cause:** Neovim's `$PATH` doesn't include `~/.cargo/bin`.

**Fix:** Ensure `.zprofile` sources cargo env (Phase 4.7), then restart tmux:
```bash
tmux kill-server
tmux
```

### edition = "2024" breaks rust-analyzer go-to-definition

**Cause:** Older rust-analyzer may have incomplete edition 2024 support.

**Fix:** Update the toolchain:
```bash
rustup update stable
```

**Quick test:** Temporarily change `edition = "2024"` to `edition = "2021"` in `Cargo.toml`, then `:RustAnalyzer restart` in Neovim. If `gd` works, the edition is the cause.

---

## Symlink Reference

| Config | Dotfiles source | Target on server |
|---|---|---|
| zsh | `zsh/.zshrc` | `~/.zshrc` |
| tmux | `tmux/.tmux.conf` | `~/.tmux.conf` |
| nvim | `nvim/` | `~/.config/nvim` |
| starship | `starship/starship.toml` | `~/.config/starship.toml` |
| atuin | `atuin/config.toml` | `~/.config/atuin/config.toml` |
| opencode | `opencode/opencode.jsonc` | `~/.config/opencode/opencode.jsonc` |
| git | _(not symlinked)_ | configured via `git config` |
| secrets | `zsh/.zshrc.local.example` | `~/.zshrc.local` (copy, not symlink) |

### Not needed on cloud server (desktop-only)

wezterm, alacritty, ghostty, aerospace, hammerspoon, karabiner, omniwm, vscode, zed, yazi

---

## File Transfer Methods

All commands below are run **from your macOS terminal**.

### Method 1: scp (Simple - one-time transfers)

```bash
# Copy single file
scp /path/to/local/file.txt jiny@SERVER_IP:/remote/path/

# Copy directory recursively
scp -r /path/to/local/dir jiny@SERVER_IP:/remote/path/

# Copy to home directory
scp -r /path/to/local/dir jiny@SERVER_IP:~/
```

### Method 2: rsync (Recommended - better for large dirs)

```bash
# Copy directory with progress, compression, and resume support
rsync -avz --progress /path/to/local/dir/ jiny@SERVER_IP:/remote/path/

# Exclude certain files/patterns
rsync -avz --progress --exclude='node_modules' --exclude='.git' \
  /path/to/local/dir/ jiny@SERVER_IP:/remote/path/

# Dry run first to see what will be copied
rsync -avz --progress --dry-run /path/to/local/dir/ jiny@SERVER_IP:/remote/path/
```

**Key rsync options:**
- `-a` archive mode (preserve permissions, timestamps, etc.)
- `-v` verbose
- `-z` compress during transfer
- `--progress` show progress
- `--exclude` skip patterns

### Method 3: Use SSH config (More convenient)

**On your Mac**, add to `~/.ssh/config`:

```
Host myserver
  HostName SERVER_IP
  User jiny
  ServerAliveInterval 60
  ServerAliveCountMax 3
```

**Then use simpler commands:**

```bash
scp -r /path/to/local/dir myserver:/remote/path/
rsync -avz --progress /path/to/local/dir/ myserver:/remote/path/
```

### Method 4: Pull from VM (copy server → Mac)

```bash
# From Mac terminal
scp -r jiny@SERVER_IP:/remote/path/dir /local/dest/

# Or using SSH config
scp -r myserver:/remote/path/dir /local/dest/
```

### Common use cases for dotfiles

```bash
# Copy entire dotfiles directory
rsync -avz --progress ~/projects/dotfiles/ myserver:~/projects/dotfiles/

# Copy SSH public key
scp ~/.ssh/id_ed25519.pub myserver:~/.ssh/
```
