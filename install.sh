#!/bin/bash

# 显示欢迎信息
echo "欢迎使用未来变量观测局一键部署脚本"
echo "=============================="

# 检查必要的工具
command -v node >/dev/null 2>&1 || { echo "需要安装 Node.js >= 18"; exit 1; }
command -v npm >/dev/null 2>&1 || { echo "需要安装 npm >= 9"; exit 1; }

# 检查 Node.js 版本
NODE_VERSION=$(node -v | cut -d'v' -f2)
if [ "${NODE_VERSION%%.*}" -lt 18 ]; then
    echo "Node.js 版本需要 >= 18，当前版本: $NODE_VERSION"
    exit 1
fi

# 安装依赖
echo "正在安装依赖..."
npm install

# 检查环境变量文件
if [ ! -f .env.local ]; then
    echo "未检测到 .env.local 文件，将从 .env.example 创建..."
    cp .env.example .env.local
    echo "请编辑 .env.local 文件，填入必要的配置信息："
    echo "- NEXT_PUBLIC_APP_ID: Dify 应用 ID"
    echo "- NEXT_PUBLIC_APP_KEY: Dify API 密钥"
    echo "- NEXT_PUBLIC_API_URL: Dify API 地址"
    exit 1
fi

# 构建项目
echo "正在构建项目..."
npm run build

# 启动服务
echo "正在启动服务..."
npm start 