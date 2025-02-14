#!/bin/bash

# 项目目录，优先取命令行参数；若参数为 --update 或 --help，则默认使用 future-var-observatory
INSTALL_DIR="$1"
if [[ "$INSTALL_DIR" == --update || "$INSTALL_DIR" == --help ]]; then
    INSTALL_DIR="future-var-observatory"
else
    if [[ "$INSTALL_DIR" =~ ^/ ]]; then
        :
    else
        INSTALL_DIR="$(pwd)/$INSTALL_DIR"
    fi
fi

# 日志文件路径
LOG_FILE="${INSTALL_DIR}/deploy.log"

# 定义日志记录函数
log_info() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') [INFO] $1" | tee -a "$LOG_FILE"
}

log_error() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') [ERROR] $1" | tee -a "$LOG_FILE" >&2
}

echo "未来变量观测局一键部署脚本" | tee -a "$LOG_FILE"
echo "==============================" | tee -a "$LOG_FILE"

# 检查必要的命令
check_command() {
    if ! command -v $1 &> /dev/null; then
        log_error "未找到命令 $1，请先安装 $1"
        exit 1
    fi
}

# 显示帮助信息
show_help() {
    echo "用法: $0 [选项] [安装目录]" | tee -a "$LOG_FILE"
    echo "" | tee -a "$LOG_FILE"
    echo "选项:" | tee -a "$LOG_FILE"
    echo "  --help     显示帮助信息" | tee -a "$LOG_FILE"
    echo "  --update   更新已安装的项目" | tee -a "$LOG_FILE"
    echo "" | tee -a "$LOG_FILE"
    echo "示例:" | tee -a "$LOG_FILE"
    echo "  $0                    # 在当前目录下的 future-var-observatory 中安装" | tee -a "$LOG_FILE"
    echo "  $0 /opt/fvo           # 在指定目录中安装" | tee -a "$LOG_FILE"
    echo "  $0 --update           # 更新当前目录下的安装" | tee -a "$LOG_FILE"
    echo "  $0 --update /opt/fvo  # 更新指定目录中的安装" | tee -a "$LOG_FILE"
}

# 解析命令行参数
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
            if [[ ! $1 =~ ^- ]]; then
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
        log_error "目录 $INSTALL_DIR 不存在，无法更新"
        exit 1
    fi
    log_info "创建目录: $INSTALL_DIR"
    mkdir -p "$INSTALL_DIR" || { log_error "无法创建目录 $INSTALL_DIR"; exit 1; }
fi

cd "$INSTALL_DIR" || { log_error "无法进入目录 $INSTALL_DIR"; exit 1; }

# 备份 .env.local 文件（如果存在）
if [ "$UPDATE_MODE" = true ] && [ -f ".env.local" ]; then
    log_info "备份环境配置文件..."
    cp .env.local .env.local.backup || { log_error "备份 .env.local 失败"; exit 1; }
fi

# 克隆或更新代码
if [ ! -d ".git" ]; then
    log_info "正在克隆项目..."
    git clone https://github.com/bendusy/future-var-observatory.git . | tee -a "$LOG_FILE" || {
        log_error "克隆仓库失败"
        exit 1
    }
else
    if [ "$UPDATE_MODE" = true ]; then
        log_info "正在更新代码..."
        
        # 强制重置并清理，但保留 .env.local
        log_info "重置本地修改..."
        git reset --hard HEAD | tee -a "$LOG_FILE"
        git clean -fd -e .env.local -e .env.local.backup | tee -a "$LOG_FILE"
        
        log_info "拉取最新代码..."
        git fetch origin main | tee -a "$LOG_FILE"
        git reset --hard origin/main | tee -a "$LOG_FILE"
        
        # 恢复 .env.local 文件
        if [ -f ".env.local.backup" ]; then
            log_info "恢复环境配置文件..."
            mv .env.local.backup .env.local | tee -a "$LOG_FILE" || { log_error "恢复 .env.local 失败"; exit 1; }
            log_info "已恢复环境配置文件"
        fi
    else
        log_info "目录已存在且包含项目文件"
    fi
fi

# 确保脚本可执行
chmod +x install.sh update.sh || { log_error "设置脚本执行权限失败"; exit 1; }

# 根据模式执行相应操作
if [ "$UPDATE_MODE" = true ]; then
    log_info "正在执行更新..."
    ./update.sh | tee -a "$LOG_FILE"
else
    log_info "正在执行安装..."
    ./install.sh | tee -a "$LOG_FILE"
fi

exit $? 