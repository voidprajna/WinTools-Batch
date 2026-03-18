@echo off
chcp 65001 >nul
setlocal

:: 定义路径和文件名
set "IE_PATH=C:\Program Files\Internet Explorer\iexplore.exe"
set "SHORTCUT_NAME=IE浏览器.lnk"
set "ARGS=bing -Embedding"

:: 检查 IE 是否存在
if not exist "%IE_PATH%" (
    echo [警告] 未找到 Internet Explorer 主程序。
    echo 路径: %IE_PATH%
    echo 在 Windows 10/11 中，IE 可能已被禁用或移除。
    echo 脚本将继续尝试创建快捷方式，但可能无法正常运行。
)

echo 正在创建快捷方式: %SHORTCUT_NAME%
echo 目标路径: %IE_PATH%
echo 启动参数: %ARGS%

:: 使用 PowerShell 创建 .lnk 文件
:: 这种方法比纯 CMD 更可靠，可以精确设置 TargetPath 和 Arguments
powershell -Command ^
    "$WshShell = New-Object -ComObject WScript.Shell; " ^
    "$Shortcut = $WshShell.CreateShortcut('%CD%\%SHORTCUT_NAME%'); " ^
    "$Shortcut.TargetPath = '%IE_PATH%'; " ^
    "$Shortcut.Arguments = '%ARGS%'; " ^
    "$Shortcut.WorkingDirectory = 'C:\Program Files\Internet Explorer'; " ^
    "$Shortcut.Save()"

if exist "%SHORTCUT_NAME%" (
    echo.
    echo [成功] 快捷方式已生成！
    echo 位置: %CD%\%SHORTCUT_NAME%
    start "" "%SHORTCUT_NAME%"
    echo.
    echo 提示：双击该快捷方式将执行命令：
    echo "%IE_PATH%" %ARGS%
) else (
    echo.
    echo [失败] 快捷方式创建失败，请检查权限。
)

pause