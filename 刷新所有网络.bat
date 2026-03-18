@echo off
echo 正在重置网络配置，请稍候...
echo.

:: 提权
net session >nul 2>&1
if %errorLevel% neq 0 (
    powershell -Command "Start-Process '%~f0' -Verb RunAs"
    exit /b
)

echo 1. 重置Winsock目录...
netsh winsock reset
echo.

echo 2. 重置TCP/IP协议栈...
netsh int ip reset
echo.

echo 3. 释放当前IP地址...
ipconfig /release
echo.

echo 4. 续订IP地址...
ipconfig /renew
echo.

echo 5. 清除DNS缓存...
ipconfig /flushdns
echo.

echo 所有网络重置操作已完成！
echo 建议重新启动计算机以使更改完全生效。
pause