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

# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"
# Set name of the theme to load --- if set to "random", it will
# load a random theme each time oh-my-zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
# ZSH_THEME="powerlevel10k/powerlevel10k"

# Set list of themes to pick from when loading at random
# Setting this variable when ZSH_THEME=random will cause zsh to load
# a theme from this variable instead of looking in $ZSH/themes/
# If set to an empty array, this variable will have no effect.
# ZSH_THEME_RANDOM_CANDIDATES=( "robbyrussell" "agnoster" )

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion.
# Case-sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

# Uncomment one of the following lines to change the auto-update behavior
# zstyle ':omz:update' mode disabled  # disable automatic updates
# zstyle ':omz:update' mode auto      # update automatically without asking
# zstyle ':omz:update' mode reminder  # just remind me to update when it's time

# Uncomment the following line to change how often to auto-update (in days).
# zstyle ':omz:update' frequency 13

# Uncomment the following line if pasting URLs and other text is messed up.
# DISABLE_MAGIC_FUNCTIONS="true"

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
# You can also set it to another string to have that shown instead of the default red dots.
# e.g. COMPLETION_WAITING_DOTS="%F{yellow}waiting...%f"
# Caution: this setting can cause issues with multiline prompts in zsh < 5.7.1 (see #5765)
# COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# You can set one of the optional three formats:
# "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# or set a custom format using the strftime function format specifications,
# see 'man strftime' for details.
# HIST_STAMPS="mm/dd/yyyy"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Which plugins would you like to load?
# Standard plugins can be found in $ZSH/plugins/
# Custom plugins may be added to $ZSH_CUSTOM/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(git zsh-syntax-highlighting zsh-autosuggestions rust)



source $ZSH/oh-my-zsh.sh

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
lazy_load_nvm() {
  unset -f node npm nvm iflow nvim ts-node opencode
  export NVM_DIR="$HOME/.nvm"
  [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
  # [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
}
node() { lazy_load_nvm; node "$@"; }
npm() { lazy_load_nvm; npm "$@"; }
nvm() { lazy_load_nvm; nvm "$@"; }
iflow() { lazy_load_nvm; iflow "$@"; }
ts-node() { lazy_load_nvm; ts-node "$@"; }
nvim() { lazy_load_nvm; nvim "$@"; }
opencode() {lazy_load_nvm; opencode "$@"; }

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
command -v starship &>/dev/null && eval "$(starship init zsh)"
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
