#!/bin/bash

# 如果任何命令失败，立即退出脚本
set -e

# --- 统一配置区 (所有配置都在这里修改) ---
# 1. 需要备份的项目目录列表
BACKUP_TARGETS=(
    "$HOME/dotfiles"
#暂时不用    "$HOME/FinalProject"
)
# 2. 备份文件在云端的目标路径
BACKUP_REMOTE="GDrive_2TB:GithubRepos"

# 3. 在云端保留备份的天数
DAYS_TO_KEEP=7


# --- 功能函数定义区 ---

# 函数: 备份指定的项目目录
function backup_projects() {
    echo "--> [1/1] 正在开始项目备份任务 (目标: $BACKUP_REMOTE)..."

    # 动态检查所有目标目录是否存在
    for target in "${BACKUP_TARGETS[@]}"; do
        if [ ! -d "$target" ]; then
            echo "错误: 目标备份目录 '$target' 不存在！请检查配置。" >&2
            return 1 # 返回错误码
        fi
    done

    # 准备临时文件名和路径
    local TIMESTAMP=$(date +'%Y-%m-%d_%H-%M-%S')
    local BACKUP_FILENAME="projects-backup-${TIMESTAMP}.tar.gz"
    local LOCAL_ARCHIVE_PATH="/tmp/${BACKUP_FILENAME}"

    echo "    -> 正在创建压缩包: ${LOCAL_ARCHIVE_PATH}"
    echo "    -> 包含的目录:"
    for target in "${BACKUP_TARGETS[@]}"; do
        echo "       - $(basename "$target")"
    done

    # 动态生成 tar 命令的参数
    local tar_targets=()
    for target in "${BACKUP_TARGETS[@]}"; do
        tar_targets+=("$(basename "$target")")
    done

    # 执行打包命令
    # -C "$HOME" 表示先切换到家目录，再进行打包，以保持压缩包内的目录结构整洁
    tar -I 'gzip --best' -cf "${LOCAL_ARCHIVE_PATH}" \
        --exclude='dotfiles/project_snapshot.txt' \
        --exclude-vcs \
        -C "$HOME" \
        "${tar_targets[@]}"

    echo "    -> 正在上传压缩包..."
    rclone copyto "${LOCAL_ARCHIVE_PATH}" "${BACKUP_REMOTE}/${BACKUP_FILENAME}" --progress

    echo "    -> 清理本地临时文件..."
    rm "${LOCAL_ARCHIVE_PATH}"

    echo "    -> 清理云端 ${DAYS_TO_KEEP} 天前的旧备份..."
    rclone delete "${BACKUP_REMOTE}" --min-age "${DAYS_TO_KEEP}d"

    echo "--> ✅ 项目备份任务完成。"
}


# --- 脚本主执行区 ---

# 设置时区，确保日志和时间戳正确
export TZ='Asia/Shanghai'

echo "==> [$(date)] 开始执行备份任务..."
echo ""

# 直接调用备份函数
backup_projects

echo ""
echo "==> [$(date)] 所有备份任务成功完成！"

# --- 发送桌面通知 ---
# 由于脚本开头设置了 set -e, 只有在所有任务都成功后才会执行到这里。
notify-send -a "Backup Script" -i "emblem-synchronizing" \
    "✅ All Backups Complete" \
    "项目 (dotfiles, FinalProject) 已成功备份到云端。"

exit 0
