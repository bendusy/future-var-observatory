# 显示欢迎信息
Write-Host "未来变量观测局一键更新脚本"
Write-Host "=============================="

# 检查是否在正确的目录
if (-not (Test-Path "install.ps1")) {
    Write-Host "错误: 请在项目根目录下运行此脚本" -ForegroundColor Red
    exit 1
}

# 执行更新
Write-Host "正在执行更新..."
& .\install.ps1 --update

# 如果更新成功，重启服务
if ($LASTEXITCODE -eq 0) {
    Write-Host "正在重启服务..."
    pm2 restart fvo
    Write-Host "更新完成！" -ForegroundColor Green
}
else {
    Write-Host "更新失败，请检查错误信息" -ForegroundColor Red
    exit 1
} 