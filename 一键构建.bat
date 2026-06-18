@echo off
chcp 65001 >nul
cd /d "%~dp0"
powershell -NoProfile -ExecutionPolicy Bypass -File ".\scripts\build.ps1"
if errorlevel 1 (
  echo.
  echo 构建失败，请查看上方错误信息。
  pause
  exit /b 1
)
echo.
echo 构建成功，结果位于 dist 目录。
pause
