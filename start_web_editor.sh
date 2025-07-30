#!/bin/bash

# Wangluo Web编辑器启动脚本

echo "🌐 启动 Wangluo Web编辑器..."

# 检查Python3是否安装
if ! command -v python3 &> /dev/null; then
    echo "❌ Python3 未安装，请先安装 Python3"
    exit 1
fi

# 检查Flask是否安装
if ! python3 -c "import flask" &> /dev/null; then
    echo "📦 安装依赖包..."
    pip3 install -r requirements.txt
fi

# 确保目录存在
mkdir -p /root/OpenClashManage/wangluo
mkdir -p templates

# 启动Web服务器
echo "🚀 启动Web服务器..."
echo "📱 访问地址: http://$(hostname -I | awk '{print $1}'):5000"
echo "📁 文件目录: /root/OpenClashManage/wangluo"
echo "⏹️  按 Ctrl+C 停止服务"

python3 web_editor.py 