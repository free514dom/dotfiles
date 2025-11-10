#!/bin/bash

set -e

REMOTE_PATH="GDrive_2TB:Music"
LOCAL_PATH="$HOME/Music"

echo "==> [$(date)] 开始执行音乐库单向同步任务..."
echo "    -> 源 (云端): $REMOTE_PATH"
echo "    -> 目标 (本地): $LOCAL_PATH"
echo "    -> 注意: 本地多余的文件将被删除以匹配云端。"
echo ""

mkdir -p "$LOCAL_PATH"

rclone sync "$REMOTE_PATH" "$LOCAL_PATH" --progress

echo ""
echo "==> [$(date)] 音乐库同步成功完成！"

notify-send -a "Music Sync" -i "folder-music" \
    "✅ 音乐库同步完成" \
    "已从 $REMOTE_PATH 更新到本地。"

exit 0
