@echo off
setlocal enabledelayedexpansion

:: 1. 自动提权
net session >nul 2>&1
if %errorLevel% neq 0 (
    powershell -Command "Start-Process '%~f0' -Verb RunAs"
    exit /b
)

:menu
cls
echo ==========================================
echo           网络适配器快捷开关
echo ==========================================
echo.

:: 2. 遍历并解析所有网卡信息
set "count=0"
:: skip=3 用来跳过 netsh 输出的前三行表头
:: tokens=1,2,3,* 用来提取：管理状态(%%A), 连接状态(%%B), 类型(%%C), 网卡名称(%%D)
for /f "skip=3 tokens=1,2,3,* delims= " %%A in ('netsh interface show interface') do (
    set /a count+=1
    set "netState[!count!]=%%A"
    set "netName[!count!]=%%D"
    echo   [!count!] %%D  (当前状态: %%A)
)

if !count! equ 0 (
    echo   !! 没有检测到任何网络适配器。
    echo.
    pause
    exit /b
)

echo.
echo ==========================================
set /p choice="请输入要切换的网卡序号 (1-!count!)，输入 0 退出: "

:: 检查是否退出
if "%choice%"=="0" exit /b

:: 检查输入是否合法
if not defined netName[%choice%] (
    echo.
    echo !! 输入无效，请重新输入！
    timeout /t 2 /nobreak >nul
    goto menu
)

:: 3. 获取目标网卡信息并执行切换
set "TARGET_NAME=!netName[%choice%]!"
set "TARGET_STATE=!netState[%choice%]!"

echo.
echo 正在操作: [%TARGET_NAME%] ...

:: 判断当前是启用还是禁用 (兼容中英文)
echo !TARGET_STATE! | findstr /i /c:"已启用" /c:"Enabled" >nul
if !errorlevel! equ 0 (
    echo --^> 检测到已开启，正在【禁用】...
    netsh interface set interface name="!TARGET_NAME!" admin=disabled
) else (
    echo --^> 检测到已关闭，正在【启用】...
    netsh interface set interface name="!TARGET_NAME!" admin=enabled
)

echo.
echo 操作完成！按任意键刷新菜单...
pause >nul
goto menu