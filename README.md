# Terminal Settings

## iTerm2 color scheme

- find color scheme in https://iterm2colorschemes.com/
- download the `*.itermcolors` file
- open iTerm2 Settings
- goto profiles - colors - import...

## Install zsh theme

- `git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ~/.oh-my-zsh/custom/themes/powerlevel10k/`
- edit `~/.zshrc` 
  ```
  ZSH_THEM="powerlevel10k/powerlevel10k"
  ```

## Install zsh plugins

- `git clone --depth=1 https://github.com/zsh-users/zsh-autosuggestions.git ~/.oh-my-zsh/custom/plugins/zsh-autosuggestions`
- `git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ~/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting`
- edit `~/.zshrc`
  ```
  plugins=(git zsh-syntax-highlighting zsh-autosuggestions kubectl docker vi-mode nvm)
  ```

## Install tmux

- `git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm`

