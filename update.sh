#!/bin/bash

# 显示欢迎信息
echo "未来变量观测局一键更新脚本"
echo "=============================="

# 检查是否在正确的目录
if [ ! -f "install.sh" ]; then
    echo "错误: 请在项目根目录下运行此脚本"
    exit 1
fi

# 执行更新
./install.sh --update

# 如果更新成功，重启服务
if [ $? -eq 0 ]; then
    echo "正在重启服务..."
    # 使用新的 PM2 处理函数
    if source ./install.sh > /dev/null 2>&1; then
        handle_pm2_service "restart"
        handle_pm2_service "save"
        echo "更新完成！"
    else
        echo "更新失败：无法加载 PM2 处理函数"
        exit 1
    fi
else
    echo "更新失败，请检查错误信息"
    exit 1
fi 