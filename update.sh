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
    echo "✨ 更新完成！"
    echo ""
    echo "🔍 检查结果："
    echo "1. 环境变量："
    if [ -f ".env.example" ] && [ -f ".env.local" ]; then
        if ! cmp -s ".env.example" ".env.local"; then
            echo "   ⚠️  需要更新"
            echo "   - 请对比 .env.example 和 .env.local 文件"
            echo "   - 手动添加新的配置项到 .env.local"
        else
            echo "   ✓ 无需更新"
        fi
    fi
    
    echo "2. 服务状态："
    if pm2 describe fvo | grep -q "online"; then
        echo "   ✓ PM2 服务正常运行"
    else
        echo "   ⚠️  PM2 服务异常"
        echo "   - 请执行 pm2 logs fvo 查看日志"
    fi
    
    echo ""
    echo "🌐 访问服务："
    PUBLIC_IP=$(curl -s http://ipv4.icanhazip.com || curl -s http://api.ipify.org)
    if [ -n "$PUBLIC_IP" ]; then
        echo "   http://${PUBLIC_IP}:${PORT:-33896}"
    else
        echo "   http://<服务器IP>:${PORT:-33896}"
    fi
    echo ""
    echo "🛠  常用命令："
    echo "   pm2 status     # 查看服务状态"
    echo "   pm2 logs fvo   # 查看服务日志"
    echo "   pm2 restart fvo # 重启服务"
    echo "   pm2 stop fvo   # 停止服务"
    echo ""
    echo "=============================="
else
    echo "更新失败，请检查错误信息"
    exit 1
fi 