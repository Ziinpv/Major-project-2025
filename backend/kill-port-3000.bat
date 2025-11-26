@echo off
echo ========================================
echo Killing process on port 3000
echo ========================================
echo.

echo Finding process on port 3000...
for /f "tokens=5" %%a in ('netstat -ano ^| findstr :3000') do (
    set PID=%%a
    echo Found process ID: %%a
    echo Killing process...
    taskkill /F /PID %%a
    echo Process killed!
)

echo.
echo ========================================
echo Done! You can now start the server with:
echo npm start
echo ========================================
pause

