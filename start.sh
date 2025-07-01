#!/bin/bash

set -e

echo "==== Try Start Squid Proxy ===="
# 启动 squid
squid

# 启动OpenVPN (后台运行)
echo "=== Starting OpenVPN ==="
/runOvpn.sh &
OPENVPN_PID=$!

# 启动RDP转发 (后台运行)
echo "=== Starting RDP Forwarder ==="
/rdp-forward.sh &
RDP_FORWARD_PID=$!


# 捕获退出信号
trap "kill $OPENVPN_PID $RDP_FORWARD_PID 2>/dev/null; exit 0" SIGINT SIGTERM

# 等待所有后台进程退出
wait -n $OPENVPN_PID $RDP_FORWARD_PID
EXIT_CODE=$?

# 如果任一进程退出，终止其他进程
kill $OPENVPN_PID $RDP_FORWARD_PID 2>/dev/null || true

exit $EXIT_CODE