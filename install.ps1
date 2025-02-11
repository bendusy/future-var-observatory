# 显示欢迎信息
Write-Host "欢迎使用未来变量观测局一键部署脚本"
Write-Host "=============================="

# 检查 Node.js
try {
    $nodeVersion = (node -v).Replace('v','')
    if ([version]$nodeVersion -lt [version]"18.0.0") {
        Write-Host "Node.js 版本需要 >= 18，当前版本: $nodeVersion"
        exit 1
    }
} catch {
    Write-Host "需要安装 Node.js >= 18"
    exit 1
}

# 检查 npm
try {
    $npmVersion = (npm -v)
    if ([version]$npmVersion -lt [version]"9.0.0") {
        Write-Host "npm 版本需要 >= 9，当前版本: $npmVersion"
        exit 1
    }
} catch {
    Write-Host "需要安装 npm >= 9"
    exit 1
}

# 安装依赖
Write-Host "正在安装依赖..."
npm install

# 检查环境变量文件
if (-not (Test-Path .env.local)) {
    Write-Host "未检测到 .env.local 文件，将从 .env.example 创建..."
    Copy-Item .env.example .env.local
    Write-Host "请编辑 .env.local 文件，填入必要的配置信息："
    Write-Host "- NEXT_PUBLIC_APP_ID: Dify 应用 ID"
    Write-Host "- NEXT_PUBLIC_APP_KEY: Dify API 密钥"
    Write-Host "- NEXT_PUBLIC_API_URL: Dify API 地址"
    exit 1
}

# 构建项目
Write-Host "正在构建项目..."
npm run build

# 启动服务
Write-Host "正在启动服务..."
npm start 