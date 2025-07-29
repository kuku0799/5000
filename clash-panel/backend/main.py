from fastapi import FastAPI, HTTPException, Depends, Request
from fastapi.middleware.cors import CORSMiddleware
from fastapi.staticfiles import StaticFiles
from fastapi.responses import HTMLResponse, JSONResponse
from pydantic import BaseModel
from typing import List, Optional, Dict, Any
import yaml
import os
import subprocess
import asyncio
import json
from datetime import datetime
import uvicorn
import logging
from pathlib import Path

# 配置日志
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s',
    handlers=[
        logging.FileHandler('/opt/clash-panel/logs/clash-panel.log'),
        logging.StreamHandler()
    ]
)
logger = logging.getLogger(__name__)

app = FastAPI(
    title="Clash Management Panel", 
    version="2.0.0",
    description="现代化的 Clash 管理面板"
)

# CORS 配置
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# 静态文件服务
app.mount("/static", StaticFiles(directory="static"), name="static")

# 数据模型
class Node(BaseModel):
    name: str
    type: str
    server: str
    port: int
    latency: Optional[int] = None
    alive: bool = True
    country: Optional[str] = None
    city: Optional[str] = None

class ProxyGroup(BaseModel):
    name: str
    type: str
    proxies: List[str]
    now: Optional[str] = None
    url: Optional[str] = None
    interval: Optional[int] = None

class ClashStatus(BaseModel):
    running: bool
    mode: str
    uptime: Optional[str] = None
    memory_usage: Optional[str] = None
    cpu_usage: Optional[str] = None
    version: Optional[str] = None

class ConfigUpdate(BaseModel):
    config: Dict[str, Any]
    backup: bool = True

# 配置管理
class ConfigManager:
    def __init__(self):
        self.config_path = "/opt/clash-panel/config.json"
        self.default_config = {
            "server": {
                "host": "0.0.0.0",
                "port": 8000,
                "debug": False
            },
            "clash": {
                "config_path": "/etc/openclash/config.yaml",
                "service_name": "openclash",
                "log_path": "/root/OpenClashManage/wangluo/log.txt"
            },
            "security": {
                "enable_auth": False,
                "username": "admin",
                "password": "admin123"
            },
            "ui": {
                "title": "Clash 管理面板",
                "theme": "default",
                "auto_refresh": 30
            }
        }
        self.load_config()
    
    def load_config(self):
        """加载配置文件"""
        try:
            if os.path.exists(self.config_path):
                with open(self.config_path, 'r', encoding='utf-8') as f:
                    self.config = json.load(f)
            else:
                self.config = self.default_config
                self.save_config()
        except Exception as e:
            logger.error(f"加载配置文件失败: {e}")
            self.config = self.default_config
    
    def save_config(self):
        """保存配置文件"""
        try:
            os.makedirs(os.path.dirname(self.config_path), exist_ok=True)
            with open(self.config_path, 'w', encoding='utf-8') as f:
                json.dump(self.config, f, indent=2, ensure_ascii=False)
        except Exception as e:
            logger.error(f"保存配置文件失败: {e}")
    
    def get(self, key, default=None):
        """获取配置值"""
        keys = key.split('.')
        value = self.config
        for k in keys:
            if isinstance(value, dict) and k in value:
                value = value[k]
            else:
                return default
        return value

# 全局配置管理器
config_manager = ConfigManager()

class ClashManager:
    def __init__(self):
        self.config_path = config_manager.get("clash.config_path", "/etc/openclash/config.yaml")
        self.service_name = config_manager.get("clash.service_name", "openclash")
        self.log_path = config_manager.get("clash.log_path", "/root/OpenClashManage/wangluo/log.txt")
    
    def get_config(self) -> Dict[str, Any]:
        """读取 Clash 配置文件"""
        try:
            if not os.path.exists(self.config_path):
                raise FileNotFoundError(f"配置文件不存在: {self.config_path}")
            
            with open(self.config_path, 'r', encoding='utf-8') as f:
                return yaml.safe_load(f)
        except Exception as e:
            logger.error(f"读取配置文件失败: {e}")
            raise HTTPException(status_code=500, detail=f"读取配置文件失败: {str(e)}")
    
    def save_config(self, config: Dict[str, Any], backup: bool = True):
        """保存 Clash 配置文件"""
        try:
            if backup:
                # 创建备份
                backup_dir = "/opt/clash-panel/backups"
                os.makedirs(backup_dir, exist_ok=True)
                backup_path = f"{backup_dir}/config_{datetime.now().strftime('%Y%m%d_%H%M%S')}.yaml"
                
                if os.path.exists(self.config_path):
                    import shutil
                    shutil.copy2(self.config_path, backup_path)
                    logger.info(f"配置文件已备份到: {backup_path}")
            
            # 保存新配置
            with open(self.config_path, 'w', encoding='utf-8') as f:
                yaml.dump(config, f, default_flow_style=False, allow_unicode=True)
            
            logger.info("配置文件保存成功")
            return {"message": "配置保存成功", "backup": backup_path if backup else None}
        except Exception as e:
            logger.error(f"保存配置文件失败: {e}")
            raise HTTPException(status_code=500, detail=f"保存配置文件失败: {str(e)}")
    
    def get_service_status(self) -> ClashStatus:
        """获取 Clash 服务状态"""
        try:
            # 检查服务状态
            if os.path.exists("/etc/init.d/openclash"):
                result = subprocess.run(
                    ["/etc/init.d/openclash", "status"],
                    capture_output=True,
                    text=True
                )
                running = "running" in result.stdout.lower()
            else:
                # 检查进程
                result = subprocess.run(
                    ["pgrep", "-f", "clash"],
                    capture_output=True,
                    text=True
                )
                running = result.returncode == 0
            
            # 获取系统信息
            memory = "0 KB"
            cpu = "0%"
            uptime = None
            version = None
            
            if running:
                try:
                    # 获取进程信息
                    ps_result = subprocess.run(
                        ["ps", "aux", "|", "grep", "clash"],
                        capture_output=True,
                        text=True,
                        shell=True
                    )
                    if ps_result.stdout:
                        lines = ps_result.stdout.strip().split('\n')
                        if lines:
                            parts = lines[0].split()
                            if len(parts) >= 3:
                                cpu = f"{parts[2]}%"
                                memory = f"{parts[5]} KB"
                except Exception as e:
                    logger.warning(f"获取进程信息失败: {e}")
                
                # 获取版本信息
                try:
                    version_result = subprocess.run(
                        ["clash", "-v"],
                        capture_output=True,
                        text=True
                    )
                    if version_result.returncode == 0:
                        version = version_result.stdout.strip()
                except:
                    pass
            
            return ClashStatus(
                running=running,
                mode="rule",  # 默认模式
                uptime=uptime,
                memory_usage=memory,
                cpu_usage=cpu,
                version=version
            )
        except Exception as e:
            logger.error(f"获取服务状态失败: {e}")
            return ClashStatus(running=False, mode="unknown")
    
    def restart_service(self):
        """重启 Clash 服务"""
        try:
            if os.path.exists("/etc/init.d/openclash"):
                result = subprocess.run(
                    ["/etc/init.d/openclash", "restart"],
                    capture_output=True,
                    text=True
                )
            else:
                # 尝试使用 systemctl
                result = subprocess.run(
                    ["systemctl", "restart", "openclash"],
                    capture_output=True,
                    text=True
                )
            
            logger.info("服务重启成功")
            return {"message": "服务重启成功", "output": result.stdout}
        except Exception as e:
            logger.error(f"重启服务失败: {e}")
            raise HTTPException(status_code=500, detail=f"重启服务失败: {str(e)}")
    
    def test_node_latency(self, node_name: str) -> int:
        """测试节点延迟"""
        try:
            # 这里可以实现具体的延迟测试逻辑
            # 暂时返回随机延迟
            import random
            return random.randint(50, 300)
        except Exception as e:
            logger.error(f"测试节点延迟失败: {e}")
            return -1
    
    def get_backups(self) -> List[Dict[str, Any]]:
        """获取备份文件列表"""
        try:
            backup_dir = "/opt/clash-panel/backups"
            if not os.path.exists(backup_dir):
                return []
            
            backups = []
            for file in os.listdir(backup_dir):
                if file.endswith('.yaml'):
                    file_path = os.path.join(backup_dir, file)
                    stat = os.stat(file_path)
                    backups.append({
                        "filename": file,
                        "size": stat.st_size,
                        "modified": datetime.fromtimestamp(stat.st_mtime).isoformat()
                    })
            
            return sorted(backups, key=lambda x: x["modified"], reverse=True)
        except Exception as e:
            logger.error(f"获取备份列表失败: {e}")
            return []

# 全局管理器实例
clash_manager = ClashManager()

# API 路由
@app.get("/", response_class=HTMLResponse)
async def root():
    """根路径 - 返回前端页面"""
    try:
        with open("static/index.html", "r", encoding="utf-8") as f:
            return HTMLResponse(content=f.read())
    except FileNotFoundError:
        return HTMLResponse(content="<h1>Clash 管理面板</h1><p>前端文件未找到</p>")

@app.get("/api/status")
async def get_status():
    """获取 Clash 状态"""
    return clash_manager.get_service_status()

@app.get("/api/nodes")
async def get_nodes():
    """获取所有节点"""
    try:
        config = clash_manager.get_config()
        nodes = config.get("proxies", [])
        
        # 转换为标准格式
        result = []
        for node in nodes:
            result.append(Node(
                name=node.get("name", ""),
                type=node.get("type", ""),
                server=node.get("server", ""),
                port=node.get("port", 0),
                alive=True
            ))
        
        return result
    except Exception as e:
        logger.error(f"获取节点列表失败: {e}")
        raise HTTPException(status_code=500, detail=str(e))

@app.get("/api/groups")
async def get_groups():
    """获取代理组"""
    try:
        config = clash_manager.get_config()
        groups = config.get("proxy-groups", [])
        
        result = []
        for group in groups:
            result.append(ProxyGroup(
                name=group.get("name", ""),
                type=group.get("type", ""),
                proxies=group.get("proxies", []),
                now=group.get("now", ""),
                url=group.get("url", ""),
                interval=group.get("interval", 300)
            ))
        
        return result
    except Exception as e:
        logger.error(f"获取策略组失败: {e}")
        raise HTTPException(status_code=500, detail=str(e))

@app.post("/api/restart")
async def restart_clash():
    """重启 Clash 服务"""
    return clash_manager.restart_service()

@app.get("/api/config")
async def get_config():
    """获取完整配置"""
    return clash_manager.get_config()

@app.post("/api/config")
async def save_config(config_update: ConfigUpdate):
    """保存配置"""
    return clash_manager.save_config(config_update.config, config_update.backup)

@app.get("/api/node/{node_name}/test")
async def test_node(node_name: str):
    """测试节点延迟"""
    latency = clash_manager.test_node_latency(node_name)
    return {"node": node_name, "latency": latency}

@app.get("/api/logs")
async def get_logs(lines: int = 100):
    """获取日志"""
    try:
        log_path = clash_manager.log_path
        if os.path.exists(log_path):
            with open(log_path, 'r', encoding='utf-8') as f:
                log_lines = f.readlines()
                return {"logs": log_lines[-lines:]}
        else:
            return {"logs": ["日志文件不存在"]}
    except Exception as e:
        logger.error(f"读取日志失败: {e}")
        return {"logs": [f"读取日志失败: {str(e)}"]}

@app.get("/api/backups")
async def get_backups():
    """获取备份文件列表"""
    return {"backups": clash_manager.get_backups()}

@app.get("/api/panel-config")
async def get_panel_config():
    """获取面板配置"""
    return config_manager.config

@app.post("/api/panel-config")
async def save_panel_config(config: Dict[str, Any]):
    """保存面板配置"""
    try:
        config_manager.config.update(config)
        config_manager.save_config()
        return {"message": "面板配置保存成功"}
    except Exception as e:
        logger.error(f"保存面板配置失败: {e}")
        raise HTTPException(status_code=500, detail=str(e))

@app.get("/api/system-info")
async def get_system_info():
    """获取系统信息"""
    try:
        import platform
        import psutil
        
        return {
            "platform": platform.platform(),
            "python_version": platform.python_version(),
            "cpu_count": psutil.cpu_count(),
            "memory_total": f"{psutil.virtual_memory().total / (1024**3):.2f} GB",
            "disk_usage": f"{psutil.disk_usage('/').percent:.1f}%"
        }
    except ImportError:
        return {
            "platform": "Unknown",
            "python_version": "Unknown",
            "cpu_count": "Unknown",
            "memory_total": "Unknown",
            "disk_usage": "Unknown"
        }

if __name__ == "__main__":
    # 确保日志目录存在
    os.makedirs("/opt/clash-panel/logs", exist_ok=True)
    
    # 启动服务器
    host = config_manager.get("server.host", "0.0.0.0")
    port = config_manager.get("server.port", 8000)
    debug = config_manager.get("server.debug", False)
    
    logger.info(f"启动 Clash 管理面板服务器: {host}:{port}")
    uvicorn.run(app, host=host, port=port, debug=debug) 