#!/bin/bash

# ================= 配置区域 =================
# 硬盘设备名 (根据你的 lsblk 确认)
DEVICE_PARTITION="/dev/sdb1"

# 硬盘标签 (你的硬盘挂载后的名字)
DRIVE_LABEL="MyPassport"

# 获取当前用户名
CURRENT_USER=$(whoami)

# 硬盘挂载点 (通常是 /run/media/用户名/硬盘名)
MOUNT_POINT="/run/media/$CURRENT_USER/$DRIVE_LABEL"

# 定义回收站的根目录 (在移动硬盘上)
# 格式: /硬盘/.Trash_Bin/日期_时间
TIMESTAMP=$(date +%Y-%m-%d_%H%M%S)
TRASH_DIR_ROOT="$MOUNT_POINT/.Trash_Bin/$TIMESTAMP"

# ===========================================

# 0. 尝试挂载硬盘
echo "==> [1/4] 检查硬盘状态..."
if [ ! -d "$MOUNT_POINT" ]; then
    echo "    硬盘未挂载，尝试挂载 $DEVICE_PARTITION ..."
    udisksctl mount -b "$DEVICE_PARTITION"
    
    # 再次检查
    if [ ! -d "$MOUNT_POINT" ]; then
        echo "❌ 挂载失败或路径错误，请检查设备是否插入。"
        exit 1
    fi
else
    echo "    硬盘已挂载于: $MOUNT_POINT"
fi

echo ""
echo "==> 本次备份的【后悔药】(回收站) 位置:"
echo "    📂 $TRASH_DIR_ROOT"
echo "    (凡是被删除或覆盖的文件，都会被移到这里，不会丢失)"
echo ""

# 定义一个通用的同步函数
# 用法: sync_safe "源目录" "目标目录名"
sync_safe() {
    local SRC="$1"
    local DEST_NAME="$2"
    local FULL_DEST="$MOUNT_POINT/$DEST_NAME"
    local BACKUP_DIR="$TRASH_DIR_ROOT/$DEST_NAME"

    echo "-----------------------------------------------------"
    echo "🚀 正在同步: $(basename "$SRC") -> $DEST_NAME"
    
    # 核心命令解释:
    # sync: 单向镜像 (本地删->硬盘删)
    # --backup-dir: 关键参数! 将"被删"或"被覆盖"的文件移走，而不是销毁
    # --exclude ".git/**": (可选) 如果不需要备份git历史，加上这句能省很多时间
    
    rclone sync "$SRC" "$FULL_DEST" \
        --progress \
        --transfers 16 \
        --backup-dir "$BACKUP_DIR" \
        --create-empty-src-dirs

    if [ $? -eq 0 ]; then
        echo "✅ $(basename "$SRC") 同步完成"
    else
        echo "❌ $(basename "$SRC") 同步出现错误"
    fi
}

# ================= 执行任务 =================

# 任务 1: Music
sync_safe "$HOME/Music" "Music_Backup"

# 任务 2: dotfiles
sync_safe "$HOME/dotfiles" "dotfiles_Backup"

# 任务 3: MyPublic
# 修正: 你之前写成了 Music_Backup，这里改为 MyPublic_Backup 防止文件混在一起
sync_safe "$HOME/MyPublic" "MyPublic_Backup" 

# ================= 收尾工作 =================

echo "-----------------------------------------------------"
echo "==> [4/4] 正在清理回收站里的空文件夹..."
# 删除回收站里生成的空目录(保持整洁)，但不删除文件
rmdir --ignore-fail-on-non-empty -p "$TRASH_DIR_ROOT"/* 2>/dev/null

echo "==> 💾 正在将数据写入硬盘 (Syncing)... 请耐心等待"
sync

echo ""
echo "🎉 所有备份完成！"
echo "👉 被替换/删除的文件已保存在: .Trash_Bin/$TIMESTAMP"
echo "👉 你现在可以安全拔出硬盘了 (udisksctl unmount -b $DEVICE_PARTITION)"
