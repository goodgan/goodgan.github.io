@echo off
echo ========================================
echo           Git Commit and Push Script
echo ========================================

REM Check if there are any changes
git status --porcelain > nul
if %errorlevel% neq 0 (
    echo No changes detected, exiting script
    pause
    exit /b
)

REM Display current status
echo Current changes:
git status --short

echo.
set /p commit_msg="Enter commit message (press Enter for default): "

REM If no input, use default message
if "%commit_msg%"=="" set commit_msg=Update content

echo.
echo Committing changes...
git add .
git commit -m "%commit_msg%"

if %errorlevel% neq 0 (
    echo Commit failed!
    pause
    exit /b 1
)

echo Pushing to remote repository...
git push

if %errorlevel% neq 0 (
    echo Push failed!
    pause
    exit /b 1
)

echo Commit and push completed!
pause
