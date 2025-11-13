#!/bin/bash

set -e

REMOTE_PATH="ProtonDrive:MyPublic"
LOCAL_PATH="$HOME/MyPublic"

echo "==> [$(date)] 开始执行 MyPublic 单向同步任务..."
echo "    -> 源 (云端): $REMOTE_PATH"
echo "    -> 目标 (本地): $LOCAL_PATH"
echo "    -> 注意: 本地多余的文件将被删除以匹配云端。"
echo ""

mkdir -p "$LOCAL_PATH"

rclone sync "$REMOTE_PATH" "$LOCAL_PATH" --progress

echo ""
echo "==> [$(date)] MyPublic 同步成功完成！"

notify-send -a "MyPublic Sync" -i "folder-download" \
    "✅ MyPublic 同步完成" \
    "已从 $REMOTE_PATH 更新到本地。"

exit 0
