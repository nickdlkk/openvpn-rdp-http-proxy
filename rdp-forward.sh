#!/bin/bash

# 检查目标RDP服务器是否设置
if [ -z "$RDP_TARGET" ]; then
  echo "ERROR: RDP_TARGET environment variable not set"
  echo "Please set using: -e RDP_TARGET=<target_ip>"
  exit 1
fi

# 等待tun0接口建立
echo "Waiting for VPN tunnel to establish..."
for i in {1..30}; do
  if ip link show tun0 &> /dev/null; then
    echo "VPN tunnel established"
    break
  fi
  if [[ $i == 30 ]]; then
    echo "ERROR: Failed to establish VPN tunnel within 30 seconds"
    exit 1
  fi
  sleep 1
done

# 获取VPN接口的IP地址
VPN_IP=$(ip -4 addr show tun0 | awk '/inet/ {print $2}' | cut -d'/' -f1)
if [ -z "$VPN_IP" ]; then
  echo "ERROR: Could not get VPN IP address"
  exit 1
fi

echo "Using VPN IP: $VPN_IP"
echo "Forwarding RDP traffic to: $RDP_TARGET"

# 启动socat进行端口转发
exec socat \
    TCP-LISTEN:3389,fork,reuseaddr \
    TCP:$RDP_TARGET:3389,bind=$VPN_IP