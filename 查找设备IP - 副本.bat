@echo off
echo Host: %COMPUTERNAME%
powershell -NoProfile -Command "Get-NetIPAddress -AddressFamily IPv4 | Where-Object IPAddress -like '192.168.*' | Select-Object -First 1 | ForEach-Object { $nic = Get-NetAdapter -InterfaceAlias $_.InterfaceAlias; Write-Host 'Adapter:' $nic.Name; Write-Host 'MAC:' $nic.MacAddress; Write-Host 'IPv4:' $_.IPAddress }"
echo.
pause