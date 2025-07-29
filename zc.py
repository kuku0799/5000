# zc.py
import os
import re
from datetime import datetime

def should_inject_group(group_name: str, group_config: dict) -> bool:
    """判断是否应该向该策略组注入节点"""
    # 排除系统组
    system_groups = {"REJECT", "DIRECT", "GLOBAL", "PROXY", "FINAL", "COMPLETE"}
    if group_name in system_groups:
        return False
    
    # 只处理 select 类型的组
    if group_config.get("type") != "select":
        return False
    
    # 排除一些常见的特殊组
    exclude_patterns = ["^url-test", "^fallback", "^load-balance"]
    for pattern in exclude_patterns:
        if re.match(pattern, group_name):
            return False
    
    return True

def get_target_groups(config) -> list:
    """获取需要注入节点的目标策略组"""
    proxy_groups = config.get("proxy-groups", [])
    target_groups = []
    
    for group in proxy_groups:
        if should_inject_group(group["name"], group):
            target_groups.append(group["name"])
    
    return target_groups

def inject_groups(config, node_names: list) -> tuple:
    # 自动获取目标策略组
    target_groups = get_target_groups(config)

    # 日志路径
    log_path = os.getenv("ZC_LOG_PATH", "/root/OpenClashManage/wangluo/log.txt")
    def write_log(msg):
        timestamp = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
        with open(log_path, "a", encoding="utf-8") as f:
            f.write(f"[{timestamp}] {msg}\n")

    def is_valid_name(name: str) -> bool:
        return bool(re.match(r'^[\w\-\.]+$', name))

    # ✅ 节点名称合法性校验
    valid_names = []
    skipped = 0
    for name in node_names:
        name = name.strip()
        if is_valid_name(name):
            valid_names.append(name)
        else:
            skipped += 1
            write_log(f"⚠️ [zc] 非法节点名已跳过：{name}")

    proxy_groups = config.get("proxy-groups", [])
    group_map = {g["name"]: g for g in proxy_groups}

    injected_total = 0
    injected_groups = 0
    skipped_groups = 0

    write_log(f"🔍 [zc] 发现 {len(target_groups)} 个可注入的策略组")

    for group_name in target_groups:
        group = group_map.get(group_name)
        if not group:
            write_log(f"⚠️ [zc] 策略组 [{group_name}] 不存在，跳过注入")
            skipped_groups += 1
            continue

        original = group.get("proxies", [])
        reserved = [p for p in original if p not in ("REJECT", "DIRECT") and p not in valid_names]
        updated = ["REJECT", "DIRECT"] + valid_names + reserved

        added = len([n for n in valid_names if n not in original])
        group["proxies"] = updated

        injected_total += added
        injected_groups += 1
        write_log(f"✅ [zc] 策略组 [{group_name}] 注入 {added} 个新节点")

    config["proxy-groups"] = proxy_groups
    write_log(f"🎯 [zc] 成功注入 {injected_groups} 个策略组，总计 {injected_total} 个节点，跳过非法节点 {skipped} 个，跳过策略组 {skipped_groups} 个\n")
    return config, injected_total
