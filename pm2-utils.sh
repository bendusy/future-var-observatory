#!/bin/bash

# PM2 服务管理函数
handle_pm2_service() {
    local action=$1
    local service_name=${PM2_APP_NAME:-fvo}
    
    case $action in
        "clean")
            echo "正在清理旧的 PM2 进程..."
            # 删除旧的 webapp 进程
            if pm2 list | grep -q "webapp"; then
                pm2 delete webapp-8zi >/dev/null 2>&1
            fi
            ;;
        "start")
            # 检查服务是否已存在
            if pm2 list | grep -q "$service_name"; then
                echo "服务已存在，正在重启..."
                pm2 restart "$service_name"
            else
                echo "正在启动服务..."
                # 先清理旧进程
                handle_pm2_service "clean"
                pm2 start npm --name "$service_name" \
                    ${PM2_EXEC_MODE:+--exec-mode $PM2_EXEC_MODE} \
                    ${PM2_INSTANCES:+--instances $PM2_INSTANCES} \
                    ${PM2_WATCH:+--watch} \
                    ${PM2_MAX_MEMORY_RESTART:+--max-memory-restart $PM2_MAX_MEMORY_RESTART} \
                    ${PM2_CWD:+--cwd $PM2_CWD} \
                    -- start
            fi
            ;;
        "restart")
            echo "正在重启服务..."
            if ! pm2 describe "$service_name" > /dev/null; then
                echo "服务不存在，将重新启动..."
                handle_pm2_service "start"
            else
                if [ "${PM2_UPDATE_STRATEGY}" = "reload" ]; then
                    pm2 reload "$service_name"
                else
                    pm2 restart "$service_name"
                fi
            fi
            ;;
        "save")
            echo "正在保存 PM2 进程列表..."
            pm2 save
            
            # 如果启用了开机自启
            if [ "${PM2_STARTUP_ENABLED}" = "true" ]; then
                echo "正在设置开机自启..."
                pm2 startup
            fi
            ;;
    esac
    
    # 检查服务状态
    if ! pm2 describe "$service_name" > /dev/null; then
        echo "错误: 服务启动失败"
        return 1
    fi
    
    return 0
} 