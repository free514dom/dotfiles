#!/bin/bash

# --- 脚本核心设置 ---
# 如果任何命令失败,立即退出脚本
set -e

# --- 配置区 ---
# 1. 云端音乐源路径
REMOTE_PATH="GDrive_2TB:Music"

# 2. 本地音乐目标路径 (脚本会自动创建此目录)
LOCAL_PATH="$HOME/Music"

# --- 脚本主执行区 ---

echo "==> [$(date)] 开始执行音乐库单向同步任务..."
echo "    -> 源 (云端): $REMOTE_PATH"
echo "    -> 目标 (本地): $LOCAL_PATH"
echo "    -> 注意: 本地多余的文件将被删除以匹配云端。"
echo ""

# 确保本地目标目录存在
mkdir -p "$LOCAL_PATH"

# 使用 rclone sync 执行单向同步
# --progress (或 -P): 显示详细的传输进度，对大文件/多文件非常有用。
# sync 命令会确保 LOCAL_PATH 的内容与 REMOTE_PATH 完全一致。
rclone sync "$REMOTE_PATH" "$LOCAL_PATH" --progress

echo ""
echo "==> [$(date)] 音乐库同步成功完成！"

# --- 发送桌面通知 ---
notify-send -a "Music Sync" -i "folder-music" \
    "✅ 音乐库同步完成" \
    "已从 $REMOTE_PATH 更新到本地。"

exit 0
