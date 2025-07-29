#!/bin/bash

# OpenClash 管理系统卸载脚本
# 作者: AI Assistant
# 版本: 1.0

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

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
    
    # 停止同步服务
    if [ -f /etc/init.d/openclash-sync ]; then
        /etc/init.d/openclash-sync stop
        /etc/init.d/openclash-sync disable
    fi
    
    # 停止 OpenClash
    if [ -f /etc/init.d/openclash ]; then
        /etc/init.d/openclash stop
    fi
    
    # 杀死相关进程
    pkill -f "jk.sh" 2>/dev/null || true
    pkill -f "zr.py" 2>/dev/null || true
    
    log_info "服务已停止"
}

# 删除文件
remove_files() {
    log_step "删除文件..."
    
    # 删除脚本目录
    if [ -d "/root/OpenClashManage" ]; then
        rm -rf /root/OpenClashManage
        log_info "删除脚本目录: /root/OpenClashManage"
    fi
    
    # 删除服务文件
    if [ -f "/etc/init.d/openclash-sync" ]; then
        rm -f /etc/init.d/openclash-sync
        log_info "删除服务文件: /etc/init.d/openclash-sync"
    fi
    
    # 删除 PID 文件
    if [ -f "/var/run/openclash-sync.pid" ]; then
        rm -f /var/run/openclash-sync.pid
    fi
    
    # 删除锁文件
    if [ -f "/tmp/openclash_update.lock" ]; then
        rm -f /tmp/openclash_update.lock
    fi
    
    log_info "文件删除完成"
}

# 清理防火墙规则
cleanup_firewall() {
    log_step "清理防火墙规则..."
    
    if command -v uci &> /dev/null; then
        # 删除 OpenClash 相关防火墙规则
        uci show firewall | grep "OpenClash" | cut -d'=' -f1 | while read rule; do
            if [ -n "$rule" ]; then
                uci delete "$rule" 2>/dev/null || true
            fi
        done
        uci commit firewall
        /etc/init.d/firewall restart
        log_info "防火墙规则已清理"
    fi
}

# 卸载 OpenClash（可选）
uninstall_openclash() {
    log_step "卸载 OpenClash（可选）..."
    
    read -p "是否要卸载 OpenClash？(y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        # 卸载 OpenClash
        if opkg list-installed | grep -q "luci-app-openclash"; then
            opkg remove luci-app-openclash
            log_info "OpenClash 已卸载"
        fi
        
        # 卸载 Python 包
        pip3 uninstall ruamel.yaml -y 2>/dev/null || true
        
        log_info "OpenClash 卸载完成"
    else
        log_info "保留 OpenClash 安装"
    fi
}

# 清理日志
cleanup_logs() {
    log_step "清理日志..."
    
    # 清理系统日志中的相关条目
    if [ -f "/var/log/messages" ]; then
        sed -i '/openclash-sync/d' /var/log/messages 2>/dev/null || true
    fi
    
    log_info "日志清理完成"
}

# 显示卸载信息
show_uninstall_info() {
    log_step "卸载完成！"
    echo
    echo "=========================================="
    echo "          卸载完成"
    echo "=========================================="
    echo
    echo "✅ 已删除的文件:"
    echo "   - /root/OpenClashManage/ (整个目录)"
    echo "   - /etc/init.d/openclash-sync"
    echo "   - 相关 PID 和锁文件"
    echo
    echo "✅ 已停止的服务:"
    echo "   - OpenClash 同步服务"
    echo "   - 相关后台进程"
    echo
    echo "⚠️  注意事项:"
    echo "   - OpenClash 本身未被卸载（如果选择保留）"
    echo "   - 配置文件可能需要手动清理"
    echo "   - 建议重启路由器以确保完全清理"
    echo
    echo "=========================================="
}

# 主函数
main() {
    echo "=========================================="
    echo "      OpenClash 管理系统卸载"
    echo "=========================================="
    echo
    
    check_root
    stop_services
    remove_files
    cleanup_firewall
    cleanup_logs
    uninstall_openclash
    show_uninstall_info
}

# 错误处理
trap 'log_error "卸载过程中发生错误"; exit 1' ERR

# 运行主函数
main "$@" 