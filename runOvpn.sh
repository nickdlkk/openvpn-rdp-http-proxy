#!/bin/bash

CONFIG_DIR="/etc/openvpn/config"

# 切换到配置目录
cd "$CONFIG_DIR" || { echo "ERROR: Cannot access $CONFIG_DIR"; exit 1; }

# 查找第一个配置文件
CONFIG_FILE=$(find "$CONFIG_DIR" -type f -name '*.ovpn' | head -n 1)

if [[ -z "$CONFIG_FILE" ]]; then
  echo "ERROR: No OpenVPN config found in $CONFIG_DIR"
  ls -l "$CONFIG_DIR" || echo "Cannot list directory contents"
  exit 1
fi

echo "Starting OpenVPN with: $CONFIG_FILE (in $PWD)"
exec openvpn \
    --config "$CONFIG_FILE" \
    --auth-nocache \
    --log /dev/stdout \
    --verb 3