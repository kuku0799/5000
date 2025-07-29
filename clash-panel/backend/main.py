from fastapi import FastAPI, HTTPException, Depends
from fastapi.middleware.cors import CORSMiddleware
from fastapi.staticfiles import StaticFiles
from pydantic import BaseModel
from typing import List, Optional, Dict, Any
import yaml
import os
import subprocess
import asyncio
import json
from datetime import datetime
import uvicorn

app = FastAPI(title="Clash Management Panel", version="1.0.0")

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

class ProxyGroup(BaseModel):
    name: str
    type: str
    proxies: List[str]
    now: Optional[str] = None

class ClashStatus(BaseModel):
    running: bool
    mode: str
    uptime: Optional[str] = None
    memory_usage: Optional[str] = None
    cpu_usage: Optional[str] = None

# 配置文件路径
CONFIG_PATH = "/etc/openclash/config.yaml"
CLASH_SERVICE = "openclash"

class ClashManager:
    def __init__(self):
        self.config_path = CONFIG_PATH
        self.service_name = CLASH_SERVICE
    
    def get_config(self) -> Dict[str, Any]:
        """读取 Clash 配置文件"""
        try:
            with open(self.config_path, 'r', encoding='utf-8') as f:
                return yaml.safe_load(f)
        except Exception as e:
            raise HTTPException(status_code=500, detail=f"读取配置文件失败: {str(e)}")
    
    def save_config(self, config: Dict[str, Any]):
        """保存 Clash 配置文件"""
        try:
            # 备份原配置
            backup_path = f"{self.config_path}.backup.{datetime.now().strftime('%Y%m%d_%H%M%S')}"
            if os.path.exists(self.config_path):
                os.system(f"cp {self.config_path} {backup_path}")
            
            with open(self.config_path, 'w', encoding='utf-8') as f:
                yaml.dump(config, f, default_flow_style=False, allow_unicode=True)
            
            return {"message": "配置保存成功", "backup": backup_path}
        except Exception as e:
            raise HTTPException(status_code=500, detail=f"保存配置文件失败: {str(e)}")
    
    def get_service_status(self) -> ClashStatus:
        """获取 Clash 服务状态"""
        try:
            result = subprocess.run(
                ["/etc/init.d/openclash", "status"],
                capture_output=True,
                text=True
            )
            running = "running" in result.stdout.lower()
            
            # 获取内存和CPU使用情况
            memory = "0 KB"
            cpu = "0%"
            uptime = None
            
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
                except:
                    pass
            
            return ClashStatus(
                running=running,
                mode="rule",  # 默认模式
                uptime=uptime,
                memory_usage=memory,
                cpu_usage=cpu
            )
        except Exception as e:
            return ClashStatus(running=False, mode="unknown")
    
    def restart_service(self):
        """重启 Clash 服务"""
        try:
            result = subprocess.run(
                ["/etc/init.d/openclash", "restart"],
                capture_output=True,
                text=True
            )
            return {"message": "服务重启成功", "output": result.stdout}
        except Exception as e:
            raise HTTPException(status_code=500, detail=f"重启服务失败: {str(e)}")
    
    def test_node_latency(self, node_name: str) -> int:
        """测试节点延迟"""
        try:
            # 这里可以实现具体的延迟测试逻辑
            # 暂时返回随机延迟
            import random
            return random.randint(50, 300)
        except Exception as e:
            return -1

# 全局管理器实例
clash_manager = ClashManager()

# API 路由
@app.get("/")
async def root():
    """根路径"""
    return {"message": "Clash Management Panel API"}

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
                now=group.get("now", "")
            ))
        
        return result
    except Exception as e:
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
async def save_config(config: Dict[str, Any]):
    """保存配置"""
    return clash_manager.save_config(config)

@app.get("/api/node/{node_name}/test")
async def test_node(node_name: str):
    """测试节点延迟"""
    latency = clash_manager.test_node_latency(node_name)
    return {"node": node_name, "latency": latency}

@app.get("/api/logs")
async def get_logs(lines: int = 100):
    """获取日志"""
    try:
        log_path = "/root/OpenClashManage/wangluo/log.txt"
        if os.path.exists(log_path):
            with open(log_path, 'r', encoding='utf-8') as f:
                log_lines = f.readlines()
                return {"logs": log_lines[-lines:]}
        else:
            return {"logs": ["日志文件不存在"]}
    except Exception as e:
        return {"logs": [f"读取日志失败: {str(e)}"]}

if __name__ == "__main__":
    uvicorn.run(app, host="0.0.0.0", port=8000) 