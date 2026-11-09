#!/usr/bin/env bash
set -Eeuo pipefail

PREFIX="${PREFIX:-/usr/local/sbin}"
BIN_DIR="${BIN_DIR:-/usr/local/bin}"
SCRIPT_DIR="$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)"

if [ "${EUID}" -ne 0 ]; then
  echo "请使用 root 运行此安装脚本" >&2
  exit 1
fi

need_cmd() {
  command -v "$1" >/dev/null 2>&1 || {
    echo "缺少依赖命令：$1" >&2
    exit 1
  }
}

need_cmd install
need_cmd ln

if ! command -v wg >/dev/null 2>&1; then
  echo "未找到 wg。请先安装 wireguard-tools。" >&2
  exit 1
fi
if ! command -v ip >/dev/null 2>&1; then
  echo "未找到 ip。请先安装 iproute2。" >&2
  exit 1
fi
if ! command -v qrencode >/dev/null 2>&1; then
  echo "警告：未找到 qrencode，show/qr 无法显示二维码。" >&2
  echo "请安装：apt-get install qrencode" >&2
fi

install -d -m 755 "$PREFIX" "$BIN_DIR"
install -m 755 "$SCRIPT_DIR/wgctl" "$PREFIX/wgctl"
ln -sfn "$PREFIX/wgctl" "$BIN_DIR/wgctl"

echo "安装完成：$BIN_DIR/wgctl"
echo "运行 wgctl help 查看用法"
