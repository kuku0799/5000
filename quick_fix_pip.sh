#!/bin/bash

# 快速修复pip3 magic number错误
# 适用于OpenWrt系统

echo "🔧 快速修复pip3 magic number错误..."
echo "====================================="

# 检查root权限
if [[ $EUID -ne 0 ]]; then
    echo "❌ 需要root权限运行此脚本"
    exit 1
fi

echo "📋 步骤1: 备份当前pip3..."
if command -v pip3 &> /dev/null; then
    cp -f /usr/bin/pip3 /usr/bin/pip3.backup 2>/dev/null || true
    echo "✅ 已备份pip3"
fi

echo "📋 步骤2: 清理损坏的文件..."
rm -f /usr/bin/pip3
rm -rf ~/.cache/pip 2>/dev/null || true
rm -rf /root/.cache/pip 2>/dev/null || true
echo "✅ 已清理损坏文件"

echo "📋 步骤3: 重新安装pip3..."
opkg update
opkg install python3-pip --force-reinstall

echo "📋 步骤4: 验证安装..."
if command -v pip3 &> /dev/null && pip3 --version &> /dev/null; then
    echo "✅ pip3修复成功！"
    pip3 --version
else
    echo "⚠️  pip3仍有问题，尝试使用get-pip.py..."
    wget -O /tmp/get-pip.py https://bootstrap.pypa.io/get-pip.py
    python3 /tmp/get-pip.py --force-reinstall
    
    if command -v pip3 &> /dev/null && pip3 --version &> /dev/null; then
        echo "✅ pip3修复成功！"
        pip3 --version
    else
        echo "❌ pip3修复失败，请手动检查"
        exit 1
    fi
fi

echo
echo "🎉 pip3修复完成！"
echo "📋 测试命令："
echo "  pip3 --version"
echo "  pip3 install flask" 