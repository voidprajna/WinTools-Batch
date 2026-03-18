@echo off
setlocal enabledelayedexpansion

:: 1. 快速获取主机名
echo Host: %COMPUTERNAME%

set "adapter="
set "mac="

:: 2. 遍历 ipconfig 输出（利用内部字符串查找，速度极快）
for /f "delims=" %%i in ('ipconfig /all') do (
    set "line=%%i"
    
    :: 判断是否是适配器名称行 (行首没有空格)
    if "!line:~0,1!" neq " " (
        if "!line:~0,1!" neq "" (
            set "adapter=!line!"
            set "mac="
        )
    )

    :: 记录物理地址（匹配中英文）
    if "!line:Physical Address=!" neq "!line!" set "mac=!line!"
    if "!line:物理地址=!" neq "!line!" set "mac=!line!"

    :: 寻找包含 192.168. 的 IPv4 行
    if "!line:IPv4=!" neq "!line!" (
        if "!line:192.168.=!" neq "!line!" (
            echo Adapter: !adapter!
            echo !mac!
            echo !line!
            goto :done
        )
    )
)

:done
echo.
pause