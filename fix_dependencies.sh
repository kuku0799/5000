#!/bin/bash

# 快速修复依赖脚本
# 解决 ruamel.yaml 缺失问题

echo "🔧 修复依赖问题..."

# 检查并安装 ruamel.yaml
if ! python3 -c "import ruamel.yaml" 2>/dev/null; then
    echo "📦 安装 ruamel.yaml..."
    
    # 尝试使用 pip3 安装
    if command -v pip3 &> /dev/null; then
        pip3 install ruamel.yaml==0.18.6
        echo "✅ 使用 pip3 安装 ruamel.yaml 完成"
    else
        # 尝试使用 opkg 安装
        opkg install python3-ruamel-yaml
        echo "✅ 使用 opkg 安装 ruamel.yaml 完成"
    fi
else
    echo "✅ ruamel.yaml 已安装"
fi

# 检查并安装其他依赖
echo "📦 检查其他依赖..."

# 检查 Flask
if ! python3 -c "import flask" 2>/dev/null; then
    echo "📦 安装 Flask..."
    if command -v pip3 &> /dev/null; then
        pip3 install Flask==2.3.3
    else
        opkg install python3-flask
    fi
fi

# 检查 Werkzeug
if ! python3 -c "import werkzeug" 2>/dev/null; then
    echo "📦 安装 Werkzeug..."
    if command -v pip3 &> /dev/null; then
        pip3 install Werkzeug==2.3.7
    else
        opkg install python3-werkzeug
    fi
fi

echo "🎉 依赖修复完成！"
echo ""
echo "现在可以重新启动服务："
echo "cd /root/OpenClashManage && ./start_all.sh" 