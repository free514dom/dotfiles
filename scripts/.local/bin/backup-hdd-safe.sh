#!/bin/bash

# ================= 配置区域 =================
DEVICE_PARTITION="/dev/sdb1"   # 硬盘设备名
DRIVE_LABEL="MyPassport"       # 硬盘标签

# ================= 系统变量 =================
CURRENT_USER=$(whoami)
MOUNT_POINT="/run/media/$CURRENT_USER/$DRIVE_LABEL"
TIMESTAMP=$(date +%Y-%m-%d_%H%M%S)
TRASH_DIR_ROOT="$MOUNT_POINT/.Trash_Bin/$TIMESTAMP"

echo "=== 🛡️ 混合策略智能备份 (安全+极速) ==="
echo "    📅 时间戳: $TIMESTAMP"

# --- 1. 挂载检查 ---
if [ ! -d "$MOUNT_POINT" ]; then
    echo "⚠️  未检测到挂载点，尝试自动挂载 $DEVICE_PARTITION ..."
    udisksctl mount -b "$DEVICE_PARTITION"
    if [ ! -d "$MOUNT_POINT" ]; then
        echo "❌ 挂载失败！"
        exit 1
    fi
else
    echo "✅ 硬盘已就绪: $MOUNT_POINT"
fi

echo "🗑️  后悔药机制: 被删/改的文件 -> .Trash_Bin/$TIMESTAMP"
echo ""

# --- 2. 定义核心同步函数 ---
# 参数1: 源目录
# 参数2: 目标目录名
# 参数3: 额外的 Rclone 参数 (用于区分极速模式还是安全模式)
sync_task() {
    local SRC="$1"
    local DEST_NAME="$2"
    local SPECIAL_FLAGS="$3"
    
    local FULL_DEST="$MOUNT_POINT/$DEST_NAME"
    local BACKUP_DIR="$TRASH_DIR_ROOT/$DEST_NAME"

    echo "🔄 [同步中] $(basename "$SRC")"
    
    # 基础参数 (所有任务通用)
    # --fast-list: 减少磁盘寻道
    # --delete-during: 边传边删
    # --backup-dir: 开启回收站
    
    rclone sync "$SRC" "$FULL_DEST" \
        --progress \
        --transfers 32 \
        --checkers 32 \
        --fast-list \
        --backup-dir "$BACKUP_DIR" \
        --create-empty-src-dirs \
        --exclude ".DS_Store" \
        --exclude "Thumbs.db" \
        $SPECIAL_FLAGS

    if [ $? -eq 0 ]; then
        echo "✅ [完成] $DEST_NAME"
    else
        echo "❌ [失败] $DEST_NAME"
    fi
    echo "-----------------------------------------------------"
}

# ================= 3. 执行具体任务 (策略分离) =================

# 🎵 任务 A: 音乐库
# 策略: 【极速模式】 --size-only
# 原因: 媒体文件大，只改内容不改大小的情况极少，速度优先
sync_task "$HOME/Music" "Music_Backup" "--size-only"

# 📄 任务 B: 文档库 (MyPublic)
# 策略: 【安全模式】 --modify-window 2s
# 原因: 纯文本修改可能不改变大小，必须对比时间。2s 窗口解决跨文件系统时间误差。
sync_task "$HOME/MyPublic" "MyPublic_Backup" "--modify-window 2s"

# ⚙️ 任务 C: Dotfiles (Git仓库)
# 策略: 【安全模式】 --modify-window 2s
# 原因: 代码修改极其敏感，必须精确。同时不排除 .git 目录，完整备份版本控制历史。
sync_task "$HOME/dotfiles" "dotfiles_Backup" "--modify-window 2s"

# ================= 4. 清理与写入 =================
echo "🧹 清理空目录..."
rmdir --ignore-fail-on-non-empty -p "$TRASH_DIR_ROOT"/* 2>/dev/null
rmdir --ignore-fail-on-non-empty "$TRASH_DIR_ROOT" 2>/dev/null

echo "💾 正在强制写入磁盘 (Syncing)..."
sync

echo ""
echo "🎉 备份完成！请安全移除硬盘。"
