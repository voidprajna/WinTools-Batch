@echo off
:: 解决直接在网络共享(UNC路径)下运行报错的问题
pushd "%~dp0"

:: 获取当前 bat 文件的名称拼接成同名 .ps1，并获取当前所在的完整网络路径
set "ps1_name=%~n0.ps1"
set "source=%~dp0%ps1_name%"

:: 获取当前用户的下载文件夹路径
for /f "tokens=2*" %%a in ('reg query "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Shell Folders" /v "{374DE290-123F-4565-9164-39C4925E467B}"') do set "download_path=%%b"

:: 定义下载到本地的目标路径
set "destination=%download_path%\%ps1_name%"

:: 复制同名的 ps1 脚本到本地下载文件夹
if not exist "%destination%" (
    copy "%source%" "%destination%"
    powershell.exe -Command "Unblock-File '%destination%'"
)

:: 退出网络共享目录，恢复之前的路径环境
popd

:: 使用绕过执行策略运行本地的脚本
powershell.exe -ExecutionPolicy Bypass -File "%destination%"

:: 删除本地下载文件夹中的 ps1 文件
if exist "%destination%" (
    del "%destination%"
)