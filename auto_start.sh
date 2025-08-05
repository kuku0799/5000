#!/bin/bash

# OpenClash节点管理系统 - 快速自动启动脚本
# 简化版本，用于快速设置开机自启动和后台运行

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# 配置
ROOT_DIR="/root/OpenClashManage"
SERVICE_NAME="openclash-manager"

log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# 检查root权限
if [[ $EUID -ne 0 ]]; then
    log_error "需要root权限运行此脚本"
    exit 1
fi

echo "🚀 OpenClash节点管理系统 - 自动启动设置"
echo "========================================"

# 检查必要文件
log_info "检查必要文件..."
if [[ ! -f "$ROOT_DIR/jk.sh" ]] || [[ ! -f "$ROOT_DIR/web_editor.py" ]]; then
    log_error "缺少必要文件，请确保在正确的目录中运行"
    exit 1
fi

# 设置执行权限
log_info "设置文件权限..."
chmod +x "$ROOT_DIR/jk.sh"
chmod +x "$ROOT_DIR/start_web_editor.sh"

# 确保目录存在
mkdir -p "$ROOT_DIR/wangluo"
mkdir -p "$ROOT_DIR/templates"

# 安装Python依赖
log_info "安装Python依赖..."
if [[ -f "$ROOT_DIR/requirements.txt" ]]; then
    pip3 install -r "$ROOT_DIR/requirements.txt"
fi

# 创建systemd服务文件
log_info "创建systemd服务..."

# 守护进程服务
cat > "/etc/systemd/system/${SERVICE_NAME}-watchdog.service" << EOF
[Unit]
Description=OpenClash节点管理系统 - 守护进程
After=network.target

[Service]
Type=simple
User=root
WorkingDirectory=$ROOT_DIR
ExecStart=/bin/bash $ROOT_DIR/jk.sh
Restart=always
RestartSec=10
StandardOutput=journal
StandardError=journal

[Install]
WantedBy=multi-user.target
EOF

# Web编辑器服务
cat > "/etc/systemd/system/${SERVICE_NAME}-web.service" << EOF
[Unit]
Description=OpenClash节点管理系统 - Web编辑器
After=network.target

[Service]
Type=simple
User=root
WorkingDirectory=$ROOT_DIR
ExecStart=/usr/bin/python3 $ROOT_DIR/web_editor.py
Restart=always
RestartSec=10
StandardOutput=journal
StandardError=journal
Environment=FLASK_ENV=production

[Install]
WantedBy=multi-user.target
EOF

# 主服务
cat > "/etc/systemd/system/${SERVICE_NAME}.service" << EOF
[Unit]
Description=OpenClash节点管理系统 - 完整系统
After=network.target

[Service]
Type=oneshot
RemainAfterExit=yes
ExecStart=/bin/bash -c 'systemctl start ${SERVICE_NAME}-watchdog.service && systemctl start ${SERVICE_NAME}-web.service'
ExecStop=/bin/bash -c 'systemctl stop ${SERVICE_NAME}-watchdog.service && systemctl stop ${SERVICE_NAME}-web.service'

[Install]
WantedBy=multi-user.target
EOF

# 重新加载systemd
log_info "重新加载systemd配置..."
systemctl daemon-reload

# 启用服务
log_info "启用服务..."
systemctl enable "${SERVICE_NAME}-watchdog.service"
systemctl enable "${SERVICE_NAME}-web.service"
systemctl enable "${SERVICE_NAME}.service"

# 启动服务
log_info "启动服务..."
systemctl start "${SERVICE_NAME}.service"

# 等待服务启动
sleep 3

# 检查服务状态
echo
echo "=== 服务状态检查 ==="
if systemctl is-active --quiet "${SERVICE_NAME}-watchdog.service"; then
    log_info "✅ 守护进程服务运行正常"
else
    log_warn "⚠️  守护进程服务可能有问题"
fi

if systemctl is-active --quiet "${SERVICE_NAME}-web.service"; then
    log_info "✅ Web编辑器服务运行正常"
    log_info "🌐 访问地址: http://$(hostname -I | awk '{print $1}'):5000"
else
    log_warn "⚠️  Web编辑器服务可能有问题"
fi

echo
echo "=== 使用说明 ==="
echo "服务管理命令："
echo "  启动: systemctl start ${SERVICE_NAME}.service"
echo "  停止: systemctl stop ${SERVICE_NAME}.service"
echo "  重启: systemctl restart ${SERVICE_NAME}.service"
echo "  状态: systemctl status ${SERVICE_NAME}.service"
echo "  日志: journalctl -u ${SERVICE_NAME}.service -f"
echo
echo "开机自启动：已启用，系统重启后会自动启动"
echo "Web编辑器：http://$(hostname -I | awk '{print $1}'):5000"
echo
log_info "🎉 自动启动设置完成！" 