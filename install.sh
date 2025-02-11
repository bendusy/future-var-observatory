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

# 检查并安装 pm2
install_pm2() {
    if ! command -v pm2 >/dev/null 2>&1; then
        echo "正在安装 pm2..."
        npm install -g pm2
    else
        echo "检测到 pm2 已安装"
    fi
}

# 安装依赖
echo "正在安装依赖..."
npm install

# 安装 pm2
install_pm2

# 处理环境变量
function setup_env() {
    local env_file=".env.local"
    
    # 如果环境变量文件已存在,直接返回
    if [ -f $env_file ]; then
        echo "检测到 $env_file 文件已存在,跳过配置..."
        return 0
    fi
    
    # 如果命令行参数存在，使用命令行参数
    if [ ! -z "$1" ] && [ ! -z "$2" ] && [ ! -z "$3" ]; then
        echo "使用命令行参数配置环境变量..."
        echo "NEXT_PUBLIC_APP_ID=$1" > $env_file
        echo "NEXT_PUBLIC_APP_KEY=$2" >> $env_file
        echo "NEXT_PUBLIC_API_URL=$3" >> $env_file
        return 0
    fi
    
    # 如果环境变量文件不存在，创建并提示输入
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
}

# 设置环境变量
setup_env "$1" "$2" "$3"

# 构建项目
echo "正在构建项目..."
npm run build

# 使用 pm2 启动服务
echo "正在启动服务..."
# 停止已存在的实例
pm2 stop webapp-8zi 2>/dev/null || true
pm2 delete webapp-8zi 2>/dev/null || true

# 启动新实例
pm2 start npm --name "webapp-8zi" -- start

# 保存 pm2 配置
pm2 save

# 设置开机自启
echo "是否设置开机自启？[y/N]"
read -r autostart_choice
if [[ $autostart_choice =~ ^[Yy]$ ]]; then
    pm2 startup
    echo "已设置开机自启"
fi

echo "=============================="
echo "部署完成！"
echo "服务已在后台启动，访问 http://localhost:33896"
echo ""
echo "常用命令："
echo "- 查看运行状态：pm2 status"
echo "- 查看应用日志：pm2 logs webapp-8zi"
echo "- 重启应用：pm2 restart webapp-8zi"
echo "- 停止应用：pm2 stop webapp-8zi"
echo "- 删除应用：pm2 delete webapp-8zi" 