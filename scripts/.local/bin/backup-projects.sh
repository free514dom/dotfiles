#!/bin/bash

set -e

BACKUP_TARGETS=(
    "$HOME/dotfiles"
)
BACKUP_REMOTE="GDrive_2TB:GithubRepos"
DAYS_TO_KEEP=7

function backup_projects() {
    echo "--> [1/1] 正在开始项目备份任务 (目标: $BACKUP_REMOTE)..."

    for target in "${BACKUP_TARGETS[@]}"; do
        if [ ! -d "$target" ]; then
            echo "错误: 目标备份目录 '$target' 不存在！请检查配置。" >&2
            return 1
        fi
    done

    local TIMESTAMP=$(date +'%Y-%m-%d_%H-%M-%S')
    local BACKUP_FILENAME="projects-backup-${TIMESTAMP}.tar.gz"
    local LOCAL_ARCHIVE_PATH="/tmp/${BACKUP_FILENAME}"

    echo "    -> 正在创建压缩包: ${LOCAL_ARCHIVE_PATH}"
    echo "    -> 包含的目录:"
    for target in "${BACKUP_TARGETS[@]}"; do
        echo "       - $(basename "$target")"
    done

    local tar_targets=()
    for target in "${BACKUP_TARGETS[@]}"; do
        tar_targets+=("$(basename "$target")")
    done

    tar -I 'gzip --best' -cf "${LOCAL_ARCHIVE_PATH}" \
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

export TZ='Asia/Shanghai'

echo "==> [$(date)] 开始执行备份任务..."
echo ""

backup_projects

echo ""
echo "==> [$(date)] 所有备份任务成功完成！"

notify-send -a "Backup Script" -i "emblem-synchronizing" \
    "✅ All Backups Complete" \
    "项目 (dotfiles, FinalProject) 已成功备份到云端。"

exit 0
