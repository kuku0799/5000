#!/bin/bash

# OpenClash节点管理系统 - Git提交脚本
# 用于快速提交所有更改到GitHub

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

# 检查Git状态
check_git_status() {
    log_step "检查Git状态..."
    
    if ! command -v git &> /dev/null; then
        log_error "Git未安装，请先安装Git"
        exit 1
    fi
    
    if ! git rev-parse --git-dir > /dev/null 2>&1; then
        log_error "当前目录不是Git仓库"
        exit 1
    fi
    
    log_info "Git状态检查通过"
}

# 显示更改的文件
show_changes() {
    log_step "显示更改的文件..."
    
    echo "=== 新增文件 ==="
    git status --porcelain | grep "^??" | cut -c4- || echo "无新增文件"
    
    echo
    echo "=== 修改文件 ==="
    git status --porcelain | grep "^ M" | cut -c4- || echo "无修改文件"
    
    echo
    echo "=== 删除文件 ==="
    git status --porcelain | grep "^ D" | cut -c4- || echo "无删除文件"
}

# 添加文件到暂存区
add_files() {
    log_step "添加文件到暂存区..."
    
    # 添加所有文件
    git add .
    
    # 检查是否有文件被添加
    if git diff --cached --quiet; then
        log_warn "没有文件需要提交"
        return 1
    fi
    
    log_info "文件已添加到暂存区"
    return 0
}

# 创建提交
create_commit() {
    local commit_message="$1"
    
    if [[ -z "$commit_message" ]]; then
        commit_message="feat: 添加开机自启动和后台运行功能

- 新增开机自启动脚本 (auto_start.sh)
- 新增服务管理脚本 (service_manager.sh)
- 新增完整systemd安装脚本 (systemd_service.sh)
- 更新一键安装脚本，集成开机自启动功能
- 更新主文档，添加服务管理说明
- 新增详细的使用文档和故障排除指南
- 添加GitHub Actions工作流
- 优化服务架构和安全配置"
    fi
    
    log_step "创建提交..."
    
    if git commit -m "$commit_message"; then
        log_info "✅ 提交创建成功"
        return 0
    else
        log_error "❌ 提交创建失败"
        return 1
    fi
}

# 推送到远程仓库
push_to_remote() {
    log_step "推送到远程仓库..."
    
    # 获取当前分支
    local current_branch=$(git branch --show-current)
    
    if git push origin "$current_branch"; then
        log_info "✅ 推送成功"
        return 0
    else
        log_error "❌ 推送失败"
        return 1
    fi
}

# 创建标签
create_tag() {
    local tag_name="$1"
    
    if [[ -z "$tag_name" ]]; then
        # 自动生成标签名
        local date=$(date +%Y%m%d)
        local time=$(date +%H%M)
        tag_name="v1.1.0-${date}-${time}"
    fi
    
    log_step "创建标签: $tag_name"
    
    if git tag "$tag_name"; then
        log_info "✅ 标签创建成功: $tag_name"
        
        if git push origin "$tag_name"; then
            log_info "✅ 标签推送成功"
            return 0
        else
            log_warn "⚠️  标签推送失败"
            return 1
        fi
    else
        log_error "❌ 标签创建失败"
        return 1
    fi
}

# 显示帮助信息
show_help() {
    echo "🔧 OpenClash节点管理系统 - Git提交工具"
    echo "========================================"
    echo
    echo "用法: $0 [选项]"
    echo
    echo "选项:"
    echo "  -m, --message <消息>  指定提交消息"
    echo "  -t, --tag <标签名>     创建并推送标签"
    echo "  -p, --push            推送到远程仓库"
    echo "  -s, --status          显示Git状态"
    echo "  -h, --help            显示此帮助信息"
    echo
    echo "示例:"
    echo "  $0                     # 使用默认消息提交"
    echo "  $0 -m '自定义消息'      # 使用自定义消息提交"
    echo "  $0 -p                  # 提交并推送"
    echo "  $0 -t v1.1.0          # 提交并创建标签"
    echo "  $0 -s                  # 显示状态"
    echo
}

# 主函数
main() {
    local commit_message=""
    local tag_name=""
    local should_push=false
    local show_status=false
    
    # 解析命令行参数
    while [[ $# -gt 0 ]]; do
        case $1 in
            -m|--message)
                commit_message="$2"
                shift 2
                ;;
            -t|--tag)
                tag_name="$2"
                shift 2
                ;;
            -p|--push)
                should_push=true
                shift
                ;;
            -s|--status)
                show_status=true
                shift
                ;;
            -h|--help)
                show_help
                exit 0
                ;;
            *)
                log_error "未知选项: $1"
                show_help
                exit 1
                ;;
        esac
    done
    
    echo "🚀 OpenClash节点管理系统 - Git提交工具"
    echo "========================================"
    echo
    
    check_git_status
    
    if [[ "$show_status" == true ]]; then
        show_changes
        exit 0
    fi
    
    if ! add_files; then
        log_warn "没有文件需要提交"
        exit 0
    fi
    
    if ! create_commit "$commit_message"; then
        exit 1
    fi
    
    if [[ "$should_push" == true ]]; then
        if ! push_to_remote; then
            exit 1
        fi
    fi
    
    if [[ -n "$tag_name" ]]; then
        create_tag "$tag_name"
    fi
    
    echo
    log_info "🎉 Git操作完成！"
    echo
    echo "📋 提交内容："
    echo "  - 新增开机自启动脚本"
    echo "  - 新增服务管理工具"
    echo "  - 更新一键安装脚本"
    echo "  - 更新文档和说明"
    echo "  - 添加GitHub Actions工作流"
    echo
    echo "🔗 远程仓库：https://github.com/kuku0799/5000"
    echo
}

# 运行主函数
main "$@" 