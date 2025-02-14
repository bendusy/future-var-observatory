#!/bin/bash

# 项目目录（当前工作目录）
PROJECT_DIR="$(pwd)"

# 日志文件路径
LOG_FILE="${PROJECT_DIR}/deploy.log"

# 定义日志记录函数
log_info() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') [INFO] $1" | tee -a "$LOG_FILE"
}
log_error() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') [ERROR] $1" | tee -a "$LOG_FILE" >&2
}

log_info "未来变量观测局一键安装脚本"
log_info "=============================="

cd "${PROJECT_DIR}" || { log_error "无法进入项目目录 ${PROJECT_DIR}"; exit 1; }

log_info "检查依赖..."
if ! command -v npm &> /dev/null; then
    log_error "npm 未安装"
    exit 1
fi
if ! command -v pm2 &> /dev/null; then
    log_info "安装 PM2..."
    npm install -g pm2 | tee -a "$LOG_FILE" || { log_error "PM2 安装失败"; exit 1; }
fi

log_info "安装依赖..."
npm install | tee -a "$LOG_FILE" || { log_error "依赖安装失败"; exit 1; }

log_info "构建项目..."
npm run build | tee -a "$LOG_FILE" || { log_error "项目构建失败"; exit 1; }

log_info "启动服务..."
pm2 start npm --name "fvo" \
    --max-memory-restart 500M \
    --cwd "${PROJECT_DIR}" \
    -- start | tee -a "$LOG_FILE"

pm2 save | tee -a "$LOG_FILE"

log_info "=============================="
log_info "✓ 安装完成"
log_info "服务状态："
pm2 status fvo | tee -a "$LOG_FILE"
log_info ""
log_info "如遇问题，请检查："
log_info "1. 项目目录: ${PROJECT_DIR}"
log_info "2. 服务日志: pm2 logs fvo"
log_info "3. PM2 状态: pm2 status"