#!/bin/bash

# OpenClash节点管理系统 - pip3修复脚本
# 用于修复pip3的magic number错误

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

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

# 备份当前pip
backup_pip() {
    log_step "备份当前pip配置..."
    
    if command -v pip3 &> /dev/null; then
        cp -f /usr/bin/pip3 /usr/bin/pip3.backup 2>/dev/null || true
        log_info "已备份pip3到 /usr/bin/pip3.backup"
    fi
    
    if command -v pip &> /dev/null; then
        cp -f /usr/bin/pip /usr/bin/pip.backup 2>/dev/null || true
        log_info "已备份pip到 /usr/bin/pip.backup"
    fi
}

# 清理损坏的pip文件
clean_pip() {
    log_step "清理损坏的pip文件..."
    
    # 删除可能损坏的pip文件
    rm -f /usr/bin/pip3
    rm -f /usr/bin/pip
    
    # 清理pip缓存
    rm -rf ~/.cache/pip 2>/dev/null || true
    rm -rf /root/.cache/pip 2>/dev/null || true
    
    log_info "已清理损坏的pip文件"
}

# 重新安装pip
reinstall_pip() {
    log_step "重新安装pip..."
    
    # 下载get-pip.py
    log_info "下载pip安装脚本..."
    wget -O /tmp/get-pip.py https://bootstrap.pypa.io/get-pip.py
    
    # 使用python3安装pip
    log_info "安装pip3..."
    python3 /tmp/get-pip.py --force-reinstall
    
    # 验证安装
    if command -v pip3 &> /dev/null; then
        log_info "✅ pip3安装成功"
        pip3 --version
    else
        log_error "❌ pip3安装失败"
        return 1
    fi
}

# 使用opkg安装pip（OpenWrt系统）
install_pip_opkg() {
    log_step "使用opkg安装pip..."
    
    # 更新软件包列表
    opkg update
    
    # 安装python3-pip
    log_info "安装python3-pip..."
    opkg install python3-pip --force-reinstall
    
    # 验证安装
    if command -v pip3 &> /dev/null; then
        log_info "✅ pip3安装成功"
        pip3 --version
        return 0
    else
        log_error "❌ pip3安装失败"
        return 1
    fi
}

# 修复Python环境
fix_python_env() {
    log_step "修复Python环境..."
    
    # 检查Python版本
    log_info "Python版本信息："
    python3 --version
    
    # 重新安装Python相关包
    if command -v opkg &> /dev/null; then
        log_info "检测到OpenWrt系统，使用opkg修复..."
        opkg update
        opkg install python3 python3-pip python3-setuptools --force-reinstall
    else
        log_info "使用系统包管理器修复..."
        # 尝试使用apt或yum
        if command -v apt &> /dev/null; then
            apt update && apt install python3-pip --reinstall
        elif command -v yum &> /dev/null; then
            yum reinstall python3-pip
        fi
    fi
}

# 测试pip功能
test_pip() {
    log_step "测试pip功能..."
    
    # 测试pip3
    if command -v pip3 &> /dev/null; then
        log_info "测试pip3..."
        if pip3 --version; then
            log_info "✅ pip3工作正常"
        else
            log_error "❌ pip3仍有问题"
            return 1
        fi
    fi
    
    # 测试pip
    if command -v pip &> /dev/null; then
        log_info "测试pip..."
        if pip --version; then
            log_info "✅ pip工作正常"
        else
            log_error "❌ pip仍有问题"
            return 1
        fi
    fi
    
    return 0
}

# 安装项目依赖
install_dependencies() {
    log_step "安装项目依赖..."
    
    # 检查是否有requirements.txt
    if [[ -f "requirements.txt" ]]; then
        log_info "安装Python依赖..."
        if pip3 install -r requirements.txt; then
            log_info "✅ 依赖安装成功"
        else
            log_warn "⚠️  依赖安装失败，尝试使用opkg"
            opkg install python3-flask python3-werkzeug python3-ruamel-yaml
        fi
    else
        log_warn "未找到requirements.txt文件"
    fi
}

# 显示修复结果
show_result() {
    log_step "修复完成！"
    
    echo
    echo "🔧 pip3修复结果："
    echo "=================="
    
    if command -v pip3 &> /dev/null; then
        echo "✅ pip3: $(pip3 --version)"
    else
        echo "❌ pip3: 未安装"
    fi
    
    if command -v pip &> /dev/null; then
        echo "✅ pip: $(pip --version)"
    else
        echo "❌ pip: 未安装"
    fi
    
    echo
    echo "📋 测试命令："
    echo "  pip3 --version"
    echo "  pip3 install flask"
    echo "  python3 -c 'import flask; print(\"Flask安装成功\")'"
    echo
}

# 主函数
main() {
    echo "🔧 OpenClash节点管理系统 - pip3修复工具"
    echo "========================================"
    echo
    
    check_root
    backup_pip
    clean_pip
    fix_python_env
    
    # 尝试重新安装pip
    if ! reinstall_pip; then
        log_warn "pip重新安装失败，尝试使用opkg..."
        if ! install_pip_opkg; then
            log_error "所有pip安装方法都失败了"
            exit 1
        fi
    fi
    
    test_pip
    install_dependencies
    show_result
    
    echo
    log_info "🎉 pip3修复完成！"
    echo
}

# 运行主函数
main "$@" 