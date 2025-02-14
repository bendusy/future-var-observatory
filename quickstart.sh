#!/bin/bash

# 默认设定
INSTALL_DIR="future-var-observatory"
UPDATE_MODE=false

# 解析命令行参数
while [[ $# -gt 0 ]]; do
    case $1 in
        --help)
            echo "用法: $0 [选项] [安装目录]"
            echo ""
            echo "选项:"
            echo "  --help     显示帮助信息"
            echo "  --update   更新已安装的项目"
            echo ""
            echo "示例:"
            echo "  $0                    # 在当前目录下的 future-var-observatory 中安装"
            echo "  $0 /opt/fvo           # 在指定目录中安装"
            echo "  $0 --update           # 更新当前目录下的安装"
            echo "  $0 --update /opt/fvo  # 更新指定目录中的安装"
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

# 若 INSTALL_DIR 不是绝对路径，则转换为绝对路径
if [[ "$INSTALL_DIR" =~ ^/ ]]; then
    :  # 已是绝对路径
else
    INSTALL_DIR="$(pwd)/$INSTALL_DIR"
fi

# 日志文件路径
LOG_FILE="${INSTALL_DIR}/deploy.log"

# 根据模式确保安装目录：更新模式下目录必须存在；安装模式下自动创建目录
if [ "$UPDATE_MODE" = true ]; then
    if [ ! -d "$INSTALL_DIR" ]; then
        echo "目录 $INSTALL_DIR 不存在，无法更新" >&2
        exit 1
    fi
else
    mkdir -p "$INSTALL_DIR" || { echo "无法创建目录 $INSTALL_DIR" >&2; exit 1; }
fi

# 定义日志记录函数
log_info() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') [INFO] $1" | tee -a "$LOG_FILE"
}
log_error() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') [ERROR] $1" | tee -a "$LOG_FILE" >&2
}

log_info "未来变量观测局一键部署脚本"
log_info "=============================="

# 检查必要的命令
check_command() {
    if ! command -v $1 &> /dev/null; then
        log_error "未找到命令 $1，请先安装 $1"
        exit 1
    fi
}

# 检查必要命令
check_command git
check_command node
check_command npm

# 备份 .env.local 文件（如果存在且处于更新模式）
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