@echo off
echo ==========================================================
echo        Launching Vision AI Flutter Web Client
echo ==========================================================
cd /d "%~dp0frontend"
call "C:\Users\HP-PC\flutter_sdk\flutter\bin\flutter.bat" run -d chrome
pause

