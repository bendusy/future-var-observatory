#!/bin/bash

# 项目目录
PROJECT_DIR="/opt/future-var-observatory"

# 日志文件路径
LOG_FILE="${PROJECT_DIR}/deploy.log"

# 定义日志记录函数
log_info() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') [INFO] $1" | tee -a "$LOG_FILE"
}

log_error() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') [ERROR] $1" | tee -a "$LOG_FILE" >&2
}

# 显示欢迎信息
log_info "未来变量观测局一键更新脚本"
log_info "=============================="

# 确保在项目目录下
cd "${PROJECT_DIR}" || { log_error "无法进入项目目录 ${PROJECT_DIR}"; exit 1; }

# 恢复 .env.local 文件（如果存在备份）
if [ -f ".env.local.backup" ]; then
    log_info "恢复环境配置文件..."
    mv .env.local.backup .env.local || { log_error "恢复 .env.local 失败"; exit 1; }
    log_info "已恢复环境配置文件"
fi

# 检查并安装依赖
log_info "检查依赖..."
if ! command -v npm &> /dev/null; then
    log_error "npm 未安装"
    exit 1
fi

if ! command -v pm2 &> /dev/null; then
    log_info "安装 PM2..."
    npm install -g pm2 | tee -a "$LOG_FILE" || { log_error "PM2 安装失败"; exit 1; }
fi

# 清理并重新安装依赖
log_info "清理旧依赖..."
rm -rf node_modules
rm -f package-lock.json

log_info "安装依赖..."
npm install | tee -a "$LOG_FILE" || { log_error "依赖安装失败"; exit 1; }

log_info "构建项目..."
npm run build | tee -a "$LOG_FILE" || { log_error "项目构建失败"; exit 1; }

# 停止所有 PM2 进程（忽略错误）
log_info "清理旧服务..."
pm2 delete all 2>/dev/null || log_info "没有需要删除的 PM2 进程"
pm2 save | tee -a "$LOG_FILE"

# 启动新服务
log_info "启动服务..."
pm2 start npm --name "fvo" \
    --max-memory-restart 500M \
    --cwd "${PROJECT_DIR}" \
    -- start | tee -a "$LOG_FILE"

# 等待服务启动
log_info "等待服务启动..."
sleep 5

# 验证服务状态
if ! pm2 describe fvo | grep -q "online"; then
    log_error "服务可能未正常启动，查看日志..."
    pm2 logs fvo --lines 10 | tee -a "$LOG_FILE"
    log_info "尝试重新启动服务..."
    pm2 restart fvo | tee -a "$LOG_FILE"
    sleep 3
fi

# 再次检查服务状态
if pm2 describe fvo | grep -q "online"; then
    log_info "服务启动成功！"
else
    log_error "服务可能存在问题，请检查日志"
fi

# 保存 PM2 配置
pm2 save | tee -a "$LOG_FILE"

log_info "=============================="
log_info "✓ 更新完成"
log_info "服务状态："
pm2 status fvo | tee -a "$LOG_FILE"
log_info ""
log_info "如遇问题，请检查："
log_info "1. 项目目录: ${PROJECT_DIR}"
log_info "2. 服务日志: pm2 logs fvo"
log_info "3. PM2 状态: pm2 status" 