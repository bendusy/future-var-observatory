#!/bin/bash

# 获取项目根目录的绝对路径
PROJECT_DIR="/opt/future-var-observatory"

# 显示欢迎信息
echo "未来变量观测局一键安装脚本"
echo "=============================="

# 确保在项目目录下
cd "${PROJECT_DIR}" || {
    echo "错误: 无法进入项目目录 ${PROJECT_DIR}"
    exit 1
}

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

# 安装依赖
echo "安装依赖..."
npm install || {
    echo "错误: 依赖安装失败"
    exit 1
}

# 构建项目
echo "构建项目..."
npm run build || {
    echo "错误: 项目构建失败"
    exit 1
}

# 启动服务
echo "启动服务..."
pm2 start npm --name "fvo" \
    --max-memory-restart 500M \
    --cwd "${PROJECT_DIR}" \
    -- start

# 保存 PM2 配置
pm2 save

echo "=============================="
echo "✓ 安装完成"
echo "服务状态："
pm2 status fvo
echo ""
echo "如遇问题，请检查："
echo "1. 项目目录: ${PROJECT_DIR}"
echo "2. 服务日志: pm2 logs fvo"
echo "3. PM2 状态: pm2 status" 