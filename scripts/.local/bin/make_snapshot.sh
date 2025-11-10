#!/usr/bin/env bash

# 1. [HARDCODED] 要扫描的项目目录的绝对路径。
PROJECT_PATH="$HOME/dotfiles"
#PROJECT_PATH="$HOME/FinalProject"

# 2. [HARDCODED] 单一、静态的输出文件绝对路径。
#    此文件将在每次运行时被覆盖。
OUTPUT_FILE="$HOME/project_snapshot.txt"


# --- 脚本会自动忽略的目录和文件 ---
# 注意：输出文件本身已被自动添加到忽略列表中，以防自我包含。
ignored_dirs=(
    .git
    .vscode
    .idea
    .metadata
    .venv
    .direnv
    .envrc
    node_modules
    __pycache__
)
ignored_files=(
    "*.log"
    "*.swp"
    "*.bak"
    "*.hex"
    "LICENSE"
    # 自动忽略输出文件本身的文件名
    "$(basename "$OUTPUT_FILE")"
)



# --- 运行前检查 ---
if [ ! -d "$PROJECT_PATH" ]; then
    echo "错误：项目目录不存在: $PROJECT_PATH" >&2
    notify-send -u critical -a "Snapshot Tool" "错误" "项目目录不存在: $PROJECT_PATH"
    exit 1
fi

echo "开始生成项目快照..."
echo "项目目录: $PROJECT_PATH"
echo "输出文件: $OUTPUT_FILE (每次运行都会覆盖)"

# 切换到项目目录，以确保 find 命令使用正确的相对路径
cd "$PROJECT_PATH" || exit

# 为 find 命令准备忽略参数
find_ignore_params=()
for dir in "${ignored_dirs[@]}"; do
    find_ignore_params+=(-name "$dir" -prune -o)
done
for file in "${ignored_files[@]}"; do
    find_ignore_params+=(-name "$file" -prune -o)
done

# 清空或创建输出文件，并写入头部信息
echo "# 这是由 make_snapshot.sh 脚本在 $(date) 生成的项目快照" > "$OUTPUT_FILE"
echo "# 项目路径: $PROJECT_PATH" >> "$OUTPUT_FILE"
echo "----------------------------------------------------" >> "$OUTPUT_FILE"
echo "" >> "$OUTPUT_FILE"

# 查找所有符合条件的文件
file_list=()
while IFS= read -r -d $'\0' file; do
    file_list+=("$file")
done < <(find . "${find_ignore_params[@]}" -type f -print0)

# 检查是否找到文件
if [ ${#file_list[@]} -eq 0 ]; then
    echo "警告：在目标目录中没有找到符合条件的文件。"
    # 清理只包含头部的快照文件
    rm "$OUTPUT_FILE"
    exit 0
fi

echo "找到了 ${#file_list[@]} 个文件。正在处理..."

# 循环处理每个找到的文件
for file in "${file_list[@]}"; do
    # 获取文件的绝对路径以保证清晰
    absolute_path=$(realpath "$file")

    # 过滤掉二进制文件
    mime_type=$(file -b --mime-type "$file")
    if [[ "$mime_type" == "text/"* || "$mime_type" == "application/json" || "$mime_type" == "application/xml" || "$mime_type" == "application/javascript" || "$mime_type" == "application/x-sh" || "$mime_type" == "application/x-c" || "$mime_type" == "application/x-c++" ]]; then
        # 写入文件路径头部
        echo "--- START OF FILE: $absolute_path ---" >> "$OUTPUT_FILE"
        echo "" >> "$OUTPUT_FILE"

        # 追加文件内容
        cat "$file" >> "$OUTPUT_FILE"

        # 写入文件结束标记
        echo "" >> "$OUTPUT_FILE"
        echo "--- END OF FILE: $absolute_path ---" >> "$OUTPUT_FILE"
        echo -e "\n\n" >> "$OUTPUT_FILE"

        echo "  - 已处理: $absolute_path"
    else
        # 是二进制文件，跳过
        echo "  - (二进制文件，已忽略): $absolute_path"
    fi
done

# --- 收尾工作 ---

echo "快照生成完毕。"

# 【关键修改】将文件 URI 复制到剪贴板，而不是文件内容
# 这样就可以在文件管理器中粘贴文件本身。
echo "file://$OUTPUT_FILE" | wl-copy --type text/uri-list
echo "✅ 文件本身 (URI) 已复制到剪贴板。您可以在文件管理器中粘贴它。"

# 发送系统通知
notify-send -a "Snapshot Tool" -i "document-save" \
    "✅ 项目快照已生成" \
    "文件 $(basename "$OUTPUT_FILE") 已复制到剪贴板，可直接粘贴。"
echo "✅ 系统通知已发送。"

echo "所有任务完成！"
