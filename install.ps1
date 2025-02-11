# 显示欢迎信息
Write-Host "欢迎使用未来变量观测局一键部署脚本"
Write-Host "=============================="

# 安装 Node.js 函数
function Install-NodeJS {
    Write-Host "正在安装 Node.js 22.x ..."
    try {
        # 下载 Node.js 安装程序
        $nodeUrl = "https://nodejs.org/dist/v22.14.0/node-v22.14.0-x64.msi"
        $installerPath = "$env:TEMP\node-installer.msi"
        Invoke-WebRequest -Uri $nodeUrl -OutFile $installerPath
        
        # 安装 Node.js
        Start-Process msiexec.exe -Wait -ArgumentList "/i $installerPath /quiet"
        Remove-Item $installerPath
        
        # 刷新环境变量
        $env:Path = [System.Environment]::GetEnvironmentVariable("Path", "Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path", "User")
    }
    catch {
        Write-Host "安装失败，请访问 https://nodejs.org/en/download/ 手动下载安装"
        exit 1
    }
}

# 检查 Node.js
try {
    $nodeVersion = (node -v).Replace('v', '')
    if ([version]$nodeVersion -lt [version]"22.0.0") {
        Write-Host "Node.js 版本需要 >= 22，当前版本: $nodeVersion"
        $updateChoice = Read-Host "是否更新 Node.js？[y/N]"
        if ($updateChoice -eq "y" -or $updateChoice -eq "Y") {
            Install-NodeJS
        }
        else {
            exit 1
        }
    }
}
catch {
    Write-Host "未检测到 Node.js"
    $installChoice = Read-Host "是否安装 Node.js？[y/N]"
    if ($installChoice -eq "y" -or $installChoice -eq "Y") {
        Install-NodeJS
    }
    else {
        Write-Host "请手动安装 Node.js >= 22"
        exit 1
    }
}

# 检查 npm 版本
try {
    $npmVersion = (npm -v)
    if ([version]$npmVersion -lt [version]"10.0.0") {
        Write-Host "npm 版本需要 >= 10，当前版本: $npmVersion"
        Write-Host "正在更新 npm..."
        npm install -g npm@latest
    }
}
catch {
    Write-Host "需要安装 npm >= 10"
    exit 1
}

# 检查并安装 pm2
function Install-PM2 {
    try {
        $pm2Version = (pm2 -v) 2>$null
        Write-Host "检测到 pm2 已安装" -ForegroundColor Green
    }
    catch {
        Write-Host "正在安装 pm2..." -ForegroundColor Yellow
        npm install -g pm2
        if ($LASTEXITCODE -ne 0) {
            Write-Host "pm2 安装失败" -ForegroundColor Red
            exit 1
        }
    }
}

# 检查依赖是否已安装
function Test-Dependencies {
    # 检查 node_modules 目录
    if (Test-Path "node_modules") {
        Write-Host "检测到依赖已安装，跳过安装步骤..." -ForegroundColor Green
        return $true
    }
    # 检查 package-lock.json
    if (Test-Path "package-lock.json") {
        Write-Host "检测到 package-lock.json，是否重新安装依赖？[y/N]" -ForegroundColor Yellow
        $reinstallChoice = Read-Host
        if ($reinstallChoice -ne "y" -and $reinstallChoice -ne "Y") {
            return $true
        }
    }
    return $false
}

# 安装依赖
if (-not (Test-Dependencies)) {
    Write-Host "正在安装依赖..." -ForegroundColor Yellow
    npm install
}

# 检查 node-windows 是否已安装
function Test-NodeWindows {
    try {
        $modulePath = Join-Path (Get-Location) "node_modules\node-windows"
        if (Test-Path $modulePath) {
            Write-Host "检测到 node-windows 已安装" -ForegroundColor Green
            return $true
        }
        return $false
    }
    catch {
        return $false
    }
}

# 安装 node-windows
if (-not (Test-NodeWindows)) {
    Write-Host "正在安装 node-windows..." -ForegroundColor Yellow
    npm install node-windows --save
    npm link node-windows
}

# 创建 Windows 服务安装脚本
$serviceScript = @"
const Service = require('node-windows').Service;
const path = require('path');

const svc = new Service({
    name: 'WebApp8Zi',
    description: '未来变量观测局 Web 服务',
    script: path.join(process.cwd(), '.next', 'standalone', 'server.js'),
    scriptOptions: '-p 33896',
    nodeOptions: '--harmony',
    workingDirectory: process.cwd(),
    allowServiceLogon: true
});

svc.on('install', () => {
    console.log('服务安装成功');
    svc.start();
});

svc.on('uninstall', () => {
    console.log('服务卸载成功');
});

svc.on('start', () => {
    console.log('服务启动成功');
});

svc.on('stop', () => {
    console.log('服务已停止');
});

svc.on('error', (err) => {
    console.error('服务错误:', err);
});

if (process.argv[2] === 'uninstall') {
    svc.uninstall();
} else {
    svc.install();
}
"@ 

# 创建服务管理脚本
$serviceScriptPath = "install-service.js"
$serviceScript | Out-File -FilePath $serviceScriptPath -Encoding UTF8

# 创建卸载脚本
$uninstallScript = @"
# 卸载 Windows 服务
Write-Host "正在卸载服务..." -ForegroundColor Yellow
node install-service.js uninstall
"@

$uninstallScriptPath = "uninstall.ps1"
$uninstallScript | Out-File -FilePath $uninstallScriptPath -Encoding UTF8

# 安装 pm2
Install-PM2

# 处理环境变量
function Setup-Env {
    param (
        [string]$AppId,
        [string]$AppKey,
        [string]$ApiUrl
    )
    
    $envFile = ".env.local"
    
    # 如果环境变量文件已存在,直接返回
    if (Test-Path $envFile) {
        Write-Host "检测到 $envFile 文件已存在,跳过配置..." -ForegroundColor Green
        return
    }
    
    # 如果命令行参数存在，使用命令行参数
    if ($AppId -and $AppKey -and $ApiUrl) {
        Write-Host "使用命令行参数配置环境变量..." -ForegroundColor Green
        @"
NEXT_PUBLIC_APP_ID=$AppId
NEXT_PUBLIC_APP_KEY=$AppKey
NEXT_PUBLIC_API_URL=$ApiUrl
"@ | Out-File -FilePath $envFile -Encoding UTF8
        return
    }
    
    # 如果环境变量文件不存在，创建并提示输入
    Write-Host "未检测到环境变量配置，请输入以下信息：" -ForegroundColor Yellow
    
    $appId = Read-Host "请输入 Dify 应用 ID (NEXT_PUBLIC_APP_ID)"
    $appKey = Read-Host "请输入 Dify API 密钥 (NEXT_PUBLIC_APP_KEY)"
    $apiUrl = Read-Host "请输入 Dify API 地址 [默认: https://api.dify.ai/v1]"
    
    if (-not $apiUrl) {
        $apiUrl = "https://api.dify.ai/v1"
    }
    
    @"
NEXT_PUBLIC_APP_ID=$appId
NEXT_PUBLIC_APP_KEY=$appKey
NEXT_PUBLIC_API_URL=$apiUrl
"@ | Out-File -FilePath $envFile -Encoding UTF8
    
    Write-Host "环境变量已保存到 $envFile" -ForegroundColor Green
}

# 设置环境变量
Setup-Env $args[0] $args[1] $args[2]

# 构建项目
Write-Host "正在构建项目..." -ForegroundColor Yellow
npm run build

# 安装并启动 Windows 服务
Write-Host "正在安装并启动 Windows 服务..." -ForegroundColor Yellow
node install-service.js

Write-Host "=============================="
Write-Host "部署完成！" -ForegroundColor Green
Write-Host "服务已作为 Windows 服务安装并启动"
Write-Host "访问 http://localhost:33896"
Write-Host ""
Write-Host "服务管理：" -ForegroundColor Yellow
Write-Host "- 启动服务：net start WebApp8Zi"
Write-Host "- 停止服务：net stop WebApp8Zi"
Write-Host "- 卸载服务：./uninstall.ps1"
Write-Host "- 查看服务：services.msc (在系统服务中查找 'WebApp8Zi')"
Write-Host ""
Write-Host "日志查看：" -ForegroundColor Yellow
Write-Host "- 事件查看器(eventvwr.msc) -> Windows 日志 -> 应用程序"
Write-Host "- 在事件查看器中搜索来源为 'WebApp8Zi' 的日志" 