@echo off
:: 提权
echo ==============================
echo    正在检查权限情况
echo ==============================
net session >nul 2>&1
if %errorLevel% neq 0 (
    powershell -Command "Start-Process '%~f0' -Verb RunAs"
    exit /b
)

:menu
cls
echo ==============================
echo    Windows 右键菜单切换工具
echo ==============================
echo.
echo 1. 恢复 Win10 经典右键菜单
echo 2. 恢复 Win11 默认右键菜单
echo 3. 退出
echo.
set /p choice=请输入选项（1/2/3）：
if "%choice%"=="1" goto win10
if "%choice%"=="2" goto win11
if "%choice%"=="3" exit
echo 输入无效，请重新输入！
pause
goto menu

:win10
reg add "HKCU\Software\Classes\CLSID\{86ca1aa0-34aa-4e8b-a509-50c905bae2a2}\InprocServer32" /ve /d "" /f
echo Win10 经典右键菜单已启用！
goto restart

:win11
reg delete "HKCU\Software\Classes\CLSID\{86ca1aa0-34aa-4e8b-a509-50c905bae2a2}" /f
echo Win11 默认右键菜单已恢复！
goto restart

:restart
taskkill /f /im explorer.exe >nul
start explorer.exe
echo 资源管理器已重启，更改生效！
pause
goto menu