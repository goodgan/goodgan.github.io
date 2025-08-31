@echo off
echo ========================================
echo           Hexo Local Preview Script
echo ========================================

REM Clean and generate static files
echo Cleaning cache...
npx hexo clean

echo Generating static files...
npx hexo generate

if %errorlevel% neq 0 (
    echo Generation failed!
    pause
    exit /b 1
)

echo.
echo Generation completed! Starting local server...
echo Access URL: http://localhost:4000
echo Press Ctrl+C to stop server
echo.

npx hexo server

echo.
echo Server stopped
pause