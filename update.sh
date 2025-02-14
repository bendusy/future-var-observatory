#!/bin/bash

# 获取项目根目录的绝对路径
PROJECT_DIR="/opt/future-var-observatory"

# 显示欢迎信息
echo "未来变量观测局一键更新脚本"
echo "=============================="

# 确保项目目录存在
mkdir -p "${PROJECT_DIR}"

# 确保在项目目录下
cd "${PROJECT_DIR}" || {
    echo "错误: 无法进入项目目录 ${PROJECT_DIR}"
    exit 1
}

# 如果目录为空，执行完整克隆
if [ ! -d ".git" ] || [ -z "$(ls -A ${PROJECT_DIR})" ]; then
    echo "执行完整克隆..."
    rm -rf "${PROJECT_DIR:?}/"*  # 清空目录
    git clone https://github.com/bendusy/future-var-observatory.git .
    if [ $? -ne 0 ]; then
        echo "错误: 克隆仓库失败"
        exit 1
    fi
else
    # 如果目录不为空，保存本地修改并更新
    echo "更新现有仓库..."
    
    # 重置任何未提交的更改
    git reset --hard HEAD
    
    # 拉取最新代码
    git fetch origin main
    git reset --hard origin/main
    
    if [ $? -ne 0 ]; then
        echo "错误: 更新代码失败"
        exit 1
    fi
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

# 停止所有相关的 PM2 进程
echo "清理旧服务..."
pm2 delete fvo 2>/dev/null || true
pm2 delete webapp-8zi 2>/dev/null || true
pm2 save

# 启动服务
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
    echo "错误: 服务启动失败"
    echo "错误日志："
    pm2 logs fvo --lines 10
    exit 1
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