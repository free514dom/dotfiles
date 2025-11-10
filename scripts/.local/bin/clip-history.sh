#!/bin/bash

MAX_ENTRIES=500
HISTORY_FILE="$HOME/.local/share/clipboard_history"
LAST_ITEM_FILE="/tmp/clipboard_last_item"

export HISTORY_FILE
export LAST_ITEM_FILE
export MAX_ENTRIES

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

    printf "%s\n%s\n\n" "${separator}" "${item}" >> "$HISTORY_FILE"

    echo -n "$item" > "$LAST_ITEM_FILE"

    notify-send -a "Clipboard" -i "edit-copy" "内容已复制" "新的内容已保存到剪贴板"

    local total_lines
    total_lines=$(wc -l < "$HISTORY_FILE")
    local max_lines=$((MAX_ENTRIES * 4))

    if [[ $total_lines -gt $max_lines ]]; then
        tail -n "$max_lines" "$HISTORY_FILE" > "${HISTORY_FILE}.tmp" && mv "${HISTORY_FILE}.tmp" "$HISTORY_FILE"
    fi
}

mkdir -p "$(dirname "$HISTORY_FILE")"
export -f process_item
wl-paste --type text --watch bash -c process_item
