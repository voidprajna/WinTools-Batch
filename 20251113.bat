@echo off
:: 获取当前用户的下载文件夹路径
for /f "tokens=2*" %%a in ('reg query "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Shell Folders" /v "{374DE290-123F-4565-9164-39C4925E467B}"') do set "download_path=%%b"

:: 定义源文件和目标文件路径
set "source=\\pe\共享文件夹\1-3 测试工具\20251113.ps1"
set "destination=%download_path%\20251113.ps1"

:: 复制脚本到下载文件夹并解除锁定
if not exist "%destination%" (
    copy "%source%" "%destination%"
    powershell.exe -Command "Unblock-File '%destination%'"
)

:: 使用绕过执行策略运行脚本
powershell.exe -ExecutionPolicy Bypass -File "%destination%"

:: 删除下载文件夹中的 ps1 文件
if exist "%destination%" (
    del "%destination%"
)
