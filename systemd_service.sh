#!/bin/bash

# OpenClash节点管理系统 - Systemd服务安装脚本
# 用于设置开机自启动和后台运行

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 配置变量
SERVICE_NAME="openclash-manager"
SERVICE_DESC="OpenClash节点管理系统"
ROOT_DIR="/root/OpenClashManage"
WEB_EDITOR_PORT="5000"

# 日志函数
log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

log_step() {
    echo -e "${BLUE}[STEP]${NC} $1"
}

# 检查是否为root用户
check_root() {
    if [[ $EUID -ne 0 ]]; then
        log_error "此脚本需要root权限运行"
        exit 1
    fi
}

# 检查必要文件
check_files() {
    log_step "检查必要文件..."
    
    local required_files=(
        "$ROOT_DIR/jk.sh"
        "$ROOT_DIR/web_editor.py"
        "$ROOT_DIR/zr.py"
        "$ROOT_DIR/jx.py"
        "$ROOT_DIR/zw.py"
        "$ROOT_DIR/zc.py"
        "$ROOT_DIR/log.py"
    )
    
    for file in "${required_files[@]}"; do
        if [[ ! -f "$file" ]]; then
            log_error "缺少必要文件: $file"
            exit 1
        fi
    done
    
    log_info "所有必要文件检查通过"
}

# 创建守护进程服务
create_watchdog_service() {
    log_step "创建守护进程服务..."
    
    cat > "/etc/systemd/system/${SERVICE_NAME}-watchdog.service" << EOF
[Unit]
Description=${SERVICE_DESC} - 守护进程
After=network.target
Wants=network.target

[Service]
Type=simple
User=root
WorkingDirectory=$ROOT_DIR
ExecStart=/bin/bash $ROOT_DIR/jk.sh
Restart=always
RestartSec=10
StandardOutput=journal
StandardError=journal

# 安全设置
NoNewPrivileges=true
PrivateTmp=true
ProtectSystem=strict
ProtectHome=true
ReadWritePaths=$ROOT_DIR /etc/openclash

[Install]
WantedBy=multi-user.target
EOF

    log_info "守护进程服务文件已创建"
}

# 创建Web编辑器服务
create_web_editor_service() {
    log_step "创建Web编辑器服务..."
    
    cat > "/etc/systemd/system/${SERVICE_NAME}-web.service" << EOF
[Unit]
Description=${SERVICE_DESC} - Web编辑器
After=network.target
Wants=network.target

[Service]
Type=simple
User=root
WorkingDirectory=$ROOT_DIR
ExecStart=/usr/bin/python3 $ROOT_DIR/web_editor.py
Restart=always
RestartSec=10
StandardOutput=journal
StandardError=journal

# 环境变量
Environment=FLASK_ENV=production
Environment=FLASK_DEBUG=0

# 安全设置
NoNewPrivileges=true
PrivateTmp=true
ProtectSystem=strict
ProtectHome=true
ReadWritePaths=$ROOT_DIR

[Install]
WantedBy=multi-user.target
EOF

    log_info "Web编辑器服务文件已创建"
}

# 创建组合服务
create_combined_service() {
    log_step "创建组合服务..."
    
    cat > "/etc/systemd/system/${SERVICE_NAME}.service" << EOF
[Unit]
Description=${SERVICE_DESC} - 完整系统
After=network.target
Wants=network.target

[Service]
Type=oneshot
RemainAfterExit=yes
ExecStart=/bin/bash -c 'systemctl start ${SERVICE_NAME}-watchdog.service && systemctl start ${SERVICE_NAME}-web.service'
ExecStop=/bin/bash -c 'systemctl stop ${SERVICE_NAME}-watchdog.service && systemctl stop ${SERVICE_NAME}-web.service'

[Install]
WantedBy=multi-user.target
EOF

    log_info "组合服务文件已创建"
}

# 设置文件权限
set_permissions() {
    log_step "设置文件权限..."
    
    # 设置脚本执行权限
    chmod +x "$ROOT_DIR/jk.sh"
    chmod +x "$ROOT_DIR/start_web_editor.sh"
    
    # 确保目录存在
    mkdir -p "$ROOT_DIR/wangluo"
    mkdir -p "$ROOT_DIR/templates"
    
    # 设置目录权限
    chmod 755 "$ROOT_DIR"
    chmod 755 "$ROOT_DIR/wangluo"
    
    log_info "文件权限设置完成"
}

# 安装Python依赖
install_dependencies() {
    log_step "安装Python依赖..."
    
    if [[ -f "$ROOT_DIR/requirements.txt" ]]; then
        pip3 install -r "$ROOT_DIR/requirements.txt"
        log_info "Python依赖安装完成"
    else
        log_warn "未找到requirements.txt文件，跳过依赖安装"
    fi
}

# 重新加载systemd
reload_systemd() {
    log_step "重新加载systemd配置..."
    systemctl daemon-reload
    log_info "systemd配置已重新加载"
}

# 启用服务
enable_services() {
    log_step "启用服务..."
    
    # 启用子服务
    systemctl enable "${SERVICE_NAME}-watchdog.service"
    systemctl enable "${SERVICE_NAME}-web.service"
    
    # 启用主服务
    systemctl enable "${SERVICE_NAME}.service"
    
    log_info "服务已启用，将在下次开机时自动启动"
}

# 启动服务
start_services() {
    log_step "启动服务..."
    
    # 启动主服务
    systemctl start "${SERVICE_NAME}.service"
    
    # 等待服务启动
    sleep 3
    
    # 检查服务状态
    if systemctl is-active --quiet "${SERVICE_NAME}-watchdog.service"; then
        log_info "✅ 守护进程服务启动成功"
    else
        log_error "❌ 守护进程服务启动失败"
    fi
    
    if systemctl is-active --quiet "${SERVICE_NAME}-web.service"; then
        log_info "✅ Web编辑器服务启动成功"
        log_info "🌐 访问地址: http://$(hostname -I | awk '{print $1}'):${WEB_EDITOR_PORT}"
    else
        log_error "❌ Web编辑器服务启动失败"
    fi
}

# 显示服务状态
show_status() {
    log_step "服务状态检查..."
    
    echo
    echo "=== 服务状态 ==="
    systemctl status "${SERVICE_NAME}-watchdog.service" --no-pager -l
    echo
    systemctl status "${SERVICE_NAME}-web.service" --no-pager -l
    echo
    systemctl status "${SERVICE_NAME}.service" --no-pager -l
    
    echo
    echo "=== 端口检查 ==="
    if netstat -tlnp 2>/dev/null | grep -q ":${WEB_EDITOR_PORT} "; then
        log_info "✅ Web编辑器端口 ${WEB_EDITOR_PORT} 正在监听"
    else
        log_warn "⚠️  Web编辑器端口 ${WEB_EDITOR_PORT} 未监听"
    fi
    
    echo
    echo "=== 进程检查 ==="
    if pgrep -f "jk.sh" > /dev/null; then
        log_info "✅ 守护进程正在运行"
    else
        log_warn "⚠️  守护进程未运行"
    fi
    
    if pgrep -f "web_editor.py" > /dev/null; then
        log_info "✅ Web编辑器进程正在运行"
    else
        log_warn "⚠️  Web编辑器进程未运行"
    fi
}

# 显示使用说明
show_usage() {
    echo
    echo "=== 使用说明 ==="
    echo
    echo "服务管理命令："
    echo "  启动服务: systemctl start ${SERVICE_NAME}.service"
    echo "  停止服务: systemctl stop ${SERVICE_NAME}.service"
    echo "  重启服务: systemctl restart ${SERVICE_NAME}.service"
    echo "  查看状态: systemctl status ${SERVICE_NAME}.service"
    echo "  查看日志: journalctl -u ${SERVICE_NAME}.service -f"
    echo
    echo "单独管理子服务："
    echo "  守护进程: systemctl {start|stop|restart|status} ${SERVICE_NAME}-watchdog.service"
    echo "  Web编辑器: systemctl {start|stop|restart|status} ${SERVICE_NAME}-web.service"
    echo
    echo "开机自启动："
    echo "  已自动启用，系统重启后会自动启动服务"
    echo
    echo "访问地址："
    echo "  Web编辑器: http://$(hostname -I | awk '{print $1}'):${WEB_EDITOR_PORT}"
    echo
}

# 主函数
main() {
    echo "🚀 OpenClash节点管理系统 - Systemd服务安装"
    echo "=========================================="
    
    check_root
    check_files
    set_permissions
    install_dependencies
    create_watchdog_service
    create_web_editor_service
    create_combined_service
    reload_systemd
    enable_services
    start_services
    show_status
    show_usage
    
    echo
    log_info "🎉 安装完成！系统将在开机时自动启动"
    echo
}

# 卸载函数
uninstall() {
    log_step "卸载服务..."
    
    # 停止服务
    systemctl stop "${SERVICE_NAME}.service" 2>/dev/null || true
    systemctl stop "${SERVICE_NAME}-watchdog.service" 2>/dev/null || true
    systemctl stop "${SERVICE_NAME}-web.service" 2>/dev/null || true
    
    # 禁用服务
    systemctl disable "${SERVICE_NAME}.service" 2>/dev/null || true
    systemctl disable "${SERVICE_NAME}-watchdog.service" 2>/dev/null || true
    systemctl disable "${SERVICE_NAME}-web.service" 2>/dev/null || true
    
    # 删除服务文件
    rm -f "/etc/systemd/system/${SERVICE_NAME}.service"
    rm -f "/etc/systemd/system/${SERVICE_NAME}-watchdog.service"
    rm -f "/etc/systemd/system/${SERVICE_NAME}-web.service"
    
    # 重新加载systemd
    systemctl daemon-reload
    
    log_info "✅ 服务已卸载"
}

# 脚本入口
case "${1:-install}" in
    "install")
        main
        ;;
    "uninstall")
        uninstall
        ;;
    "status")
        show_status
        ;;
    *)
        echo "用法: $0 {install|uninstall|status}"
        echo "  install   - 安装并启动服务"
        echo "  uninstall - 卸载服务"
        echo "  status    - 查看服务状态"
        exit 1
        ;;
esac 