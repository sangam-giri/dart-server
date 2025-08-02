@echo off
REM Change to the directory where this script is located
cd /d "%~dp0"

REM Ensure Dart SDK is available
where dart >nul 2>nul
if %errorlevel% neq 0 (
    echo Dart SDK is not installed or not in PATH.
    pause
    exit /b 1
)

REM Run the Dart project
echo Running Dart server...
dart run bin/server.dart

pause
