@echo off
chcp 65001 >nul
:: 1. 获取管理员权限
net session >nul 2>&1
if %errorLevel% neq 0 (
    powershell -Command "Start-Process '%~f0' -Verb RunAs"
    exit /b
)

echo ==========================================
echo 正在重置蓝牙模块...
echo ==========================================

:: 2. 停止蓝牙服务 (原脚本漏了停止操作)
echo [1/3] 正在停止蓝牙服务...
net stop bthserv /y >nul 2>&1

:: 3. 软重启蓝牙硬件 (合并了你的禁用和启用逻辑，修复了乱码)
echo [2/3] 正在重启蓝牙硬件适配器...
powershell -NoProfile -ExecutionPolicy Bypass -Command ^
  "$devs = Get-PnpDevice -Class Bluetooth | Where-Object { $_.Status -eq 'OK' -or $_.Status -eq 'Error' }; " ^
  "if(!$devs){ Write-Host '  !! 未找到可用的蓝牙设备' ; exit }; " ^
  "foreach($d in $devs){ " ^
  "  try { Disable-PnpDevice -InstanceId $d.InstanceId -Confirm:$false; Write-Host ('  >> 已禁用: ' + $d.FriendlyName) } " ^
  "  catch { Write-Host ('  !! 禁用失败: ' + $_.Exception.Message) } " ^
  "}; " ^
  "Start-Sleep -Seconds 2; " ^
  "foreach($d in $devs){ " ^
  "  try { Enable-PnpDevice -InstanceId $d.InstanceId -Confirm:$false; Write-Host ('  >> 已启用: ' + $d.FriendlyName) } " ^
  "  catch { Write-Host ('  !! 启用失败: ' + $_.Exception.Message) } " ^
  "}"

:: 4. 启动蓝牙服务
echo [3/3] 正在启动蓝牙服务...
net start bthserv >nul 2>&1
timeout /t 2 /nobreak >nul
if %errorLevel% equ 0 (
    echo   -^> 服务已成功启动。
) else (
    echo   -^> !! 服务启动失败，请检查系统设置。
)

echo.
echo ==========================================
echo 操作完成！
echo ==========================================
pause