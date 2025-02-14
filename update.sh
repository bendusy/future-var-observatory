#!/bin/bash

# 显示欢迎信息
echo "未来变量观测局一键更新脚本"
echo "=============================="

# 检查是否在正确的目录
if [ ! -f "install.sh" ]; then
    echo "错误: 请在项目根目录下运行此脚本"
    exit 1
fi

# 检查 PM2 服务
if ! pm2 describe fvo > /dev/null; then
    echo "错误: PM2 服务不存在，请先运行安装脚本"
    exit 1
fi

# 检查必要的环境变量
if [ ! -f ".env.local" ]; then
    echo "错误: 未找到 .env.local 文件"
    echo "请先运行完整安装脚本配置环境变量"
    exit 1
fi

# 检查关键环境变量
for var in "NEXT_PUBLIC_APP_ID" "NEXT_PUBLIC_APP_KEY" "NEXT_PUBLIC_API_URL"; do
    if ! grep -q "^$var=" .env.local; then
        echo "错误: $var 未在 .env.local 中配置"
        exit 1
    fi
done

# 测试 Dify API 连接
if [ -f ".env.local" ]; then
    echo "测试 Dify API 连接..."
    API_URL=$(grep "NEXT_PUBLIC_API_URL" .env.local | cut -d '=' -f2)
    API_KEY=$(grep "NEXT_PUBLIC_APP_KEY" .env.local | cut -d '=' -f2)
    if ! curl -s --head "$API_URL" > /dev/null; then
        echo "⚠️  警告: 无法连接到 Dify API"
        echo "请检查 API 地址是否正确: $API_URL"
    fi
fi

# 清理旧的 PM2 进程
if pm2 list | grep -q "webapp-8zi"; then
    echo "正在清理旧进程..."
    pm2 delete webapp-8zi
    pm2 save
fi

# 执行更新
./install.sh --update

# 如果更新成功，重启服务
if [ $? -eq 0 ]; then
    echo "正在重启服务..."
    # 检查服务状态
    if pm2 describe fvo | grep -q "errored"; then
        echo "检测到服务异常，尝试重新启动..."
        pm2 delete fvo
        pm2 start npm --name "fvo" \
            --cwd /opt/future-var-observatory \
            -- start
    else
        pm2 restart fvo
    fi

    # 等待服务启动
    echo "等待服务启动..."
    sleep 5

    # 验证服务状态
    if pm2 describe fvo | grep -q "errored"; then
        echo "❌ 服务启动失败"
        echo "错误日志："
        pm2 logs fvo --lines 10
        exit 1
    fi

    if [ "${PM2_STARTUP_ENABLED}" = "true" ]; then
        pm2 save
    fi
    
    # 检查是否需要更新环境变量
    if [ -f ".env.example" ] && [ -f ".env.local" ]; then
        echo "检查环境变量更新..."
        if ! cmp -s ".env.example" ".env.local"; then
            echo "=============================="
            echo "⚠️  环境变量检查"
            echo "请确认以下配置已正确设置："
            echo "1. NEXT_PUBLIC_APP_ID"
            echo "2. NEXT_PUBLIC_APP_KEY"
            echo "3. NEXT_PUBLIC_API_URL"
            echo ""
            echo "当前配置："
            if [ -f ".env.local" ]; then
                grep "NEXT_PUBLIC_" .env.local
            fi
            echo ""
            echo "发现新的环境变量配置，建议手动对比 .env.example 和 .env.local"
            echo "如需自动更新环境变量，请使用: ./install.sh --update-env"
            echo "=============================="
        fi
    fi
    
    echo "=============================="
    echo "✨ 更新完成！"
    echo ""
    echo "🔍 检查结果："
    echo "1. 环境变量："
    if [ -f ".env.example" ] && [ -f ".env.local" ]; then
        if ! cmp -s ".env.example" ".env.local"; then
            echo "   ⚠️  需要更新"
            echo "   - 请对比 .env.example 和 .env.local 文件"
            echo "   - 手动添加新的配置项到 .env.local"
        else
            echo "   ✓ 无需更新"
        fi
    fi
    
    echo "2. 服务状态："
    if pm2 describe fvo | grep -q "online"; then
        echo "   ✓ PM2 服务正常运行"
    else
        echo "   ⚠️  PM2 服务异常"
        echo "   - 请执行 pm2 logs fvo 查看日志"
    fi
    
    echo ""
    echo "🌐 访问服务："
    PUBLIC_IP=$(curl -s http://ipv4.icanhazip.com || curl -s http://api.ipify.org)
    if [ -n "$PUBLIC_IP" ]; then
        echo "   http://${PUBLIC_IP}:${PORT:-33896}"
        # 测试服务可用性
        if curl -s "http://${PUBLIC_IP}:${PORT:-33896}" > /dev/null; then
            echo "   ✓ 服务响应正常"
        else
            echo "   ⚠️  服务可能无法访问"
            echo "   - 请检查防火墙配置"
            echo "   - 检查端口是否开放: ${PORT:-33896}"
            echo "   - 查看服务日志: pm2 logs fvo"
        fi
    else
        echo "   http://<服务器IP>:${PORT:-33896}"
    fi
    echo ""
    echo "🛠  常用命令："
    echo "   pm2 status     # 查看服务状态"
    echo "   pm2 logs fvo   # 查看服务日志"
    echo "   pm2 restart fvo # 重启服务"
    echo "   pm2 stop fvo   # 停止服务"
    echo ""
    echo "=============================="
else
    echo "更新失败，请检查错误信息"
    exit 1
fi 