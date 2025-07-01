FROM nickdlk/ubuntu:latest
ENV DEBIAN_FRONTEND=noninteractive

# 安装必要软件
RUN apt update && \
    apt install -y --no-install-recommends \
        openvpn \
        iproute2 \
        socat \
        ca-certificates && \
    # 清理缓存
    apt clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* && \
    # 创建OpenVPN配置目录
    mkdir -p /etc/openvpn/config

# 复制脚本文件
COPY runOvpn.sh /runOvpn.sh
COPY rdp-forward.sh /rdp-forward.sh
COPY start.sh /start.sh

# 设置权限
RUN chmod +x /runOvpn.sh /rdp-forward.sh /start.sh

# VPN配置目录（运行时挂载）
VOLUME ["/etc/openvpn/config"]

# 暴露RDP转发端口
EXPOSE 3389

# 设置容器启动时执行的命令
CMD ["/start.sh"]