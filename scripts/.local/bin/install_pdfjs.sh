#!/bin/bash

# --- 配置 ---
# 使用符合 XDG 标准的目录 ~/.local/share/ 来存放数据文件，保持主目录整洁。
INSTALL_DIR="${HOME}/.local/share/pdfjs-dist"

# --- 脚本开始 ---
echo "PDF.js 将被安装到标准位置: ${INSTALL_DIR}"
echo "正在从 GitHub API 获取最新的版本信息..."

# 1. 获取最新 release 的下载链接
# 加上 `| head -n 1` 确保只取第一个匹配到的 URL (现代版)
DOWNLOAD_URL=$(curl -s https://api.github.com/repos/mozilla/pdf.js/releases/latest | jq -r '.assets[] | select(.name | endswith("-dist.zip")) | .browser_download_url' | head -n 1)

# 2. 检查 URL 是否获取成功
if [ -z "$DOWNLOAD_URL" ]; then
  echo "错误：无法获取最新的下载链接。请检查网络或 GitHub API 状态。"
  exit 1
fi

echo "成功找到最新版本链接: $DOWNLOAD_URL"

# 3. 下载到 /tmp 临时目录
TMP_ZIP_FILE="/tmp/pdfjs-latest.zip"
echo "正在下载..."
wget -q --show-progress -O "$TMP_ZIP_FILE" "$DOWNLOAD_URL"

# 检查下载是否成功
if [ $? -ne 0 ]; then
  echo "错误：下载失败。"
  exit 1
fi

# 4. 清理旧目录并创建新目录
echo "正在解压文件到 ${INSTALL_DIR} ..."
rm -rf "${INSTALL_DIR}"
mkdir -p "${INSTALL_DIR}"

# 5. 解压文件
unzip -q "$TMP_ZIP_FILE" -d "${INSTALL_DIR}"

# 检查解压是否成功
if [ $? -ne 0 ]; then
  echo "错误：解压失败。"
  exit 1
fi

# 6. 清理临时下载文件
rm "$TMP_ZIP_FILE"

echo "✅ 成功！最新的 PDF.js 已经安装在 ${INSTALL_DIR}"
echo "请使用新的 URL 访问。"
