## Configuration file

It is located at `~/.tmux.conf`

## plugins

```bash
# 安装新插件
prefix + I  # (大写的i，即Shift+i)

# 更新所有插件
prefix + U

# 卸载不再需要的插件
prefix + alt + u
```
## restore sessions

- 保存当前会话：`prefix + Ctrl-s`
- 恢复会话：`prefix + Ctrl-r`

## Shortcuts

`<leader>` is now C-s (default is C-b)

## 命令模式

- `<leader> + ':` - 进入命令模式

## 管理会话 （session）

- `<leader>+d`: detach the session
- `<leader>+s`: list all sessions
- '<leader>+$': rename session

## 管理窗口 （window）

在tmux中切换窗口可以使用以下快捷键：

1. `<leader>` + `c`: 创建一个新窗口
1. `<leader>` + `数字`: 直接切换到指定编号的窗口（例如 `<leader> 0` 切换到0号窗口）
1. `<leader>` + `n`: 切换到下一个窗口
1. `<leader>` + `p`: 切换到上一个窗口
1. `<leader>` + `w`: 显示窗口列表并交互式选择
1. `<leader>` + `l`: 切换到最后一个使用的窗口
1. `<leader>` + `f`: 寻找窗口
1. `<leader>` + `&`: 关闭当前窗口
1. `:move-pane -t 1.0`: move pane to window 1 pane 0

## 管理窗格 （pane）

1. `<leader> + "`: 垂直分割窗格'
2. `<leader> + %`: 水平分割窗格'
3. `<leader> + h`: 向左移动到下一个窗格
4. `<leader> + j`: 向下移动到下一个窗格
5. `<leader> + k`: 向上移动到下一个窗格
6. `<leader> + l`: 向右移动到下一个窗格
7. `<leader> + ' '`: 切换窗格布局
8. `<leader> + {`: 向左移动窗格
9. `<leader> + }`: 向右移动窗格
10. '<leader> + x': 关闭当前窗格
11. `:resize-pane -L 10`: resize split
12. `<leader> + z`: 最大化/还原当前窗格

[tmux-pain-control](https://github.com/tmux-plugins/tmux-pain-control)

## 终端内导航

1. `<leader>[` + h,j,k,l - 翻页


## references

- [tmux cheat sheet](https://tmuxcheatsheet.com/)
- [awesome-tmux](https://github.com/rothgar/awesome-tmux)
