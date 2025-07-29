#!/bin/bash

# FastAPI + Vue.js Clash 管理面板卸载脚本
# 版本: 1.0

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# 日志函数
log_info() { echo -e "${GREEN}[INFO]${NC} $1"; }
log_warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }
log_step() { echo -e "${BLUE}[STEP]${NC} $1"; }

# 显示横幅
show_banner() {
    echo
    echo "╔══════════════════════════════════════════════════════════════╗"
    echo "║                FastAPI + Vue.js Clash 管理面板                ║"
    echo "║                        卸载脚本 v1.0                          ║"
    echo "╚══════════════════════════════════════════════════════════════╝"
    echo
}

# 检查是否为 root 用户
check_root() {
    if [[ $EUID -ne 0 ]]; then
        log_error "此脚本需要 root 权限运行"
        exit 1
    fi
}

# 停止服务
stop_services() {
    log_step "停止服务..."
    
    # 停止 clash-panel 服务
    if [ -f "/etc/init.d/clash-panel" ]; then
        /etc/init.d/clash-panel stop 2>/dev/null || true
        /etc/init.d/clash-panel disable 2>/dev/null || true
    fi
    
    if [ -f "/etc/systemd/system/clash-panel.service" ]; then
        systemctl stop clash-panel 2>/dev/null || true
        systemctl disable clash-panel 2>/dev/null || true
    fi
    
    # 杀死相关进程
    pkill -f "main.py" 2>/dev/null || true
    pkill -f "clash-panel" 2>/dev/null || true
    
    log_info "服务已停止"
}

# 删除文件
remove_files() {
    log_step "删除文件..."
    
    # 删除安装目录
    if [ -d "/opt/clash-panel" ]; then
        rm -rf /opt/clash-panel
        log_info "删除安装目录: /opt/clash-panel"
    fi
    
    # 删除服务文件
    if [ -f "/etc/init.d/clash-panel" ]; then
        rm -f /etc/init.d/clash-panel
        log_info "删除 OpenWrt 服务文件"
    fi
    
    if [ -f "/etc/systemd/system/clash-panel.service" ]; then
        rm -f /etc/systemd/system/clash-panel.service
        systemctl daemon-reload
        log_info "删除 systemd 服务文件"
    fi
    
    # 删除 PID 文件
    if [ -f "/var/run/clash-panel.pid" ]; then
        rm -f /var/run/clash-panel.pid
    fi
    
    log_info "文件删除完成"
}

# 清理防火墙规则
cleanup_firewall() {
    log_step "清理防火墙规则..."
    
    if command -v uci &> /dev/null; then
        # OpenWrt 防火墙清理
        uci delete firewall.$(uci show firewall | grep ClashPanel | cut -d'=' -f1 | cut -d'.' -f2) 2>/dev/null || true
        uci commit firewall
        /etc/init.d/firewall restart
        log_info "OpenWrt 防火墙规则已清理"
    else
        # 通用防火墙清理
        if command -v iptables &> /dev/null; then
            iptables -D INPUT -p tcp --dport 8000 -j ACCEPT 2>/dev/null || true
            log_info "iptables 规则已清理"
        fi
    fi
}

# 清理 Python 包（可选）
cleanup_python_packages() {
    log_step "清理 Python 包..."
    
    read -p "是否删除安装的 Python 包？(y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        pip3 uninstall -y fastapi uvicorn pyyaml python-multipart aiofiles psutil 2>/dev/null || true
        log_info "Python 包已清理"
    else
        log_info "保留 Python 包"
    fi
}

# 显示卸载信息
show_uninstall_info() {
    log_step "卸载完成！"
    echo
    echo "╔══════════════════════════════════════════════════════════════╗"
    echo "║                    卸载信息                                   ║"
    echo "╠══════════════════════════════════════════════════════════════╣"
    echo "║ ✅ 服务已停止                                               ║"
    echo "║ ✅ 文件已删除                                               ║"
    echo "║ ✅ 防火墙规则已清理                                         ║"
    echo "╚══════════════════════════════════════════════════════════════╝"
    echo
    echo "📋 清理内容:"
    echo "   - 安装目录: /opt/clash-panel"
    echo "   - 服务文件: /etc/init.d/clash-panel"
    echo "   - 系统服务: /etc/systemd/system/clash-panel.service"
    echo "   - 防火墙规则: 端口 8000"
    echo
    echo "⚠️  注意事项:"
    echo "   - 配置文件备份已保留在 /opt/clash-panel/backups/ (如果存在)"
    echo "   - 如需重新安装，请运行: ./deploy.sh"
    echo
}

# 主函数
main() {
    show_banner
    
    check_root
    stop_services
    remove_files
    cleanup_firewall
    cleanup_python_packages
    show_uninstall_info
}

# 错误处理
trap 'log_error "卸载过程中发生错误"; exit 1' ERR

# 运行主函数
main "$@" 