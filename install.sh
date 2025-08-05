#!/bin/bash

# OpenClash 节点管理系统一键安装脚本
# 适用于 OpenWrt 系统

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

# 安装 Python3
install_python3() {
    log_step "安装 Python3..."
    
    if command -v python3 &> /dev/null; then
        log_info "Python3 已安装"
        return 0
    fi
    
    # 更新软件包列表
    opkg update
    
    # 安装 Python3 和相关包
    log_info "正在安装 Python3..."
    opkg install python3 python3-pip python3-requests python3-yaml python3-ruamel-yaml
    
    # 验证安装
    if command -v python3 &> /dev/null; then
        log_info "Python3 安装成功"
        return 0
    else
        log_error "Python3 安装失败"
        return 1
    fi
}

# 安装 pip3
install_pip3() {
    log_step "安装 pip3..."
    
    if command -v pip3 &> /dev/null; then
        log_info "pip3 已安装"
        return 0
    fi
    
    # 尝试安装 pip3
    opkg install python3-pip
    
    # 验证安装
    if command -v pip3 &> /dev/null; then
        log_info "pip3 安装成功"
        return 0
    else
        log_warn "pip3 安装失败，将使用 opkg 安装依赖"
        return 1
    fi
}

# 检查系统
check_system() {
    log_step "检查系统环境..."
    
    # 检查是否为 OpenWrt
    if [ ! -f "/etc/openwrt_release" ]; then
        log_warn "未检测到 OpenWrt 系统，但继续安装..."
    fi
    
    # 检查并安装 Python3
    if ! command -v python3 &> /dev/null; then
        log_warn "Python3 未安装，正在自动安装..."
        if ! install_python3; then
            log_error "无法安装 Python3，请手动安装后重试"
            log_info "手动安装命令：opkg update && opkg install python3 python3-pip"
            exit 1
        fi
    fi
    
    # 检查并安装 pip3
    if ! command -v pip3 &> /dev/null; then
        log_warn "pip3 未安装，正在自动安装..."
        install_pip3
    fi
    
    # 检查 OpenClash
    if [ ! -f "/etc/init.d/openclash" ]; then
        log_warn "未检测到 OpenClash，请确保已安装 OpenClash"
        log_info "OpenClash 安装命令：opkg install luci-app-openclash"
    fi
    
    log_info "系统检查完成"
}

# 创建目录结构
create_directories() {
    log_step "创建目录结构..."
    
    mkdir -p /root/OpenClashManage/wangluo
    mkdir -p /root/OpenClashManage/logs
    
    log_info "目录创建完成"
}

# 下载文件
download_files() {
    log_step "下载项目文件..."
    
    # 设置 GitHub 仓库信息
    GITHUB_USER="kuku0799"
    GITHUB_REPO="5000"
    GITHUB_BRANCH="main"
    
    # 下载核心文件
    log_info "下载核心系统文件..."
    
    # 下载 jk.sh
    wget -O /root/OpenClashManage/jk.sh \
        "https://raw.githubusercontent.com/${GITHUB_USER}/${GITHUB_REPO}/${GITHUB_BRANCH}/jk.sh"
    
    # 下载 Python 文件
    for file in zr.py jx.py zw.py zc.py log.py; do
        wget -O "/root/OpenClashManage/${file}" \
            "https://raw.githubusercontent.com/${GITHUB_USER}/${GITHUB_REPO}/${GITHUB_BRANCH}/${file}"
    done
    
    # 下载 Web 编辑器
    log_info "下载 Web 编辑器文件..."
    
    wget -O /root/OpenClashManage/web_editor.py \
        "https://raw.githubusercontent.com/${GITHUB_USER}/${GITHUB_REPO}/${GITHUB_BRANCH}/web_editor.py"
    
    mkdir -p /root/OpenClashManage/templates
    wget -O /root/OpenClashManage/templates/index.html \
        "https://raw.githubusercontent.com/${GITHUB_USER}/${GITHUB_REPO}/${GITHUB_BRANCH}/templates/index.html"
    
    # 下载依赖文件
    wget -O /root/OpenClashManage/requirements.txt \
        "https://raw.githubusercontent.com/${GITHUB_USER}/${GITHUB_REPO}/${GITHUB_BRANCH}/requirements.txt"
    
    # 下载启动脚本
    wget -O /root/OpenClashManage/start_web_editor.sh \
        "https://raw.githubusercontent.com/${GITHUB_USER}/${GITHUB_REPO}/${GITHUB_BRANCH}/start_web_editor.sh"
    
    # 下载开机自启动相关脚本
    log_info "下载开机自启动脚本..."
    
    wget -O /root/OpenClashManage/auto_start.sh \
        "https://raw.githubusercontent.com/${GITHUB_USER}/${GITHUB_REPO}/${GITHUB_BRANCH}/auto_start.sh"
    
    wget -O /root/OpenClashManage/service_manager.sh \
        "https://raw.githubusercontent.com/${GITHUB_USER}/${GITHUB_REPO}/${GITHUB_BRANCH}/service_manager.sh"
    
    wget -O /root/OpenClashManage/systemd_service.sh \
        "https://raw.githubusercontent.com/${GITHUB_USER}/${GITHUB_REPO}/${GITHUB_BRANCH}/systemd_service.sh"
    
    log_info "文件下载完成"
}

# 设置权限
set_permissions() {
    log_step "设置文件权限..."
    
    chmod +x /root/OpenClashManage/jk.sh
    chmod +x /root/OpenClashManage/start_web_editor.sh
    chmod +x /root/OpenClashManage/auto_start.sh
    chmod +x /root/OpenClashManage/service_manager.sh
    chmod +x /root/OpenClashManage/systemd_service.sh
    
    log_info "权限设置完成"
}

# 安装依赖
install_dependencies() {
    log_step "安装 Python 依赖..."
    
    if command -v pip3 &> /dev/null; then
        log_info "使用 pip3 安装依赖..."
        pip3 install -r /root/OpenClashManage/requirements.txt
        log_info "Python 依赖安装完成"
    else
        log_warn "pip3 未找到，尝试使用 opkg 安装依赖..."
        # 尝试使用 opkg 安装依赖
        opkg install python3-flask python3-werkzeug python3-ruamel-yaml
        log_info "使用 opkg 安装依赖完成"
    fi
}

# 创建示例文件
create_sample_files() {
    log_step "创建示例文件..."
    
    # 创建示例 nodes.txt
    cat > /root/OpenClashManage/wangluo/nodes.txt << 'EOF'
# 在此粘贴你的节点链接，一行一个，支持 ss:// vmess:// vless:// trojan://协议

# 示例节点格式：
# ss://YWVzLTI1Ni1nY206cGFzc3dvcmQ=@server.com:8388#节点名称
# vmess://eyJhZGQiOiJzZXJ2ZXIuY29tIiwicG9ydCI6NDQzLCJpZCI6IjEyMzQ1Njc4LTkwYWItMTFlYy1hYzE1LTAwMTYzYzFhYzE1NSIsImFpZCI6MCwidHlwZSI6Im5vbmUiLCJob3N0IjoiIiwicGF0aCI6IiIsInRscyI6InRscyJ9#节点名称
# vless://uuid@server.com:443?security=tls#节点名称
# trojan://password@server.com:443#节点名称
EOF

    # 创建日志文件
    touch /root/OpenClashManage/wangluo/log.txt
    
    log_info "示例文件创建完成"
}

# 创建服务脚本
create_service_scripts() {
    log_step "创建服务脚本..."
    
    # 创建启动脚本
    cat > /root/OpenClashManage/start_all.sh << 'EOF'
#!/bin/bash

# 启动所有服务

echo "🚀 启动 OpenClash 节点管理系统..."

# 启动 Web 编辑器
echo "📱 启动 Web 编辑器..."
cd /root/OpenClashManage
nohup python3 web_editor.py > /dev/null 2>&1 &
echo "✅ Web 编辑器已启动，访问地址: http://$(hostname -I | awk '{print $1}'):5000"

# 启动守护进程
echo "🔄 启动守护进程..."
nohup ./jk.sh > /dev/null 2>&1 &
echo "✅ 守护进程已启动"

echo "🎉 所有服务启动完成！"
echo "📱 Web编辑器: http://$(hostname -I | awk '{print $1}'):5000"
echo "📁 配置文件: /root/OpenClashManage/wangluo/"
EOF

    # 创建停止脚本
    cat > /root/OpenClashManage/stop_all.sh << 'EOF'
#!/bin/bash

# 停止所有服务

echo "🛑 停止 OpenClash 节点管理系统..."

# 停止 Web 编辑器
pkill -f "python3 web_editor.py"
echo "✅ Web 编辑器已停止"

# 停止守护进程
pkill -f "jk.sh"
echo "✅ 守护进程已停止"

echo "🎉 所有服务已停止！"
EOF

    chmod +x /root/OpenClashManage/start_all.sh
    chmod +x /root/OpenClashManage/stop_all.sh
    
    log_info "服务脚本创建完成"
}

# 安装systemd服务
install_systemd_service() {
    log_step "安装systemd服务（开机自启动）..."
    
    # 检查是否支持systemd
    if ! command -v systemctl &> /dev/null; then
        log_warn "系统不支持systemd，跳过开机自启动设置"
        log_info "您可以手动运行以下命令启动服务："
        log_info "  cd /root/OpenClashManage && ./start_all.sh"
        return 0
    fi
    
    # 使用自动启动脚本安装服务
    cd /root/OpenClashManage
    if ./auto_start.sh; then
        log_info "✅ systemd服务安装成功"
        log_info "✅ 开机自启动已启用"
        return 0
    else
        log_warn "⚠️  systemd服务安装失败，将使用手动启动方式"
        log_info "您可以手动运行以下命令启动服务："
        log_info "  cd /root/OpenClashManage && ./start_all.sh"
        return 1
    fi
}

# 显示安装信息
show_install_info() {
    log_step "安装完成！"
    
    echo ""
    echo "🎉 OpenClash 节点管理系统安装完成！"
    echo ""
    echo "📁 安装目录: /root/OpenClashManage/"
    echo "📱 Web编辑器: http://$(hostname -I | awk '{print $1}'):5000"
    echo "📝 配置文件: /root/OpenClashManage/wangluo/nodes.txt"
    echo ""
    
    # 检查systemd服务状态
    if command -v systemctl &> /dev/null && systemctl is-enabled openclash-manager.service &> /dev/null; then
        echo "✅ 开机自启动已启用"
        echo "🚀 服务管理命令："
        echo "   启动: systemctl start openclash-manager.service"
        echo "   停止: systemctl stop openclash-manager.service"
        echo "   重启: systemctl restart openclash-manager.service"
        echo "   状态: systemctl status openclash-manager.service"
        echo "   日志: journalctl -u openclash-manager.service -f"
        echo ""
        echo "🔧 服务管理脚本："
        echo "   状态: cd /root/OpenClashManage && ./service_manager.sh status"
        echo "   日志: cd /root/OpenClashManage && ./service_manager.sh logs"
        echo "   重启: cd /root/OpenClashManage && ./service_manager.sh restart"
    else
        echo "⚠️  开机自启动未启用，使用手动启动方式"
        echo "🚀 启动服务:"
        echo "   cd /root/OpenClashManage && ./start_all.sh"
        echo ""
        echo "🛑 停止服务:"
        echo "   cd /root/OpenClashManage && ./stop_all.sh"
    fi
    
    echo ""
    echo "📖 使用说明:"
    echo "   1. 访问 Web 编辑器添加节点"
    echo "   2. 系统自动监控文件变化"
    echo "   3. 自动同步到 OpenClash"
    echo ""
    echo "🔧 高级管理："
    echo "   cd /root/OpenClashManage && ./service_manager.sh help"
    echo ""
    echo "⚠️  注意：请确保已安装 OpenClash 插件"
    echo ""
}

# 主安装流程
main() {
    echo "🌐 OpenClash 节点管理系统一键安装脚本"
    echo "=========================================="
    echo ""
    
    check_system
    create_directories
    download_files
    set_permissions
    install_dependencies
    create_sample_files
    create_service_scripts
    install_systemd_service
    show_install_info
}

# 执行安装
main "$@" 