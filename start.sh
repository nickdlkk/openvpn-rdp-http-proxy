#!/bin/bash

set -e

# Start squid service
start_squid()
{
    service squid start
    if [ ! `service squid status | grep "squid is running" | wc -l` -gt 0 ]; then 
        echo "Error: failed to start squid service" >&2; 
        return 1
    fi
    return 0
}

# 启动OpenVPN (后台运行)
echo "=== Starting OpenVPN ==="
/runOvpn.sh &
OPENVPN_PID=$!

# 启动RDP转发 (后台运行)
echo "=== Starting RDP Forwarder ==="
/rdp-forward.sh &
RDP_FORWARD_PID=$!

echo "==== Try Start Squid Proxy ===="
# 启动 squid
for i in `seq 3`
do
    start_squid
    if [ $? -eq 0 ]; then
        break 
    fi
    if [ $i -eq 3 ]; then
        echo "Error: failed to start squid service." >&2
        exit 1
    fi
done
service squid status

# 捕获退出信号
trap "kill $OPENVPN_PID $RDP_FORWARD_PID 2>/dev/null; exit 0" SIGINT SIGTERM

# 等待所有后台进程退出
wait -n $OPENVPN_PID $RDP_FORWARD_PID
EXIT_CODE=$?

# 如果任一进程退出，终止其他进程
kill $OPENVPN_PID $RDP_FORWARD_PID 2>/dev/null || true

exit $EXIT_CODE