#!/bin/bash
# zsh环境完整安装脚本
# 安装sheldon插件管理器和starship提示符、eza、zoxide

set -e

echo "=============================================="
echo "       ZSH Environment Setup Script"
echo "=============================================="
echo ""

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 日志函数
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# 安装sheldon
install_sheldon() {
    log_info "Installing sheldon plugin manager..."
    
    # 检查是否已安装
    if command -v sheldon &>/dev/null; then
        log_success "Sheldon already installed: $(sheldon --version)"
        return 0
    fi
    
    # macOS with Homebrew
    if [[ "$OSTYPE" == "darwin"* ]] && command -v brew &>/dev/null; then
        brew install sheldon
        
    # Linux with Cargo
    elif command -v cargo &>/dev/null; then
        cargo install sheldon
        
    # Debian/Ubuntu
    elif [[ -f /etc/debian_version ]] && command -v apt &>/dev/null; then
        # 检查是否已安装
        if ! dpkg -l | grep -q sheldon; then
            # 安装依赖
            sudo apt update
            sudo apt install -y curl git build-essential
            
            # 安装Rust（如果未安装）
            if ! command -v rustc &>/dev/null; then
                curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
                source "$HOME/.cargo/env"
            fi
            
            cargo install sheldon
        fi
        
    else
        log_error "Unsupported platform for automatic sheldon installation"
        echo "Please install sheldon manually:"
        echo "  macOS: brew install sheldon"
        echo "  Linux: cargo install sheldon"
        return 1
    fi
    
    if command -v sheldon &>/dev/null; then
        log_success "Sheldon installed: $(sheldon --version)"
        return 0
    else
        log_error "Sheldon installation failed"
        return 1
    fi
}

# 安装starship
install_starship() {
    log_info "Installing starship prompt..."
    
    # 检查是否已安装
    if command -v starship &>/dev/null; then
        log_success "Starship already installed: $(starship --version)"
        return 0
    fi
    
    # macOS with Homebrew
    if [[ "$OSTYPE" == "darwin"* ]] && command -v brew &>/dev/null; then
        brew install starship
        
    # Linux with official installer
    elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
        curl -fsSL https://starship.rs/install.sh | sh -s -- --yes
        
    # Other platforms with Cargo
    elif command -v cargo &>/dev/null; then
        cargo install starship --locked
        
    else
        log_error "Unsupported platform for automatic starship installation"
        echo "Please install starship manually:"
        echo "  curl -fsSL https://starship.rs/install.sh | sh"
        return 1
    fi
    
    if command -v starship &>/dev/null; then
        log_success "Starship installed: $(starship --version)"
        return 0
    else
        log_error "Starship installation failed"
        return 1
    fi
}

# 安装eza
install_eza() {
    log_info "Installing eza (modern ls replacement)..."
    
    # 检查是否已安装
    if command -v eza &>/dev/null; then
        log_success "eza already installed: $(eza --version 2>/dev/null | head -1)"
        return 0
    fi
    
    # macOS with Homebrew
    if [[ "$OSTYPE" == "darwin"* ]] && command -v brew &>/dev/null; then
        brew install eza
    elif command -v cargo &>/dev/null; then
        cargo install eza
    else
        log_warning "Cannot install eza automatically. Please install manually:"
        log_info "  macOS: brew install eza"
        log_info "  Linux: cargo install eza"
        return 1
    fi
    
    if command -v eza &>/dev/null; then
        log_success "eza installed: $(eza --version 2>/dev/null | head -1)"
        return 0
    else
        log_warning "eza installation failed or not fully functional"
        return 1
    fi
}

# 安装zoxide
install_zoxide() {
    log_info "Installing zoxide (smart cd replacement)..."
    
    # 检查是否已安装
    if command -v zoxide &>/dev/null; then
        log_success "zoxide already installed: $(zoxide --version 2>/dev/null | head -1)"
        return 0
    fi
    
    # macOS with Homebrew
    if [[ "$OSTYPE" == "darwin"* ]] && command -v brew &>/dev/null; then
        brew install zoxide
    elif command -v cargo &>/dev/null; then
        cargo install zoxide
    else
        log_warning "Cannot install zoxide automatically. Please install manually:"
        log_info "  macOS: brew install zoxide"
        log_info "  Linux: cargo install zoxide"
        return 1
    fi
    
    if command -v zoxide &>/dev/null; then
        log_success "zoxide installed: $(zoxide --version 2>/dev/null | head -1)"
        return 0
    else
        log_warning "zoxide installation failed or not fully functional"
        return 1
    fi
}

# 设置配置符号链接
setup_config_symlinks() {
    log_info "Setting up configuration symlinks..."
    
    # 确保XDG配置目录存在（sheldon需要）
    CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}"
    mkdir -p "$CONFIG_DIR"
    
    # 获取dotfiles根目录
    # 脚本位于dotfiles/zsh/scripts/，所以向上两级到dotfiles根目录
    SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    DOTFILES_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
    
    # 验证这看起来像dotfiles目录
    if [[ ! -d "$DOTFILES_ROOT/zsh" ]] || [[ ! -f "$DOTFILES_ROOT/zsh/.zshrc" ]]; then
        log_warning "Dotfiles structure not found at: $DOTFILES_ROOT"
        log_warning "Trying alternative detection..."
        
        # 尝试从HOME目录寻找常见的dotfiles位置
        for possible_dir in "$HOME/projects/dotfiles" "$HOME/dotfiles" "$HOME/.dotfiles" "$HOME/config/dotfiles"; do
            if [[ -d "$possible_dir/zsh" ]] && [[ -f "$possible_dir/zsh/.zshrc" ]]; then
                DOTFILES_ROOT="$possible_dir"
                log_success "Found dotfiles at: $DOTFILES_ROOT"
                break
            fi
        done
        
        if [[ ! -d "$DOTFILES_ROOT/zsh" ]]; then
            log_error "Cannot find dotfiles directory. Please run from dotfiles directory."
            return 1
        fi
    fi
    
    # 1. 创建sheldon配置目录和符号链接
    SHELDON_CONFIG_DIR="$CONFIG_DIR/sheldon"
    DOTFILES_SHELDON_PLUGINS="$DOTFILES_ROOT/zsh/sheldon/plugins.toml"
    
    mkdir -p "$SHELDON_CONFIG_DIR"
    
    if [[ ! -L "$SHELDON_CONFIG_DIR/plugins.toml" ]] || \
       [[ "$(readlink "$SHELDON_CONFIG_DIR/plugins.toml")" != "$DOTFILES_SHELDON_PLUGINS" ]]; then
        log_info "Creating sheldon config symlink..."
        ln -sf "$DOTFILES_SHELDON_PLUGINS" "$SHELDON_CONFIG_DIR/plugins.toml"
        log_success "Sheldon symlink created: $SHELDON_CONFIG_DIR/plugins.toml -> $DOTFILES_SHELDON_PLUGINS"
    else
        log_success "Sheldon symlink already exists and is correct"
    fi
    
    # 2. starship配置
    STARSHP_CONFIG="$CONFIG_DIR/starship.toml"
    DOTFILES_STARSHIP="$DOTFILES_ROOT/zsh/starship/starship.toml"
    
    if [[ ! -L "$STARSHP_CONFIG" ]] || \
       [[ "$(readlink "$STARSHP_CONFIG")" != "$DOTFILES_STARSHIP" ]]; then
        log_info "Creating starship config symlink..."
        ln -sf "$DOTFILES_STARSHIP" "$STARSHP_CONFIG"
        log_success "Starship symlink created: $STARSHP_CONFIG -> $DOTFILES_STARSHIP"
    else
        log_success "Starship symlink already exists and is correct"
    fi
    
    # 显示重要的目录信息
    echo ""
    log_info "Important directories:"
    log_info "  Dotfiles root: $DOTFILES_ROOT"
    log_info "  Config dir: $CONFIG_DIR"
    log_info "  Sheldon dir: $SHELDON_CONFIG_DIR"
    
    # 显示已创建的符号链接
    echo ""
    log_info "Created symlinks:"
    if [[ -L "$SHELDON_CONFIG_DIR/plugins.toml" ]]; then
        log_info "  ✓ sheldon/plugins.toml -> $(readlink "$SHELDON_CONFIG_DIR/plugins.toml")"
    fi
    if [[ -L "$STARSHP_CONFIG" ]]; then
        log_info "  ✓ starship.toml -> $(readlink "$STARSHP_CONFIG")"
    fi
}

# 验证安装
verify_installation() {
    log_info "Verifying installations..."
    
    local success=true
    
    # 检查sheldon
    if command -v sheldon &>/dev/null; then
        log_success "✓ Sheldon: $(sheldon --version)"
    else
        log_error "✗ Sheldon not installed"
        success=false
    fi
    
    # 检查starship
    if command -v starship &>/dev/null; then
        log_success "✓ Starship: $(starship --version)"
    else
        log_error "✗ Starship not installed"
        success=false
    fi
    
    # 检查eza
    if command -v eza &>/dev/null; then
        log_success "✓ eza: $(eza --version 2>/dev/null | head -1)"
    else
        log_warning "⚠ eza not installed (ll alias will use ls -l)"
    fi
    
    # 检查zoxide
    if command -v zoxide &>/dev/null; then
        log_success "✓ zoxide: $(zoxide --version 2>/dev/null | head -1)"
    else
        log_warning "⚠ zoxide not installed (smart cd functionality unavailable)"
    fi
    
    # 检查符号链接
    STARSHP_CONFIG="${XDG_CONFIG_HOME:-$HOME/.config}/starship.toml"
    if [[ -L "$STARSHP_CONFIG" ]]; then
        log_success "✓ Starship config symlink exists"
    else
        log_warning "⚠ Starship config symlink may be missing"
    fi
    
    if [[ "$success" == true ]]; then
        log_success "All core verifications passed!"
        return 0
    else
        log_error "Some core verifications failed"
        return 1
    fi
}

# 主函数
main() {
    echo ""
    log_info "Starting ZSH environment setup..."
    echo ""
    
    # 安装sheldon
    if ! install_sheldon; then
        log_error "Sheldon installation failed, aborting..."
        exit 1
    fi
    
    echo ""
    
    # 安装starship
    if ! install_starship; then
        log_error "Starship installation failed, aborting..."
        exit 1
    fi
    
    echo ""
    
    # 安装eza (现代ls替代品)
    if ! install_eza; then
        log_warning "eza installation failed, continuing without it..."
    fi
    
    echo ""
    
    # 安装zoxide (智能cd替代品)
    if ! install_zoxide; then
        log_warning "zoxide installation failed, continuing without it..."
    fi
    
    echo ""
    
    # 设置符号链接
    setup_config_symlinks
    
    echo ""
    
    # 验证安装
    if ! verify_installation; then
        log_warning "Some installations may not be complete"
    fi
    
    echo ""
    log_success "ZSH environment setup completed!"
    echo ""
    
    # 获取dotfiles根目录用于显示路径
    SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    DOTFILES_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
    
    # 验证路径（在显示前）
    if [[ ! -d "$DOTFILES_ROOT/zsh" ]]; then
        log_warning "Cannot determine dotfiles root for next steps"
        DOTFILES_ROOT="[unknown - please find manually]"
    fi
    
    # 显示下一步
    echo "=============================================="
    echo "            Next Steps"
    echo "=============================================="
    echo ""
    echo "1. Reload your shell configuration:"
    echo "   source ~/.zshrc"
    echo ""
    echo "2. Test the new setup:"
    echo "   sheldon --version"
    echo "   starship --version"
    echo "   eza --version"
    echo "   zoxide --version"
    echo ""
    echo "3. Manage plugins with sheldon:"
    echo "   Edit: $DOTFILES_ROOT/zsh/sheldon/plugins.toml"
    echo "   Update: sheldon lock --update"
    echo ""
    echo "4. Customize starship prompt:"
    echo "   Edit: $DOTFILES_ROOT/zsh/starship/starship.toml"
    echo "   Docs: https://starship.rs/config/"
    echo ""
    echo "5. Test the new aliases and tools:"
    echo "   ll         # Uses eza if available, otherwise ls -l"
    echo "   z <dir>    # zoxide smart directory navigation"
    echo "   zi <dir>   # zoxide interactive search"
    echo ""
    echo "6. To remove oh-my-zsh completely (optional):"
    echo "   rm -rf ~/.oh-my-zsh"
    echo ""
    echo "=============================================="
}

# 执行主函数
main "$@"