
## 在 Git 中撤销已提交但未推送的更改并同步远程分支，需执行以下步骤：

### 解决方案：
1. **撤销最后一次提交（保留更改作为未暂存修改）**：
   ```bash
   git reset --soft HEAD~1
   ```

2. **完全丢弃最后一次提交的更改**：
   ```bash
   git reset --hard HEAD~1
   ```

3. **强制同步本地分支与远程分支**：
   ```bash
   git fetch origin
   git reset --hard origin/$(git branch --show-current)
   ```

### 注意事项：
- `HEAD~1` 表示撤销最近 1 次提交，需撤销多次提交时替换数字（如 `HEAD~3`）
- 执行 `reset --hard` 会**永久丢弃本地修改**，操作前请确认
- 最后一步会强制使本地分支与远程分支完全一致

### 完整流程（推荐）：
```bash
# 1. 撤销最近提交（保留修改）
git reset --soft HEAD~1

# 2. 拉取远程最新状态
git fetch origin

# 3. 强制同步本地分支
git reset --hard origin/$(git branch --show-current)
```

请根据是否需要保留修改选择 `--soft` 或 `--hard` 参数。下一步是否需要我解释具体命令的作用？


