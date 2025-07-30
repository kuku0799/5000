#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import os
import json
from flask import Flask, render_template, request, jsonify, send_from_directory
from werkzeug.utils import secure_filename
import logging

app = Flask(__name__)
app.secret_key = 'your-secret-key-here'

# 配置
WANGLUO_DIR = "/root/OpenClashManage/wangluo"
LOG_FILE = "/root/OpenClashManage/wangluo/web_editor.log"

# 设置日志
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(levelname)s - %(message)s',
    handlers=[
        logging.FileHandler(LOG_FILE),
        logging.StreamHandler()
    ]
)

def get_file_list():
    """获取wangluo目录下的文件列表"""
    try:
        if not os.path.exists(WANGLUO_DIR):
            os.makedirs(WANGLUO_DIR, exist_ok=True)
        
        files = []
        for filename in os.listdir(WANGLUO_DIR):
            filepath = os.path.join(WANGLUO_DIR, filename)
            if os.path.isfile(filepath):
                files.append({
                    'name': filename,
                    'size': os.path.getsize(filepath),
                    'modified': os.path.getmtime(filepath)
                })
        return files
    except Exception as e:
        logging.error(f"获取文件列表失败: {e}")
        return []

def read_file_content(filename):
    """读取文件内容"""
    try:
        filepath = os.path.join(WANGLUO_DIR, secure_filename(filename))
        if not os.path.exists(filepath):
            return None
        
        with open(filepath, 'r', encoding='utf-8') as f:
            return f.read()
    except Exception as e:
        logging.error(f"读取文件失败 {filename}: {e}")
        return None

def write_file_content(filename, content):
    """写入文件内容"""
    try:
        filepath = os.path.join(WANGLUO_DIR, secure_filename(filename))
        
        # 确保目录存在
        os.makedirs(os.path.dirname(filepath), exist_ok=True)
        
        with open(filepath, 'w', encoding='utf-8') as f:
            f.write(content)
        
        logging.info(f"文件保存成功: {filename}")
        return True
    except Exception as e:
        logging.error(f"保存文件失败 {filename}: {e}")
        return False

@app.route('/')
def index():
    """主页面"""
    files = get_file_list()
    return render_template('index.html', files=files)

@app.route('/api/files')
def api_files():
    """API: 获取文件列表"""
    files = get_file_list()
    return jsonify({'success': True, 'files': files})

@app.route('/api/file/<filename>')
def api_read_file(filename):
    """API: 读取文件内容"""
    content = read_file_content(filename)
    if content is not None:
        return jsonify({'success': True, 'content': content})
    else:
        return jsonify({'success': False, 'error': '文件不存在或读取失败'})

@app.route('/api/file/<filename>', methods=['POST'])
def api_write_file(filename):
    """API: 写入文件内容"""
    try:
        data = request.get_json()
        content = data.get('content', '')
        
        if write_file_content(filename, content):
            return jsonify({'success': True, 'message': '文件保存成功'})
        else:
            return jsonify({'success': False, 'error': '文件保存失败'})
    except Exception as e:
        logging.error(f"API写入文件失败: {e}")
        return jsonify({'success': False, 'error': str(e)})

@app.route('/api/file/<filename>', methods=['DELETE'])
def api_delete_file(filename):
    """API: 删除文件"""
    try:
        filepath = os.path.join(WANGLUO_DIR, secure_filename(filename))
        if os.path.exists(filepath):
            os.remove(filepath)
            logging.info(f"文件删除成功: {filename}")
            return jsonify({'success': True, 'message': '文件删除成功'})
        else:
            return jsonify({'success': False, 'error': '文件不存在'})
    except Exception as e:
        logging.error(f"删除文件失败 {filename}: {e}")
        return jsonify({'success': False, 'error': str(e)})

@app.route('/api/file', methods=['POST'])
def api_create_file():
    """API: 创建新文件"""
    try:
        data = request.get_json()
        filename = data.get('filename', '')
        
        if not filename:
            return jsonify({'success': False, 'error': '文件名不能为空'})
        
        filename = secure_filename(filename)
        filepath = os.path.join(WANGLUO_DIR, filename)
        
        if os.path.exists(filepath):
            return jsonify({'success': False, 'error': '文件已存在'})
        
        # 创建空文件
        with open(filepath, 'w', encoding='utf-8') as f:
            f.write('')
        
        logging.info(f"文件创建成功: {filename}")
        return jsonify({'success': True, 'message': '文件创建成功'})
    except Exception as e:
        logging.error(f"创建文件失败: {e}")
        return jsonify({'success': False, 'error': str(e)})

if __name__ == '__main__':
    # 确保目录存在
    os.makedirs(WANGLUO_DIR, exist_ok=True)
    
    # 创建templates目录
    templates_dir = os.path.join(os.path.dirname(__file__), 'templates')
    os.makedirs(templates_dir, exist_ok=True)
    
    print(f"Web编辑器启动中...")
    print(f"访问地址: http://localhost:5000")
    print(f"文件目录: {WANGLUO_DIR}")
    
    app.run(host='0.0.0.0', port=5000, debug=False) 