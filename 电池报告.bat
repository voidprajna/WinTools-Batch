@echo off

:: 1. 定义目标文件夹（当前路径下的"电池报告"，中文无乱码）
set "report_dir=电池报告"

:: 2. 自动获取电脑名（无需手动修改）
for /f "delims=" %%a in ('hostname') do set "pc_name=%%a"

:: 3. 拼接完整输出路径（脚本所在目录\电池报告\电脑名.html）
set "report_path=%~dp0%report_dir%\%pc_name%.html"

:: 4. 文件夹不存在则创建（中文路径兼容）
if not exist "%~dp0%report_dir%" (
    md "%~dp0%report_dir%" >nul 2>&1
    echo 已创建文件夹：%~dp0%report_dir%
)

:: 5. 生成电池报告（无乱码，Win10 直接执行）
echo 正在生成电池报告...
powercfg /batteryreport /output "%report_path%" /duration 7

:: 6. 结果提示（中文正常显示）
if exist "%report_path%" (
    echo 电池报告生成成功！
    echo 保存路径：%report_path%
    start "" "%~dp0%report_dir%"  :: 自动打开文件夹（可删除此行）
) else (
    echo 生成失败！请将脚本放在无特殊字符的路径下（仅中文/英文/数字）
)

pause