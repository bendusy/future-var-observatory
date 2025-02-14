#!/bin/bash

echo "未来变量观测局一键部署脚本"
echo "=============================="

# 检查必要的命令
check_command() {
    if ! command -v $1 &> /dev/null; then
        echo "错误: 未找到命令 $1"
        echo "请先安装 $1"
        exit 1
    fi
}

# 显示帮助信息
show_help() {
    echo "用法: $0 [选项] [安装目录]"
    echo ""
    echo "选项:"
    echo "  --help     显示帮助信息"
    echo "  --update   更新已安装的项目"
    echo ""
    echo "示例:"
    echo "  $0                    # 在当前目录下的 future-var-observatory 中安装"
    echo "  $0 /opt/fvo          # 在指定目录中安装"
    echo "  $0 --update           # 更新当前目录下的安装"
    echo "  $0 --update /opt/fvo  # 更新指定目录中的安装"
}

# 解析命令行参数
INSTALL_DIR="future-var-observatory"
UPDATE_MODE=false

while [[ $# -gt 0 ]]; do
    case $1 in
        --help)
            show_help
            exit 0
            ;;
        --update)
            UPDATE_MODE=true
            shift
            ;;
        *)
            if [ -z "$2" ] && [[ ! $1 =~ ^- ]]; then
                INSTALL_DIR="$1"
            fi
            shift
            ;;
    esac
done

# 检查必要命令
check_command git
check_command node
check_command npm

# 创建并进入目标目录
if [ ! -d "$INSTALL_DIR" ]; then
    if [ "$UPDATE_MODE" = true ]; then
        echo "错误: 目录 $INSTALL_DIR 不存在，无法更新"
        exit 1
    fi
    echo "创建目录: $INSTALL_DIR"
    mkdir -p "$INSTALL_DIR"
fi

cd "$INSTALL_DIR" || exit 1

# 检查是否是有效的项目目录
if [ ! -d ".git" ] && [ "$UPDATE_MODE" = true ]; then
    echo "错误: $INSTALL_DIR 不是有效的项目目录"
    exit 1
fi

# 克隆或更新代码
if [ ! -d ".git" ]; then
    echo "正在克隆项目..."
    git clone https://github.com/bendusy/future-var-observatory.git .
else
    if [ "$UPDATE_MODE" = true ]; then
        echo "正在更新代码..."
        # 备份 .env.local
        if [ -f ".env.local" ]; then
            echo "备份环境配置..."
            cp .env.local .env.local.backup
        fi
        
        # 强制重置并更新
        echo "重置本地修改..."
        git reset --hard HEAD
        git clean -fd -e .env.local -e .env.local.backup
        
        echo "拉取最新代码..."
        git fetch origin main
        git reset --hard origin/main
        
        # 恢复 .env.local
        if [ -f ".env.local.backup" ]; then
            echo "恢复环境配置..."
            mv .env.local.backup .env.local
        fi
    else
        echo "目录已存在且包含项目文件"
    fi
fi

# 确保脚本可执行
chmod +x install.sh update.sh

# 根据模式执行相应操作
if [ "$UPDATE_MODE" = true ]; then
    echo "正在执行更新..."
    ./update.sh
else
    echo "正在执行安装..."
    ./install.sh
fi

exit $? 