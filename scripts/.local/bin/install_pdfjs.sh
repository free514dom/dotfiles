#!/bin/bash

INSTALL_DIR="${HOME}/.local/share/pdfjs-dist"

echo "PDF.js 将被安装到标准位置: ${INSTALL_DIR}"
echo "正在从 GitHub API 获取最新的版本信息..."

DOWNLOAD_URL=$(curl -s https://api.github.com/repos/mozilla/pdf.js/releases/latest | jq -r '.assets[] | select(.name | endswith("-dist.zip")) | .browser_download_url' | head -n 1)

if [ -z "$DOWNLOAD_URL" ]; then
  echo "错误：无法获取最新的下载链接。请检查网络或 GitHub API 状态。"
  exit 1
fi

echo "成功找到最新版本链接: $DOWNLOAD_URL"

TMP_ZIP_FILE="/tmp/pdfjs-latest.zip"
echo "正在下载..."
wget -q --show-progress -O "$TMP_ZIP_FILE" "$DOWNLOAD_URL"

if [ $? -ne 0 ]; then
  echo "错误：下载失败。"
  exit 1
fi

echo "正在解压文件到 ${INSTALL_DIR} ..."
rm -rf "${INSTALL_DIR}"
mkdir -p "${INSTALL_DIR}"

unzip -q "$TMP_ZIP_FILE" -d "${INSTALL_DIR}"

if [ $? -ne 0 ]; then
  echo "错误：解压失败。"
  exit 1
fi

rm "$TMP_ZIP_FILE"

echo "✅ 成功！最新的 PDF.js 已经安装在 ${INSTALL_DIR}"
echo "请使用新的 URL 访问。"
