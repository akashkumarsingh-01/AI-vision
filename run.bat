@echo off
echo ==========================================================
echo           Starting Vision AI Assistant System
echo ==========================================================
echo [1/2] Checking Node.js environment...
cd /d "%~dp0backend"
if not exist node_modules (
    echo Installing backend dependencies...
    call npm install
)

echo [2/2] Launching Vision AI Server on http://localhost:5000 ...
start http://localhost:5000
npm start

