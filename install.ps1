# 显示欢迎信息
Write-Host "欢迎使用未来变量观测局一键部署脚本"
Write-Host "=============================="

# 检查 Dify 服务可用性
function Test-DifyService {
    param (
        [string]$AppId,
        [string]$AppKey,
        [string]$ApiUrl
    )
    
    Write-Host "正在检查 Dify 服务可用性..."
    
    # 检查API地址是否可访问
    try {
        $response = Invoke-WebRequest -Uri $ApiUrl -Method Head -UseBasicParsing
        if ($response.StatusCode -ne 200) {
            throw
        }
    }
    catch {
        Write-Host "错误: 无法连接到 Dify 服务 ($ApiUrl)"
        Write-Host "请确保："
        Write-Host "1. Dify 服务已正确部署"
        Write-Host "2. API 地址可以访问"
        Write-Host "3. 如果是自托管，请确保版本 >= 0.3.30"
        return $false
    }
    
    # 验证 APP_ID 和 API_KEY
    try {
        $headers = @{
            "Authorization" = "Bearer $AppKey"
            "Content-Type"  = "application/json"
        }
        $body = @{
            "inputs" = @{}
            "query"  = "test"
        } | ConvertTo-Json
        
        $response = Invoke-WebRequest -Uri "$ApiUrl/chat-messages" -Method Post -Headers $headers -Body $body -UseBasicParsing
        if ($response.StatusCode -ne 200) {
            throw
        }
    }
    catch {
        Write-Host "错误: APP_ID 或 API_KEY 无效"
        Write-Host "请检查："
        Write-Host "1. APP_ID 和 API_KEY 是否正确"
        Write-Host "2. 应用是否已发布"
        Write-Host "3. 应用类型是否为 AI Assistant"
        return $false
    }
    
    Write-Host "Dify 服务检查通过"
    return $true
}

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

# 检查并更新 npm
try {
    $npmVersion = (npm -v)
    if ([version]$npmVersion -lt [version]"10.0.0") {
        Write-Host "正在更新 npm..."
        npm install -g npm@latest
    }
}
catch {
    Write-Host "npm 检查失败"
    exit 1
}

# 安装依赖
Write-Host "正在安装依赖..."
try {
    npm install
}
catch {
    Write-Host "尝试使用淘宝镜像重新安装..."
    npm config set registry https://registry.npmmirror.com
    try {
        npm install
    }
    catch {
        Write-Host "依赖安装失败，请检查网络连接"
        exit 1
    }
}

# 处理环境变量
function Setup-Env {
    param (
        [string]$AppId,
        [string]$AppKey,
        [string]$ApiUrl
    )
    
    $envFile = ".env.local"
    
    # 如果环境变量文件已存在，询问是否覆盖
    if (Test-Path $envFile) {
        Write-Host "检测到 $envFile 文件已存在，是否覆盖？[y/N]"
        $overwriteChoice = Read-Host
        if ($overwriteChoice -ne "y" -and $overwriteChoice -ne "Y") {
            return
        }
    }
    
    # 如果命令行参数存在，使用命令行参数
    if ($AppId -and $AppKey -and $ApiUrl) {
        Write-Host "使用命令行参数配置环境变量..."
        if (-not (Test-DifyService $AppId $AppKey $ApiUrl)) {
            exit 1
        }
        @"
NEXT_PUBLIC_APP_ID=$AppId
NEXT_PUBLIC_APP_KEY=$AppKey
NEXT_PUBLIC_API_URL=$ApiUrl
"@ | Out-File -FilePath $envFile -Encoding UTF8
        return
    }
    
    # 交互式配置
    do {
        Write-Host "请输入配置信息："
        $appId = Read-Host "Dify 应用 ID (NEXT_PUBLIC_APP_ID)"
        $appKey = Read-Host "Dify API 密钥 (NEXT_PUBLIC_APP_KEY)"
        $apiUrl = Read-Host "Dify API 地址 [默认: https://api.dify.ai/v1]"
        
        if (-not $apiUrl) {
            $apiUrl = "https://api.dify.ai/v1"
        }
        
        if (Test-DifyService $appId $appKey $apiUrl) {
            break
        }
        
        Write-Host "是否重新输入配置？[Y/n]"
        $retryChoice = Read-Host
        if ($retryChoice -eq "n" -or $retryChoice -eq "N") {
            exit 1
        }
    } while ($true)
    
    @"
NEXT_PUBLIC_APP_ID=$appId
NEXT_PUBLIC_APP_KEY=$appKey
NEXT_PUBLIC_API_URL=$apiUrl
"@ | Out-File -FilePath $envFile -Encoding UTF8
    
    Write-Host "环境变量已保存到 $envFile"
}

# 设置环境变量
Setup-Env $args[0] $args[1] $args[2]

# 构建项目
Write-Host "正在构建项目..."
npm run build

# 启动服务
Write-Host "正在启动服务..."
npm run start

Write-Host "=============================="
Write-Host "部署完成！"
Write-Host "服务已启动，访问 http://localhost:33896"
Write-Host ""
Write-Host "服务管理命令："
Write-Host "- 启动服务：npm run start"
Write-Host "- 停止服务：按 Ctrl+C 终止进程" 