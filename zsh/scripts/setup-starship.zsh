#!/bin/zsh
# starship初始化脚本 - 简化版
# 自动检测路径并创建符号链接

# 设置配置路径
# 优先使用环境变量，否则从脚本位置推断
if [[ -n "$DOTFILES_DIR" ]] && [[ -d "$DOTFILES_DIR" ]]; then
    echo "Using DOTFILES_DIR from environment: $DOTFILES_DIR"
else
    # 从脚本位置推断dotfiles目录
    # 获取当前脚本的绝对路径

    if [[ -n "$ZSH_ARGZERO" ]]; then

        # Zsh方式



        local script_path="${(%):-%x}"

        SCRIPT_DIR="$(cd "$(dirname "$script_path")" && pwd)"

    else

        # 回退方案



        SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

    fi

    

    DOTFILES_DIR="$(dirname "$(dirname "$SCRIPT_DIR")")"

    echo "Inferred dotfiles directory: $DOTFILES_DIR"

fi



# 验证目录和配置文件



if [[ ! -d "$DOTFILES_DIR" ]]; then

    echo "Error: Dotfiles directory not found: $DOTFILES_DIR"

    return 1

fi



# 配置文件路径

DOTFILES_CONFIG="$DOTFILES_DIR/zsh/starship/starship.toml"

TARGET_CONFIG="${XDG_CONFIG_HOME:-$HOME/.config}/starship.toml"



# 检查源文件是否存在

if [[ ! -f "$DOTFILES_CONFIG" ]]; then

    echo "Error: Starship config not found at: $DOTFILES_CONFIG"

    return 1

fi



# 确保目标目录存在



CONFIG_DIR="$(dirname "$TARGET_CONFIG")"

if [[ ! -d "$CONFIG_DIR" ]]; then

    echo "Creating config directory: $CONFIG_DIR"

    mkdir -p "$CONFIG_DIR"

fi



# 创建或更新符号链接



if [[ -L "$TARGET_CONFIG" ]]; then

    CURRENT_TARGET="$(readlink "$TARGET_CONFIG")"

    if [[ "$CURRENT_TARGET" != "$DOTFILES_CONFIG" ]]; then

        echo "Updating symlink: $TARGET_CONFIG -> $DOTFILES_CONFIG"

        ln -sf "$DOTFILES_CONFIG" "$TARGET_CONFIG"

    else

        echo "Symlink already correct"

    fi

elif [[ -f "$TARGET_CONFIG" ]]; then

    echo "Backing up existing config: $TARGET_CONFIG -> $TARGET_CONFIG.backup"

    mv "$TARGET_CONFIG" "$TARGET_CONFIG.backup"

    echo "Creating symlink: $TARGET_CONFIG -> $DOTFILES_CONFIG"

    ln -sf "$DOTFILES_CONFIG" "$TARGET_CONFIG"

else

    echo "Creating symlink: $TARGET_CONFIG -> $DOTFILES_CONFIG"

    ln -sf "$DOTFILES_CONFIG" "$TARGET_CONFIG"

fi



# 设置环境变量并初始化starship



export STARSHIP_CONFIG="$TARGET_CONFIG"



if command -v starship &>/dev/null; then

    eval "$(starship init zsh)"

    echo "Starship initialized successfully"

else

    echo "Warning: Starship not installed"

    echo "Install with: ./zsh/scripts/install-starship.sh"

fi