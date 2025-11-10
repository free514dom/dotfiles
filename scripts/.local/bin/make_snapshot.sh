#!/usr/bin/env bash

PROJECT_PATH="$HOME/dotfiles"
OUTPUT_FILE="$HOME/project_snapshot.txt"

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
    "$(basename "$OUTPUT_FILE")"
)

if [ ! -d "$PROJECT_PATH" ]; then
    echo "错误：项目目录不存在: $PROJECT_PATH" >&2
    notify-send -u critical -a "Snapshot Tool" "错误" "项目目录不存在: $PROJECT_PATH"
    exit 1
fi

echo "开始生成项目快照..."
echo "项目目录: $PROJECT_PATH"
echo "输出文件: $OUTPUT_FILE (每次运行都会覆盖)"

cd "$PROJECT_PATH" || exit

find_ignore_params=()
for dir in "${ignored_dirs[@]}"; do
    find_ignore_params+=(-name "$dir" -prune -o)
done
for file in "${ignored_files[@]}"; do
    find_ignore_params+=(-name "$file" -prune -o)
done

echo "# 这是由 make_snapshot.sh 脚本在 $(date) 生成的项目快照" > "$OUTPUT_FILE"
echo "# 项目路径: $PROJECT_PATH" >> "$OUTPUT_FILE"
echo "----------------------------------------------------" >> "$OUTPUT_FILE"
echo "" >> "$OUTPUT_FILE"

file_list=()
while IFS= read -r -d $'\0' file; do
    file_list+=("$file")
done < <(find . "${find_ignore_params[@]}" -type f -print0)

if [ ${#file_list[@]} -eq 0 ]; then
    echo "警告：在目标目录中没有找到符合条件的文件。"
    rm "$OUTPUT_FILE"
    exit 0
fi

echo "找到了 ${#file_list[@]} 个文件。正在处理..."

for file in "${file_list[@]}"; do
    absolute_path=$(realpath "$file")

    mime_type=$(file -b --mime-type "$file")
    if [[ "$mime_type" == "text/"* || "$mime_type" == "application/json" || "$mime_type" == "application/xml" || "$mime_type" == "application/javascript" || "$mime_type" == "application/x-sh" || "$mime_type" == "application/x-c" || "$mime_type" == "application/x-c++" ]]; then
        echo "--- START OF FILE: $absolute_path ---" >> "$OUTPUT_FILE"
        echo "" >> "$OUTPUT_FILE"

        cat "$file" >> "$OUTPUT_FILE"

        echo "" >> "$OUTPUT_FILE"
        echo "--- END OF FILE: $absolute_path ---" >> "$OUTPUT_FILE"
        echo -e "\n\n" >> "$OUTPUT_FILE"

        echo "  - 已处理: $absolute_path"
    else
        echo "  - (二进制文件，已忽略): $absolute_path"
    fi
done

echo "快照生成完毕。"

echo "file://$OUTPUT_FILE" | wl-copy --type text/uri-list
echo "✅ 文件本身 (URI) 已复制到剪贴板。您可以在文件管理器中粘贴它。"

notify-send -a "Snapshot Tool" -i "document-save" \
    "✅ 项目快照已生成" \
    "文件 $(basename "$OUTPUT_FILE") 已复制到剪贴板，可直接粘贴。"
echo "✅ 系统通知已发送。"

echo "所有任务完成！"
