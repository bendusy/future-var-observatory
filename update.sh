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

# 清理旧的服务 - 不要因为服务不存在就退出
echo "清理旧服务..."
if pm2 list | grep -q "fvo"; then
    pm2 delete fvo
    pm2 save
else
    echo "提示: 未发现运行中的服务，继续更新..."
fi

# 备份本地修改
echo "备份本地修改..."
if [ -d ".git" ]; then
    git stash push -m "backup_before_update" || {
        echo "警告: 无法备份本地修改，尝试强制更新..."
        git reset --hard HEAD
    }
fi

# 更新代码
echo "拉取最新代码..."
if [ ! -d ".git" ]; then
    echo "初始化 Git 仓库..."
    git init
    git remote add origin https://github.com/bendusy/future-var-observatory.git
fi

git fetch origin main || {
    echo "错误: 无法获取远程代码"
    exit 1
}

git reset --hard origin/main || {
    echo "错误: 无法重置到最新代码"
    exit 1
}

# 如果之前有stash，尝试恢复
if git stash list | grep -q "backup_before_update"; then
    echo "恢复本地修改..."
    git stash pop || {
        echo "警告: 恢复本地修改时发生冲突，继续执行更新..."
    }
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