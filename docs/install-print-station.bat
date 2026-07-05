@echo off
chcp 65001 >nul
title 打印站安装器

echo ==========================================
echo   点餐系统 - 打印站一键安装
echo ==========================================
echo.
echo 本脚本将创建两个快捷方式：
echo   1. 桌面快捷方式 - 手动启动打印站
echo   2. 启动项 - 开机自动进入打印站
echo.
echo 按任意键继续安装...
pause >nul

:: Create temp profile dir if not exists
if not exist "%TEMP%\chrome-kiosk-print" mkdir "%TEMP%\chrome-kiosk-print"

:: Create desktop shortcut
set DESKTOP=%USERPROFILE%\Desktop
set SHORTCUT=%DESKTOP%\打印站.lnk

powershell -Command ^
  "$WScriptShell = New-Object -ComObject WScript.Shell; ^
   $s = $WScriptShell.CreateShortcut('%SHORTCUT%'); ^
   $s.TargetPath = 'C:\Program Files\Google\Chrome\Application\chrome.exe'; ^
   $s.Arguments = '--kiosk --kiosk-printing --user-data-dir=\"%TEMP%\chrome-kiosk-print\" \"https://app-cor1b70nj9xd.vercel.app/\"'; ^
   $s.WorkingDirectory = 'C:\Program Files\Google\Chrome\Application'; ^
   $s.Save()"

echo [OK] 桌面快捷方式: %SHORTCUT%

:: Create startup shortcut
set STARTUP=%APPDATA%\Microsoft\Windows\Start Menu\Programs\Startup
set STARTUP_LNK=%STARTUP%\打印站.lnk

powershell -Command ^
  "$WScriptShell = New-Object -ComObject WScript.Shell; ^
   $s = $WScriptShell.CreateShortcut('%STARTUP_LNK%'); ^
   $s.TargetPath = 'C:\Program Files\Google\Chrome\Application\chrome.exe'; ^
   $s.Arguments = '--kiosk --kiosk-printing --user-data-dir=\"%TEMP%\chrome-kiosk-print\" \"https://app-cor1b70nj9xd.vercel.app/\"'; ^
   $s.WorkingDirectory = 'C:\Program Files\Google\Chrome\Application'; ^
   $s.Save()"

echo [OK] 开机启动项: %STARTUP_LNK%

echo.
echo ==========================================
echo   安装完成！
echo.
echo   手动启动: 双击桌面"打印站"
echo   自动启动: 重启电脑即可
echo.
echo   退出 Kiosk: Alt+F4
echo ==========================================
pause
