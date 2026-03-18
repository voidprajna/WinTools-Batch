@echo off
:: ====================================================
:: 域环境用户清理脚本（支持 cleanmgr，无需管理员权限）
:: 适用于 GPO 登录脚本推送
:: ====================================================

set "log=%temp%\cleanup_user.log"

:: 添加时间戳分隔
>> "%log%" echo.
>> "%log%" echo ================================
>> "%log%" echo 用户清理脚本执行: %date% %time%

:: 创建测试文件夹（可选）
set "test_folder=D:\测试文件夹"
if not exist "%test_folder%" (
    mkdir "%test_folder%" 2>nul
    if exist "%test_folder%" (
        >> "%log%" echo [OK] 测试文件夹创建成功: %test_folder%
    ) else (
        >> "%log%" echo [WARN] 无法创建测试文件夹
    )
) else (
    >> "%log%" echo [OK] 测试文件夹已存在
)

:: 清理用户临时文件
call :clean_folder "%temp%"
call :clean_folder "%localappdata%\Temp"

:: 清理缩略图缓存
set "explorer_cache=%localappdata%\Microsoft\Windows\Explorer"
if exist "%explorer_cache%" (
    del /f /q "%explorer_cache%\thumbcache_*.db" >nul 2>&1
    >> "%log%" echo [OK] 缩略图缓存已清理
)

:: 清理各盘符根目录下的 Thumbs.db（仅用户有权限时）
for %%D in (C D E F G H I J K L M N O P Q R S T U V W X Y Z) do (
    if exist "%%D:\*.Thumbs.db" (
        del /f /q "%%D:\*.Thumbs.db" >nul 2>&1 && >> "%log%" echo [OK] 已清理 %%D:\Thumbs.db
    )
)

:: ? 加回 cleanmgr（普通用户可用）
:: 注意：需提前在模板机运行 cleanmgr 设置 sagerun:1
if exist "%windir%\system32\cleanmgr.exe" (
    start "" /min cleanmgr /sagerun:1 >nul 2>&1
    >> "%log%" echo [OK] 磁盘清理工具已启动（/sagerun:1）
) else (
    >> "%log%" echo [WARN] cleanmgr.exe 未找到
)

:: 记录完成
>> "%log%" echo [INFO] 用户级清理完成
>> "%log%" echo 结束时间: %date% %time%
>> "%log%" echo ================================

exit /b 0

:: ================ 函数区 ================
:clean_folder
if exist "%~1" (
    pushd "%~1" >nul 2>&1
    if not errorlevel 1 (
        del /f /q *.* >nul 2>&1
        >> "%log%" echo [OK] 已清理: %~1
        popd
    ) else (
        >> "%log%" echo [WARN] 无法进入: %~1
    )
)
exit /b