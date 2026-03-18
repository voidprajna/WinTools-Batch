# ==========================================
# 专为 MSI 版 RustDesk 编写的卸载脚本
# ==========================================

# 1. 检查管理员权限 (MSI 卸载必备)
$isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $isAdmin) {
    Write-Host "[警告] 当前未以管理员权限运行！MSI 卸载极大概率会失败。" -ForegroundColor Red
    Write-Host "请右键你的 .bat 文件，选择【以管理员身份运行】。" -ForegroundColor Yellow
    Start-Sleep -Seconds 3
}

# 2. 强力终止进程和服务，释放文件锁定
Write-Host "正在终止 RustDesk 进程和系统服务..." -ForegroundColor Cyan
& taskkill /F /IM "rustdesk.exe" /T 2>&1 | Out-Null
& net stop RustDesk 2>&1 | Out-Null
# 确保后台的 msi 进程没有卡死
& taskkill /F /IM "msiexec.exe" /T 2>&1 | Out-Null
Start-Sleep -Seconds 2

# 3. 在注册表中精准查找 MSI 卸载信息
Write-Host "正在搜索 RustDesk MSI 安装记录..." -ForegroundColor Cyan
$uninstallKeys = @(
    "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*",
    "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*"
)

$msiFound = $false

foreach ($key in $uninstallKeys) {
    $apps = Get-ItemProperty $key -ErrorAction SilentlyContinue | Where-Object { $_.DisplayName -match "RustDesk" }
    foreach ($app in $apps) {
        if ($app.UninstallString -match "msiexec") {
            $msiFound = $true
            $uninstallStr = $app.UninstallString
            Write-Host "找到 MSI 卸载命令: $uninstallStr" -ForegroundColor Yellow
            
            # 提取 GUID
            if ($uninstallStr -match "({[A-Fa-f0-9\-]+})") {
                $guid = $matches[1]
                Write-Host "准备执行 MSI 静默卸载，GUID: $guid" -ForegroundColor Cyan
                
                # 参数说明：
                # /X 卸载
                # /qn 完全静默 (如果想看进度条可以改成 /qb)
                # /norestart 不重启
                # /l*v 开启详细日志，输出到 temp 目录，方便排查彻底失败的原因
                $logFile = "$env:TEMP\RustDesk_Uninstall.log"
                $arguments = "/X $guid /qn /norestart /l*v `"$logFile`""
                
                Write-Host "正在卸载，请稍候..."
                $process = Start-Process -FilePath "msiexec.exe" -ArgumentList $arguments -Wait -PassThru -NoNewWindow
                
                # 检查退出代码
                $exitCode = $process.ExitCode
                if ($exitCode -eq 0) {
                    Write-Host "MSI 卸载成功！(ExitCode: 0)" -ForegroundColor Green
                } elseif ($exitCode -eq 1605) {
                    Write-Host "操作仅对当前安装的产品有效。(软件可能已被卸载)" -ForegroundColor Yellow
                } elseif ($exitCode -eq 1603) {
                    Write-Host "MSI 卸载发生严重错误！(ExitCode: 1603)" -ForegroundColor Red
                    Write-Host "请检查日志文件: $logFile" -ForegroundColor Red
                } else {
                    Write-Host "MSI 卸载返回异常代码: $exitCode" -ForegroundColor DarkYellow
                    Write-Host "日志文件路径: $logFile"
                }
            }
        }
    }
}

if (-not $msiFound) {
    Write-Host "未在注册表中找到 RustDesk 的 MSI 安装记录。" -ForegroundColor Yellow
}

# 等待系统刷新
Start-Sleep -Seconds 3

# 4. 清理用户配置文件夹 (AppData)
Write-Host "正在清理用户配置文件夹..." -ForegroundColor Cyan
$appDataPath = Join-Path $env:APPDATA "RustDesk"
$localAppDataPath = Join-Path $env:LOCALAPPDATA "RustDesk"

if (Test-Path $appDataPath) {
    Remove-Item -Path $appDataPath -Recurse -Force -ErrorAction SilentlyContinue
    Write-Host "已删除: $appDataPath" -ForegroundColor Green
}
if (Test-Path $localAppDataPath) {
    Remove-Item -Path $localAppDataPath -Recurse -Force -ErrorAction SilentlyContinue
    Write-Host "已删除: $localAppDataPath" -ForegroundColor Green
}

Write-Host "脚本执行完毕！" -ForegroundColor Green