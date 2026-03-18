' 在顶部添加错误处理，防止弹出报错窗口
On Error Resume Next

Dim WriteRegistry
Set WriteRegistry = WScript.CreateObject("WScript.Shell")

' 1. 修改注册表，明确指定类型为字符串 "REG_SZ"
' 注意：如果你原本想设置的是开关(0/1)，应使用 "REG_DWORD"
WriteRegistry.RegWrite "HKEY_CURRENT_USER\Software\Microsoft\Internet Explorer\Main\Enable Browser Extensions", "no", "REG_SZ"

' 2. 创建 IE 对象
Dim ie
Set ie = CreateObject("InternetExplorer.Application")

If Err.Number <> 0 Then
    MsgBox "无法创建 IE 对象，请检查系统是否支持 IE", 16, "错误"
    WScript.Quit
End If

ie.Visible = True
ie.Navigate "https://www.bing.com" ' 修正为标准的 baidu.com

' 3. 等待加载的逻辑优化
' 增加对 ReadyState 的判断，比单纯的 Busy 更可靠
Do While ie.Busy Or ie.ReadyState <> 4
    WScript.Sleep 100
Loop

' 关闭错误处理（根据需要决定是否恢复）
On Error Goto 0