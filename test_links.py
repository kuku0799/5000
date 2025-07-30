#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import requests
import sys

def test_url(url, description):
    """测试URL是否可以正常访问"""
    try:
        response = requests.head(url, timeout=10)
        if response.status_code == 200:
            print(f"✅ {description}: {url}")
            return True
        else:
            print(f"❌ {description}: {url} (状态码: {response.status_code})")
            return False
    except Exception as e:
        print(f"❌ {description}: {url} (错误: {e})")
        return False

def main():
    """测试所有GitHub链接"""
    base_url = "https://raw.githubusercontent.com/kuku0799/5000/main"
    
    # 需要测试的文件列表
    files_to_test = [
        ("install.sh", "一键安装脚本"),
        ("jk.sh", "守护进程脚本"),
        ("zr.py", "主控制器"),
        ("jx.py", "节点解析器"),
        ("zw.py", "代理注入器"),
        ("zc.py", "策略组注入器"),
        ("log.py", "日志管理器"),
        ("web_editor.py", "Web编辑器"),
        ("templates/index.html", "前端界面"),
        ("requirements.txt", "Python依赖"),
        ("start_web_editor.sh", "启动脚本"),
        ("README.md", "主说明文档"),
        ("README_Web_Editor.md", "Web编辑器说明"),
        ("QUICK_DEPLOY.md", "快速部署指南"),
        ("LICENSE", "许可证文件")
    ]
    
    print("🌐 测试 GitHub 链接可用性")
    print("=" * 50)
    
    success_count = 0
    total_count = len(files_to_test)
    
    for filename, description in files_to_test:
        url = f"{base_url}/{filename}"
        if test_url(url, description):
            success_count += 1
    
    print("=" * 50)
    print(f"📊 测试结果: {success_count}/{total_count} 个文件可正常访问")
    
    if success_count == total_count:
        print("🎉 所有文件都可以正常访问！")
        print("\n🚀 一键部署命令:")
        print("wget -O - https://raw.githubusercontent.com/kuku0799/5000/main/install.sh | bash")
        print("\n或者:")
        print("curl -sSL https://raw.githubusercontent.com/kuku0799/5000/main/install.sh | bash")
        return True
    else:
        print("⚠️  部分文件无法访问，请检查GitHub仓库状态")
        return False

if __name__ == "__main__":
    success = main()
    sys.exit(0 if success else 1) 