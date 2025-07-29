const { createApp } = Vue;

createApp({
    data() {
        return {
            activeTab: 'dashboard',
            status: {
                running: false,
                mode: 'unknown',
                memory_usage: '0 KB',
                cpu_usage: '0%'
            },
            nodes: [],
            groups: [],
            logs: [],
            configText: '',
            loading: false
        }
    },
    
    computed: {
        onlineNodes() {
            return this.nodes.filter(node => node.alive);
        }
    },
    
    mounted() {
        this.loadData();
        // 每30秒自动刷新数据
        setInterval(() => {
            this.loadData();
        }, 30000);
    },
    
    methods: {
        async loadData() {
            try {
                await Promise.all([
                    this.loadStatus(),
                    this.loadNodes(),
                    this.loadGroups(),
                    this.loadLogs()
                ]);
            } catch (error) {
                console.error('加载数据失败:', error);
                this.showError('加载数据失败');
            }
        },
        
        async loadStatus() {
            try {
                const response = await axios.get('/api/status');
                this.status = response.data;
            } catch (error) {
                console.error('加载状态失败:', error);
            }
        },
        
        async loadNodes() {
            try {
                const response = await axios.get('/api/nodes');
                this.nodes = response.data;
            } catch (error) {
                console.error('加载节点失败:', error);
            }
        },
        
        async loadGroups() {
            try {
                const response = await axios.get('/api/groups');
                this.groups = response.data;
            } catch (error) {
                console.error('加载策略组失败:', error);
            }
        },
        
        async loadLogs() {
            try {
                const response = await axios.get('/api/logs');
                this.logs = response.data.logs;
            } catch (error) {
                console.error('加载日志失败:', error);
            }
        },
        
        async loadConfig() {
            try {
                const response = await axios.get('/api/config');
                this.configText = JSON.stringify(response.data, null, 2);
            } catch (error) {
                console.error('加载配置失败:', error);
                this.showError('加载配置失败');
            }
        },
        
        async saveConfig() {
            try {
                this.loading = true;
                const config = JSON.parse(this.configText);
                const response = await axios.post('/api/config', config);
                this.showSuccess('配置保存成功');
            } catch (error) {
                console.error('保存配置失败:', error);
                this.showError('保存配置失败: ' + error.message);
            } finally {
                this.loading = false;
            }
        },
        
        async restartService() {
            try {
                this.loading = true;
                const response = await axios.post('/api/restart');
                this.showSuccess('服务重启成功');
                // 等待服务重启后刷新状态
                setTimeout(() => {
                    this.loadStatus();
                }, 5000);
            } catch (error) {
                console.error('重启服务失败:', error);
                this.showError('重启服务失败');
            } finally {
                this.loading = false;
            }
        },
        
        async testNode(nodeName) {
            try {
                const response = await axios.get(`/api/node/${encodeURIComponent(nodeName)}/test`);
                const latency = response.data.latency;
                
                // 更新节点的延迟信息
                const node = this.nodes.find(n => n.name === nodeName);
                if (node) {
                    node.latency = latency;
                }
                
                this.showSuccess(`节点 ${nodeName} 测试完成: ${latency}ms`);
            } catch (error) {
                console.error('测试节点失败:', error);
                this.showError('测试节点失败');
            }
        },
        
        async testAllNodes() {
            try {
                this.loading = true;
                const promises = this.nodes.map(node => 
                    axios.get(`/api/node/${encodeURIComponent(node.name)}/test`)
                );
                
                const results = await Promise.all(promises);
                
                // 更新所有节点的延迟信息
                results.forEach((result, index) => {
                    this.nodes[index].latency = result.data.latency;
                });
                
                this.showSuccess('所有节点测试完成');
            } catch (error) {
                console.error('测试所有节点失败:', error);
                this.showError('测试所有节点失败');
            } finally {
                this.loading = false;
            }
        },
        
        refreshStatus() {
            this.loadStatus();
        },
        
        refreshNodes() {
            this.loadNodes();
        },
        
        refreshLogs() {
            this.loadLogs();
        },
        
        getLatencyClass(latency) {
            if (latency < 100) return 'latency-good';
            if (latency < 300) return 'latency-medium';
            return 'latency-bad';
        },
        
        showSuccess(message) {
            // 简单的成功提示
            alert('✅ ' + message);
        },
        
        showError(message) {
            // 简单的错误提示
            alert('❌ ' + message);
        }
    }
}).mount('#app'); 