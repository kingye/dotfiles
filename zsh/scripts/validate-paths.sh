#!/bin/bash
# 验证路径推断脚本

set -e

echo "=============================================="
echo "        Path Validation Script"
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

# 1. 检查当前目录
log_info "1. Current directory analysis:"
echo "   Current dir: $(pwd)"
echo "   Script location: $(dirname "${BASH_SOURCE[0]}")"
echo "   Script full path: $(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo ""

# 2. 检查.zshrc路径推断逻辑
log_info "2. Testing .zshrc path inference logic..."

# 模拟.zshrc的路径推断逻辑
ZSHRC_TEST_FILE="/tmp/test-zshrc.zsh"
cat > "$ZSHRC_TEST_FILE" << 'EOF'
#!/bin/zsh
# 测试路径推断逻辑

# 自动检测dotfiles目录（从.zshrc文件位置推断）
ZSHRC_PATH="${(%):-%x}"

if [[ -n "$ZSHRC_PATH" ]] && [[ -f "$ZSHRC_PATH" ]]; then
    ZSH_DIR="$(cd "$(dirname "$ZSHRC_PATH")" && pwd)"
    DOTFILES_ROOT="$(cd "$ZSH_DIR/.." && pwd)"
    
    # 验证这看起来像dotfiles目录
    if [[ -d "$DOTFILES_ROOT/zsh" ]] && [[ -f "$DOTFILES_ROOT/zsh/.zshrc" ]]; then
        echo "SUCCESS: Found dotfiles at: $DOTFILES_ROOT"
    else
        echo "ERROR: Invalid dotfiles structure at: $DOTFILES_ROOT"
    fi
else
    echo "ERROR: Could not determine .zshrc path"
fi
EOF

chmod +x "$ZSHRC_TEST_FILE"

# 在不同位置测试
echo "   Testing with current .zshrc:"
zsh -c "source $ZSHRC_TEST_FILE"

echo ""

# 3. 检查setup-starship.zsh的路径推断
log_info "3. Testing setup-starship.zsh path inference..."

# 设置一个测试环境
export DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
echo "   DOTFILES_DIR set to: $DOTFILES_DIR"

if [[ -f "$DOTFILES_DIR/zsh/scripts/setup-starship.zsh" ]]; then
    echo "   setup-starship.zsh found at: $DOTFILES_DIR/zsh/scripts/setup-starship.zsh"
    # 运行一小部分测试
    echo "   Testing basic functionality..."
    temp_output=$(zsh -c "export DOTFILES_DIR='$DOTFILES_DIR'; source '$DOTFILES_DIR/zsh/scripts/setup-starship.zsh'; echo 'Setup completed'" 2>&1 | head -5)
    echo "   Output preview: $temp_output"
else
    log_warning "   setup-starship.zsh not found"
fi

echo ""

# 4. 验证关键目录结构
log_info "4. Verifying critical directory structure:"

REQUIRED_PATHS=(
    "$DOTFILES_DIR/zsh/.zshrc"
    "$DOTFILES_DIR/zsh/scripts/setup-starship.zsh"
    "$DOTFILES_DIR/zsh/scripts/setup-zsh-environment.sh"
    "$DOTFILES_DIR/zsh/sheldon/plugins.toml"
    "$DOTFILES_DIR/zsh/starship/starship.toml"
)

all_good=true
for path in "${REQUIRED_PATHS[@]}"; do
    if [[ -f "$path" ]]; then
        echo "   ✓ $(basename "$path")"
    else
        log_error "   ✗ Missing: $(basename "$path")"
        all_good=false
    fi
done

echo ""
echo "=============================================="

if $all_good; then
    log_success "Path validation PASSED!"
    echo ""
    echo "Next steps:"
    echo "1. Run setup script: ./zsh/scripts/setup-zsh-environment.sh"
    echo "2. Reload shell: source ~/.zshrc"
    echo "3. Test: sheldon --version"
else
    log_error "Path validation FAILED!"
    echo ""
    echo "Issues found:"
    echo "1. Check dotfiles directory structure"
    echo "2. Ensure .zshrc is in dotfiles/zsh/.zshrc"
    echo "3. Run this script from the dotfiles directory"
fi

echo "=============================================="