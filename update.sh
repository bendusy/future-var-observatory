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

# 执行更新
./install.sh --update

# 如果更新成功，重启服务
if [ $? -eq 0 ]; then
    echo "正在重启服务..."
    pm2 restart fvo
    if [ "${PM2_STARTUP_ENABLED}" = "true" ]; then
        pm2 save
    fi
    
    echo "=============================="
    echo "更新完成！"
    echo "服务已在后台重启，访问 http://localhost:${PORT:-33896}"
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