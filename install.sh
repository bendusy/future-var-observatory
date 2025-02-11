#!/bin/bash

# 显示欢迎信息
echo "欢迎使用未来变量观测局一键部署脚本"
echo "=============================="

# 检查并安装 Node.js
install_nodejs() {
    echo "正在安装 Node.js 22.x ..."
    if [ -f /etc/debian_version ]; then
        # Debian/Ubuntu
        curl -fsSL https://deb.nodesource.com/setup_22.x | sudo -E bash -
        sudo apt-get install -y nodejs
    elif [ -f /etc/redhat-release ]; then
        # CentOS/RHEL
        curl -fsSL https://rpm.nodesource.com/setup_22.x | sudo bash -
        sudo yum install -y nodejs
    else
        echo "不支持的系统版本，请手动安装 Node.js >= 22"
        echo "访问 https://nodejs.org/en/download/ 下载安装"
        exit 1
    fi
}

# 检查 Node.js
if ! command -v node >/dev/null 2>&1; then
    echo "未检测到 Node.js，是否安装？[y/N]"
    read -r install_choice
    if [[ $install_choice =~ ^[Yy]$ ]]; then
        install_nodejs
    else
        echo "请手动安装 Node.js >= 22"
        exit 1
    fi
fi

# 检查 Node.js 版本
NODE_VERSION=$(node -v | cut -d'v' -f2)
if [ "${NODE_VERSION%%.*}" -lt 22 ]; then
    echo "Node.js 版本需要 >= 22，当前版本: $NODE_VERSION"
    echo "是否更新 Node.js？[y/N]"
    read -r update_choice
    if [[ $update_choice =~ ^[Yy]$ ]]; then
        install_nodejs
    else
        exit 1
    fi
fi

# 检查 npm 版本
NPM_VERSION=$(npm -v)
if [ "$(echo $NPM_VERSION | cut -d'.' -f1)" -lt 10 ]; then
    echo "npm 版本需要 >= 10，当前版本: $NPM_VERSION"
    echo "正在更新 npm..."
    npm install -g npm@latest
fi

# 安装依赖
echo "正在安装依赖..."
npm install

# 处理环境变量
setup_env() {
    local env_file=".env.local"
    
    # 如果命令行参数存在，使用命令行参数
    if [ ! -z "$1" ] && [ ! -z "$2" ] && [ ! -z "$3" ]; then
        echo "使用命令行参数配置环境变量..."
        echo "NEXT_PUBLIC_APP_ID=$1" > $env_file
        echo "NEXT_PUBLIC_APP_KEY=$2" > $env_file
        echo "NEXT_PUBLIC_API_URL=$3" >> $env_file
        return 0
    fi
    
    # 如果环境变量文件不存在，创建并提示输入
    if [ ! -f $env_file ]; then
        echo "未检测到环境变量配置，请输入以下信息："
        
        echo -n "请输入 Dify 应用 ID (NEXT_PUBLIC_APP_ID): "
        read -r app_id
        
        echo -n "请输入 Dify API 密钥 (NEXT_PUBLIC_APP_KEY): "
        read -r app_key
        
        echo -n "请输入 Dify API 地址 [默认: https://api.dify.ai/v1]: "
        read -r api_url
        api_url=${api_url:-https://api.dify.ai/v1}
        
        echo "NEXT_PUBLIC_APP_ID=$app_id" > $env_file
        echo "NEXT_PUBLIC_APP_KEY=$app_key" >> $env_file
        echo "NEXT_PUBLIC_API_URL=$api_url" >> $env_file
        
        echo "环境变量已保存到 $env_file"
    fi
}

# 设置环境变量
setup_env "$1" "$2" "$3"

# 构建项目
echo "正在构建项目..."
npm run build

# 启动服务
echo "正在启动服务..."
npm start 