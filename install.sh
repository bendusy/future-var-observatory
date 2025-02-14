#!/bin/bash

# 显示欢迎信息
echo "欢迎使用未来变量观测局一键部署脚本"
echo "=============================="

# 更新代码函数
update_code() {
    echo "正在更新代码..."
    
    # 检查是否是 git 仓库
    if [ ! -d ".git" ]; then
        echo "错误: 当前目录不是 git 仓库"
        return 1
    }
    
    # 保存当前分支名
    current_branch=$(git symbolic-ref --short HEAD 2>/dev/null)
    if [ $? -ne 0 ]; then
        echo "错误: 无法获取当前分支"
        return 1
    }
    
    # 保存本地修改
    if ! git diff --quiet HEAD; then
        echo "检测到本地修改，正在保存..."
        git stash
        local_changes=1
    fi
    
    # 更新远程分支信息
    echo "更新远程分支信息..."
    if ! git fetch --all; then
        echo "错误: 无法更新远程分支信息"
        return 1
    fi
    
    # 重置到远程分支最新状态
    echo "重置到远程分支最新状态..."
    if ! git reset --hard origin/$current_branch; then
        echo "错误: 无法重置到远程分支"
        return 1
    fi
    
    # 恢复本地修改
    if [ "$local_changes" = "1" ]; then
        echo "恢复本地修改..."
        git stash pop
    fi
    
    # 检查是否有新的依赖需要安装
    echo "检查依赖更新..."
    if [ -f "package.json" ]; then
        if ! npm install; then
            echo "尝试使用淘宝镜像重新安装..."
            npm config set registry https://registry.npmmirror.com
            if ! npm install; then
                echo "依赖安装失败，请检查网络连接"
                return 1
            fi
        fi
    fi
    
    # 重新构建项目
    echo "重新构建项目..."
    if ! npm run build; then
        echo "项目构建失败"
        return 1
    fi
    
    echo "代码更新完成"
    return 0
}

# 显示菜单
show_menu() {
    echo "请选择要执行的操作："
    echo "1) 完整部署（安装依赖+配置环境+构建+启动）"
    echo "2) 更新代码（包含依赖安装和重新构建）"
    echo "3) 更新代码并重启服务"
    echo "4) 退出"
    echo ""
    read -p "请输入选项 [1-4]: " choice
    
    case $choice in
        1)
            # 继续执行完整部署流程
            return 0
            ;;
        2)
            update_code
            exit $?
            ;;
        3)
            if update_code; then
                echo "正在重启服务..."
                pm2 restart fvo
            fi
            exit $?
            ;;
        4)
            echo "退出脚本"
            exit 0
            ;;
        *)
            echo "无效的选项，请重新选择"
            show_menu
            ;;
    esac
}

# 解析命令行参数
while [[ $# -gt 0 ]]; do
    case $1 in
        --update)
            update_code
            exit $?
            ;;
        *)
            shift
            ;;
    esac
done

# 显示菜单
show_menu

# 检查 Dify 服务可用性
check_dify_service() {
    local app_id=$1
    local api_key=$2
    local api_url=$3
    
    echo "正在检查 Dify 服务可用性..."
    
    # 检查API地址是否可访问
    if ! curl -s --head "$api_url" > /dev/null; then
        echo "错误: 无法连接到 Dify 服务 ($api_url)"
        echo "请确保："
        echo "1. Dify 服务已正确部署"
        echo "2. API 地址可以访问"
        echo "3. 如果是自托管，请确保版本 >= 0.3.30"
        return 1
    fi
    
    # 验证 APP_ID 和 API_KEY
    if ! curl -s -X POST "$api_url/chat-messages" \
        -H "Authorization: Bearer $api_key" \
        -H "Content-Type: application/json" \
        -d '{"inputs": {}, "query": "test"}' > /dev/null; then
        echo "错误: APP_ID 或 API_KEY 无效"
        echo "请检查："
        echo "1. APP_ID 和 API_KEY 是否正确"
        echo "2. 应用是否已发布"
        echo "3. 应用类型是否为 AI Assistant"
        return 1
    fi
    
    echo "Dify 服务检查通过"
    return 0
}

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

# 检查 npm 版本并更新
NPM_VERSION=$(npm -v)
if [ "$(echo $NPM_VERSION | cut -d'.' -f1)" -lt 10 ]; then
    echo "正在更新 npm..."
    npm install -g npm@latest
fi

# 安装依赖
echo "正在安装依赖..."
if ! npm install; then
    echo "尝试使用淘宝镜像重新安装..."
    npm config set registry https://registry.npmmirror.com
    if ! npm install; then
        echo "依赖安装失败，请检查网络连接"
        exit 1
    fi
fi

# 处理环境变量
setup_env() {
    local env_file=".env.local"
    
    # 如果环境变量文件已存在，询问是否覆盖
    if [ -f $env_file ]; then
        echo "检测到 $env_file 文件已存在，是否覆盖？[y/N]"
        read -r overwrite_choice
        if [[ ! $overwrite_choice =~ ^[Yy]$ ]]; then
            return 0
        fi
    fi
    
    # 如果命令行参数存在，使用命令行参数
    if [ ! -z "$1" ] && [ ! -z "$2" ] && [ ! -z "$3" ]; then
        echo "使用命令行参数配置环境变量..."
        if ! check_dify_service "$1" "$2" "$3"; then
            exit 1
        fi
        echo "NEXT_PUBLIC_APP_ID=$1" > $env_file
        echo "NEXT_PUBLIC_APP_KEY=$2" >> $env_file
        echo "NEXT_PUBLIC_API_URL=$3" >> $env_file
        return 0
    fi
    
    # 交互式配置
    while true; do
        echo "请输入配置信息："
        read -p "Dify 应用 ID (NEXT_PUBLIC_APP_ID): " app_id
        read -p "Dify API 密钥 (NEXT_PUBLIC_APP_KEY): " app_key
        read -p "Dify API 地址 [默认: https://api.dify.ai/v1]: " api_url
        api_url=${api_url:-https://api.dify.ai/v1}
        
        if check_dify_service "$app_id" "$app_key" "$api_url"; then
            break
        fi
        
        echo "是否重新输入配置？[Y/n]"
        read -r retry_choice
        if [[ ! $retry_choice =~ ^[Yy]$ ]] && [ ! -z "$retry_choice" ]; then
            exit 1
        fi
    done
    
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

# 安装并配置 PM2
echo "正在安装 PM2..."
npm install -g pm2

# 启动服务
echo "正在启动服务..."
pm2 start npm --name "fvo" -- start

echo "=============================="
echo "部署完成！"
echo "服务已在后台启动，访问 http://localhost:33896"
echo ""
echo "服务管理命令："
echo "- 查看状态：pm2 status"
echo "- 查看日志：pm2 logs fvo"
echo "- 重启服务：pm2 restart fvo"
echo "- 停止服务：pm2 stop fvo"
echo "- 开机自启：pm2 startup && pm2 save"
echo ""
echo "下次运行脚本可以选择更新代码或重启服务等操作"
echo "代码更新命令："
echo "- 更新代码：./install.sh --update" 