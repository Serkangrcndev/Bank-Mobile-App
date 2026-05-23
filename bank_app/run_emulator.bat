@echo off
echo =============================================
echo   FINTECH ELITE - Build and Run
echo =============================================

echo.
echo [1/4] Restarting ADB...
C:\Users\Kale\AppData\Local\Android\sdk\platform-tools\adb.exe kill-server
timeout /t 2 /nobreak >nul
C:\Users\Kale\AppData\Local\Android\sdk\platform-tools\adb.exe start-server

echo.
echo [2/4] Forwarding debug port...
C:\Users\Kale\AppData\Local\Android\sdk\platform-tools\adb.exe forward tcp:8888 tcp:8888

echo.
echo [3/4] Running Flutter (hot reload enabled)...
C:\flutter\bin\flutter.bat run --no-dds --device-vmservice-port=8888 --host-vmservice-port=8888

pause
