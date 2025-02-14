#!/bin/bash

# 显示欢迎信息
echo "未来变量观测局一键更新脚本"
echo "=============================="

# 检查是否在正确的目录
if [ ! -f "install.sh" ]; then
    echo "错误: 请在项目根目录下运行此脚本"
    exit 1
fi

# 检查 PM2 服务
if ! pm2 describe fvo > /dev/null; then
    echo "错误: PM2 服务不存在，请先运行安装脚本"
    exit 1
fi

# 清理旧的 PM2 进程
if pm2 list | grep -q "webapp-8zi"; then
    echo "正在清理旧进程..."
    pm2 delete webapp-8zi
    pm2 save
fi

# 执行更新
./install.sh --update

# 如果更新成功，重启服务
if [ $? -eq 0 ]; then
    echo "正在重启服务..."
    pm2 restart fvo
    if [ "${PM2_STARTUP_ENABLED}" = "true" ]; then
        pm2 save
    fi
    
    # 检查是否需要更新环境变量
    if [ -f ".env.example" ] && [ -f ".env.local" ]; then
        echo "检查环境变量更新..."
        if ! cmp -s ".env.example" ".env.local"; then
            echo "发现新的环境变量配置，建议手动对比 .env.example 和 .env.local"
            echo "如需自动更新环境变量，请使用: ./install.sh --update-env"
        fi
    fi
    
    echo "=============================="
    echo "更新完成！"
    # 获取公网 IP
    PUBLIC_IP=$(curl -s http://ipv4.icanhazip.com || curl -s http://api.ipify.org)
    if [ -n "$PUBLIC_IP" ]; then
        echo "服务已在后台重启，访问 http://${PUBLIC_IP}:${PORT:-33896}"
    else
        echo "服务已在后台重启，访问 http://<服务器IP>:${PORT:-33896}"
    fi
    echo ""
    echo "更新后检查步骤："
    echo "1. 环境变量检查："
    if [ -f ".env.example" ] && [ -f ".env.local" ]; then
        if ! cmp -s ".env.example" ".env.local"; then
            echo "   - [需要关注] 发现环境变量有更新"
            echo "   - 请对比 .env.example 和 .env.local 文件"
            echo "   - 手动添加新的配置项到 .env.local"
        else
            echo "   - [已确认] 环境变量无需更新"
        fi
    fi
    echo "2. 服务状态检查："
    if pm2 describe fvo | grep -q "online"; then
        echo "   - [正常] PM2 服务运行中"
    else
        echo "   - [异常] PM2 服务可能未正常运行"
        echo "   - 请检查日志: pm2 logs fvo"
    fi
    echo "3. 后续操作："
    echo "   - 访问上述地址确认服务是否正常"
    echo "   - 如有异常请查看日志: pm2 logs fvo"
    echo "   - 需要时可重启服务: pm2 restart fvo"
    echo ""
    echo "服务管理命令："
    echo "- 查看状态：pm2 status"
    echo "- 查看日志：pm2 logs fvo"
    echo "- 重启服务：pm2 restart fvo"
    echo "- 停止服务：pm2 stop fvo"
else
    echo "更新失败，请检查错误信息"
    exit 1
fi 