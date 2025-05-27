#!/bin/bash
# 默认配置
DEFAULT_HOST="10.239.116.147"
DEFAULT_DEST="projects/escape"

# 获取用户输入参数
remote_host=${1:-$DEFAULT_HOST}
dest_path=${2:-$DEFAULT_DEST}

# 显示当前配置
echo "使用远程主机: ${remote_host}"
echo "目标路径: ${dest_path}"
echo "--------------------------------"

# 执行同步
rsync -azP --delete \
    --exclude='target' \
    --exclude=.git \
    ./ "${remote_host}:${dest_path}"

