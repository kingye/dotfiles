# ~/.zshrc
# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
# if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
#   source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
# fi

# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:/usr/local/bin:$PATH

# Cargo/Rust environment
[[ -f "$HOME/.cargo/env" ]] && . "$HOME/.cargo/env"

# Limit cargo parallelism on Linux (low-RAM cloud servers)
if [[ "$OSTYPE" == "linux-gnu"* ]]; then
  export CARGO_BUILD_JOBS=1
fi

# Starship提示符配置（必须在sheldon之前）
# 自动检测dotfiles目录（从.zshrc文件位置推断）
if [[ -z "$DOTFILES_DIR" ]]; then
    # 在zsh中，${(%):-%x} 获取当前源文件的路径
    ZSHRC_PATH="${(%):-%x}"
    
    # .zshrc位于dotfiles/zsh/.zshrc
    # 所以向上两级获取dotfiles根目录
    if [[ -n "$ZSHRC_PATH" ]] && [[ -f "$ZSHRC_PATH" ]]; then
        ZSH_DIR="$(cd "$(dirname "$ZSHRC_PATH")" && pwd)"
        DOTFILES_ROOT="$(cd "$ZSH_DIR/.." && pwd)"
        
        # 验证这看起来像dotfiles目录
        if [[ -d "$DOTFILES_ROOT/zsh" ]] && [[ -f "$DOTFILES_ROOT/zsh/.zshrc" ]]; then
            export DOTFILES_DIR="$DOTFILES_ROOT"
        fi
    fi
fi

# 确保XDG配置目录存在（sheldon需要，但符号链接由安装脚本创建）
CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}"
mkdir -p "$CONFIG_DIR"

# 加载starship配置
if [[ -n "$DOTFILES_DIR" ]] && [[ -f "$DOTFILES_DIR/zsh/scripts/setup-starship.zsh" ]]; then
    source "$DOTFILES_DIR/zsh/scripts/setup-starship.zsh"
else
    # 回退到传统初始化
    export STARSHIP_CONFIG="${XDG_CONFIG_HOME:-$HOME/.config}/starship.toml"
    if [[ -n "$DOTFILES_DIR" ]]; then
        [[ ! -f "$STARSHIP_CONFIG" ]] && \
            ln -sf "$DOTFILES_DIR/zsh/starship/starship.toml" "$STARSHIP_CONFIG" 2>/dev/null || true
    fi
    command -v starship &>/dev/null && eval "$(starship init zsh)"
fi

# Sheldon插件管理
if command -v sheldon &>/dev/null; then
    # 检查sheldon配置是否存在
    SHELDON_CONFIG="${XDG_CONFIG_HOME:-$HOME/.config}/sheldon/plugins.toml"
    
    if [[ ! -f "$SHELDON_CONFIG" ]] && [[ ! -L "$SHELDON_CONFIG" ]]; then
        echo "⚠️  Sheldon config not found at: $SHELDON_CONFIG"
        echo "   Run setup script: ./zsh/scripts/setup-zsh-environment.sh"
        echo "   Or create symlink manually:"
        echo "   mkdir -p ~/.config/sheldon"
        echo "   ln -sf \"\$DOTFILES_DIR/zsh/sheldon/plugins.toml\" \"$SHELDON_CONFIG\""
        
        # 尝试自动创建（如果知道DOTFILES_DIR）
        if [[ -n "$DOTFILES_DIR" ]] && [[ -f "$DOTFILES_DIR/zsh/sheldon/plugins.toml" ]]; then
            echo "   Attempting to create symlink automatically..."
            mkdir -p "$(dirname "$SHELDON_CONFIG")"
            ln -sf "$DOTFILES_DIR/zsh/sheldon/plugins.toml" "$SHELDON_CONFIG" 2>/dev/null && \
                echo "   ✓ Symlink created successfully"
        fi
    fi
    
    # 尝试加载sheldon
    if eval "$(sheldon source 2>/dev/null)"; then
        # 成功加载
        :
    else
        echo "⚠️  Sheldon failed to load plugins"
        echo "   Check config: $SHELDON_CONFIG"
        echo "   Run: sheldon lock --update"
    fi
else
    echo "Sheldon not installed. Run setup script or install manually."
    
    # 如果没有sheldon，手动加载其他插件（如果存在）
    [[ -f ~/.local/share/sheldon/repos/github.com/zdharma-continuum/fast-syntax-highlighting/fast-syntax-highlighting.plugin.zsh ]] && \
        source ~/.local/share/sheldon/repos/github.com/zdharma-continuum/fast-syntax-highlighting/fast-syntax-highlighting.plugin.zsh
    
    [[ -f ~/.local/share/sheldon/repos/github.com/marlonrichert/zsh-autocomplete/zsh-autocomplete.plugin.zsh ]] && \
        source ~/.local/share/sheldon/repos/github.com/marlonrichert/zsh-autocomplete/zsh-autocomplete.plugin.zsh
fi

# switch on zsh line editor(zle) vi mode
bindkey -v
function zle-line-init zle-keymap-select {
    RPS1="${${KEYMAP/vicmd/NORMAL}/(main|viins)/INSERT}"
    zle reset-prompt

    if [[ ${KEYMAP} == vicmd ]] || [[ $1 = 'block' ]]; then
		echo -ne '\e[1 q'
	elif [[ ${KEYMAP} == main ]] || [[ ${KEYMAP} == viins ]] || [[ ${KEYMAP} = '' ]] || [[ $1 = 'beam' ]]; then
		echo -ne '\e[5 q'
	fi
}
zle -N zle-line-init
zle -N zle-keymap-select

# Use beam shape cursor on startup.
echo -ne '\e[5 q'

# Use beam shape cursor for each new prompt.
preexec() {
	echo -ne '\e[5 q'
}

_fix_cursor() {
	echo -ne '\e[5 q'
}
precmd_functions+=(_fix_cursor)

KEYTIMEOUT=1

# Sync ZLE yank/paste with system clipboard (macOS only)
if [[ "$OSTYPE" == "darwin"* ]]; then
  function x11-clip-wrap-widgets() {
      local copy_or_paste=$1
      shift
      for widget in $@; do
          if [[ $copy_or_paste == "copy" ]]; then
              eval "
              function _x11-clip-wrapped-$widget() {
                  zle .$widget
                  echo -n \$CUTBUFFER | pbcopy
              }
              "
          else
              eval "
              function _x11-clip-wrapped-$widget() {
                  CUTBUFFER=\$(pbpaste)
                  zle .$widget
              }
              "
          fi
          zle -N $widget _x11-clip-wrapped-$widget
      done
  }

  # Wrap yank operations to copy to system clipboard
  x11-clip-wrap-widgets copy vi-yank vi-yank-eol vi-delete vi-backward-delete-char vi-delete-char vi-change vi-change-eol vi-change-whole-line vi-substitute

  # Wrap paste operations to paste from system clipboard
  x11-clip-wrap-widgets paste vi-put-after vi-put-before put-replace-selection
fi

# User configuration

# export MANPATH="/usr/local/man:$MANPATH"

# You may need to manually set your language environment
# export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
# if [[ -n $SSH_CONNECTION ]]; then
#   export EDITOR='vim'
# else
#   export EDITOR='mvim'
# fi

# Compilation flags
# export ARCHFLAGS="-arch x86_64"

# Set personal aliases, overriding those provided by oh-my-zsh libs,
# plugins, and themes. Aliases can be placed here, though oh-my-zsh
# users are encouraged to define aliases within the ZSH_CUSTOM folder.
# For a full list of active aliases, run `alias`.
#
# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

# Source local secrets (API keys, tokens — not tracked in git)
[[ -f ~/.zshrc.local ]] && source ~/.zshrc.local

# Homebrew
if [[ -f /opt/homebrew/bin/brew ]]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
elif [[ -f /home/linuxbrew/.linuxbrew/bin/brew ]]; then
  eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
fi

# Tool inits (only if installed)
command -v zoxide &>/dev/null && eval "$(zoxide init zsh)"
if command -v atuin &>/dev/null; then
  export ATUIN_NOBIND="true"
  eval "$(atuin init zsh)"
  bindkey '^r' atuin-up-search-viins
fi

alias g='git'
# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
# [[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# setup fzf shell integration
if command -v fzf &>/dev/null; then
  FZF_ZSH_OUTPUT="$(fzf --zsh 2>/dev/null)"
  if [[ $? -eq 0 && -n "$FZF_ZSH_OUTPUT" ]]; then
    eval "$FZF_ZSH_OUTPUT"
  elif [[ -f ~/.fzf.zsh ]]; then
    source ~/.fzf.zsh
  elif [[ -f /usr/share/doc/fzf/examples/key-bindings.zsh ]]; then
    source /usr/share/doc/fzf/examples/key-bindings.zsh
  fi
  unset FZF_ZSH_OUTPUT
fi


alias ls="eza --icons=always"
if command -v eza &>/dev/null; then
    alias ll="eza -l --icons=always"
else
    alias ll="ls -l"
fi
if [[ -f /etc/os-release ]] && source /etc/os-release && [[ "$ID" == "debian" ]];
then
  # Debian 12 specific settings
  export PATH="$HOME/.opencode/bin:$HOME/.local/bin:$HOME/.bun/bin:$PATH"
else
  # Not Debian 12
  export PATH="$HOME/.local/bin:$HOME/.bun/bin:$PATH"
fi
# Atuin env (curl-installed atuin puts binary here)
[[ -f "$HOME/.atuin/bin/env" ]] && . "$HOME/.atuin/bin/env"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
