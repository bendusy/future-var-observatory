#!/bin/bash

# 获取项目根目录的绝对路径
PROJECT_DIR="/opt/future-var-observatory"

# 显示欢迎信息
echo "未来变量观测局一键更新脚本"
echo "=============================="

# 确保在项目目录下
cd "${PROJECT_DIR}" || {
    echo "错误: 无法进入项目目录 ${PROJECT_DIR}"
    exit 1
}

# 恢复 .env.local 文件（如果存在备份）
if [ -f ".env.local.backup" ]; then
    echo "恢复环境配置文件..."
    mv .env.local.backup .env.local
    echo "已恢复环境配置文件"
fi

# 检查并安装依赖
echo "检查依赖..."
if ! command -v npm &> /dev/null; then
    echo "错误: npm 未安装"
    exit 1
fi

if ! command -v pm2 &> /dev/null; then
    echo "安装 PM2..."
    npm install -g pm2 || {
        echo "错误: PM2 安装失败"
        exit 1
    }
fi

# 清理并重新安装依赖
echo "清理旧依赖..."
rm -rf node_modules
rm -f package-lock.json

echo "安装依赖..."
npm install || {
    echo "错误: 依赖安装失败"
    exit 1
}

echo "构建项目..."
npm run build || {
    echo "错误: 项目构建失败"
    exit 1
}

# 停止所有 PM2 进程（忽略错误）
echo "清理旧服务..."
pm2 delete all 2>/dev/null || true
pm2 save

# 启动新服务
echo "启动服务..."
pm2 start npm --name "fvo" \
    --max-memory-restart 500M \
    --cwd "${PROJECT_DIR}" \
    -- start

# 等待服务启动
echo "等待服务启动..."
sleep 5

# 验证服务状态
if ! pm2 describe fvo | grep -q "online"; then
    echo "警告: 服务可能未正常启动，查看日志..."
    pm2 logs fvo --lines 10
    echo ""
    echo "尝试重新启动服务..."
    pm2 restart fvo
    sleep 3
fi

# 再次检查服务状态
if pm2 describe fvo | grep -q "online"; then
    echo "服务启动成功！"
else
    echo "警告: 服务可能存在问题，请检查日志"
fi

# 保存 PM2 配置
pm2 save

echo "=============================="
echo "✓ 更新完成"
echo "服务状态："
pm2 status fvo
echo ""
echo "如遇问题，请检查："
echo "1. 项目目录: ${PROJECT_DIR}"
echo "2. 服务日志: pm2 logs fvo"
echo "3. PM2 状态: pm2 status" 