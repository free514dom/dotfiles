#!/bin/bash

# --- Configuration ---
MAX_ENTRIES=500
HISTORY_FILE="$HOME/.local/share/clipboard_history"
LAST_ITEM_FILE="/tmp/clipboard_last_item"

# --- Export Variables ---
export HISTORY_FILE
export LAST_ITEM_FILE
export MAX_ENTRIES

# --- Core Processing Function ---
process_item() {
    local item
    item=$(wl-paste --type text --no-newline)

    local last_item=""
    if [[ -f "$LAST_ITEM_FILE" ]]; then
        last_item=$(cat "$LAST_ITEM_FILE")
    fi

    if [[ -z "$item" ]] || [[ "$item" == "$last_item" ]]; then
        return
    fi

    local timestamp
    timestamp=$(date +"%Y-%m-%d %H:%M:%S")
    local separator="--- [${timestamp}] ---"

    # 追加新条目
    printf "%s\n%s\n\n" "${separator}" "${item}" >> "$HISTORY_FILE"

    echo -n "$item" > "$LAST_ITEM_FILE"

    notify-send -a "Clipboard" -i "edit-copy" "内容已复制" "新的内容已保存到剪贴板"

    # 【优化】使用更高效的清理逻辑
    # 每个条目由 分隔符 + 内容 + 两个换行符 构成，大约是 4 行。
    # 我们计算总行数，如果超过了 MAX_ENTRIES * 4，就用 tail 截取最后的部分。
    # 这比多次 grep/sed/head/tail 更快，尤其是在文件很大时。
    local total_lines
    total_lines=$(wc -l < "$HISTORY_FILE")
    local max_lines=$((MAX_ENTRIES * 4))

    if [[ $total_lines -gt $max_lines ]]; then
        # 从文件尾部取回 max_lines 行，并写回原文件，完成清理
        tail -n "$max_lines" "$HISTORY_FILE" > "${HISTORY_FILE}.tmp" && mv "${HISTORY_FILE}.tmp" "$HISTORY_FILE"
    fi
}

# --- Script Main Body ---
mkdir -p "$(dirname "$HISTORY_FILE")"
export -f process_item
wl-paste --type text --watch bash -c process_item
