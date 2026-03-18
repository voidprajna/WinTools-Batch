#Requires -RunAsAdministrator

<#
.SYNOPSIS
    高级域推送脚本可靠性测试工具。
.DESCRIPTION
    该脚本用于测试通过组策略或SCCM等机制推送到域内客户端的脚本是否可靠执行。
    功能包括：
      - 清理并重建测试文件夹
      - 写入带时间戳的日志
      - 设置ACL（模拟权限配置）
      - 检测网络连通性（可选）
      - 记录执行环境信息（计算机名、用户、OS版本等）
.PARAMETER FolderPath
    测试文件夹路径，默认为 "C:\域控测试文件夹"
.PARAMETER LogFileName
    日志文件名，默认为 "PushTest.log"
.EXAMPLE
    .\Test-DomainPushReliability.ps1 -FolderPath "C:\DomainTest" -LogFileName "DeploymentTest.log"
#>

param(
    [string]$FolderPath = "C:\域控测试文件夹",
    [string]$LogFileName = "PushTest.log"
)

# 日志函数
function Write-Log {
    param([string]$Message)
    $Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $LogEntry = "[$Timestamp] [$env:COMPUTERNAME] $Message"
    Write-Host $LogEntry -ForegroundColor Cyan
    Add-Content -Path (Join-Path $FolderPath $LogFileName) -Value $LogEntry -Force
}

# 主函数
try {
    # 创建日志目录（即使后续要删除，也先确保能写日志）
    if (-not (Test-Path -Path $FolderPath)) {
        $null = New-Item -Path $FolderPath -ItemType Directory -Force
    }

    Write-Log "=== 域推送可靠性测试开始 ==="

    # 记录执行上下文
    Write-Log "当前用户: $([System.Security.Principal.WindowsIdentity]::GetCurrent().Name)"
    Write-Log "操作系统: $((Get-CimInstance Win32_OperatingSystem).Caption)"
    Write-Log "PowerShell 版本: $($PSVersionTable.PSVersion)"
    Write-Log "是否以管理员运行: $(([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator))"

    # 如果文件夹已存在，则彻底清理（模拟干净部署）
    if (Test-Path -Path $FolderPath) {
        Write-Log "检测到旧文件夹，正在清理..."
        Remove-Item -Path $FolderPath -Recurse -Force -ErrorAction Stop
        Start-Sleep -Seconds 1  # 避免文件句柄未释放
    }

    # 重新创建文件夹
    $null = New-Item -Path $FolderPath -ItemType Directory -Force
    Write-Log "成功创建测试文件夹: $FolderPath"

    # 设置基本权限（例如：允许 Domain Users 读取）
    try {
        $Acl = Get-Acl $FolderPath
        $AccessRule = New-Object System.Security.AccessControl.FileSystemAccessRule("Domain Users", "ReadAndExecute", "ContainerInherit,ObjectInherit", "None", "Allow")
        $Acl.SetAccessRule($AccessRule)
        Set-Acl -Path $FolderPath -AclObject $Acl
        Write-Log "已设置文件夹权限：授予 'Domain Users' 读取权限"
    } catch {
        Write-Log "警告：设置权限失败 - $($_.Exception.Message)"
    }

    # 可选：测试网络连通性（例如能否访问域控制器 SYSVOL）
    $DcPath = "\\$env:USERDNSDOMAIN\SYSVOL"
    if (Test-Path $DcPath) {
        Write-Log "网络验证：可访问域共享 $DcPath"
    } else {
        Write-Log "警告：无法访问域共享 $DcPath（可能影响组策略推送）"
    }

    # 创建一个测试文件
    $TestFile = Join-Path $FolderPath "test_file.txt"
    Set-Content -Path $TestFile -Value "This file was created by domain push test script on $(Get-Date)" -Force
    Write-Log "已创建测试文件: $TestFile"

    Write-Log "=== 域推送测试完成 ==="

} catch {
    if (-not (Test-Path $FolderPath)) {
        # 若主目录不存在，尝试在临时目录记录错误
        $FallbackLog = Join-Path $env:TEMP "DomainPushTest_Error.log"
        "[$(Get-Date)] 脚本执行失败: $($_.Exception.Message)`n$($_.ScriptStackTrace)" | Out-File $FallbackLog -Append
    } else {
        Write-Log "严重错误: $($_.Exception.Message)"
    }
    exit 1
}