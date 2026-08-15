@echo off
setlocal EnableExtensions EnableDelayedExpansion
title Lock Screen Blur Toggle

REM ====================================================
REM  Disable/restore the Windows 10-11 sign-in screen
REM  background blur effect.
REM  Double-click for the menu, or pass an argument:
REM    disable  Disable blur, restore clear background
REM    enable   Restore the Windows default blur
REM    status   Show current state
REM ====================================================

if /i "%~1"=="-check" (
    echo [PARSE-OK]
    exit /b 0
)

whoami /groups 2>nul | findstr "S-1-16-12288" >nul
if errorlevel 1 (
    echo [INFO] Administrator rights required. Requesting elevation, click Yes in the UAC prompt...
    powershell -NoProfile -Command "Start-Process -FilePath '%~f0' -ArgumentList '%*' -Verb RunAs -WorkingDirectory '%~dp0'"
    exit /b
)

if /i "%~1"=="disable" goto :do_disable
if /i "%~1"=="enable" goto :do_enable
if /i "%~1"=="status" goto :do_status

:menu
cls
echo ================================================
echo      Lock Screen Blur Toggle
echo      For Windows 10 1903+ and Windows 11
echo ================================================
echo.
echo   1. Disable blur - restore clear background
echo   2. Re-enable blur - Windows default
echo   3. Show current status
echo   0. Exit
echo.
set "choice="
set /p choice=Enter a choice and press Enter:
if "!choice!"=="" (
    set /a _empty+=1
    if !_empty! GEQ 10 exit /b
    goto :menu
)
set "_empty=0"
if "!choice!"=="1" goto :do_disable
if "!choice!"=="2" goto :do_enable
if "!choice!"=="3" goto :do_status
if "!choice!"=="0" exit /b
goto :menu

:do_disable
echo.
echo Disabling sign-in screen background blur...
set "_fail=0"
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\System" /v DisableAcrylicBackground /t REG_DWORD /d 1 /f
if errorlevel 1 set "_fail=1"
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\System" /v DisableAcrylicBackgroundOnLogon /t REG_DWORD /d 1 /f
if errorlevel 1 set "_fail=1"
if "!_fail!"=="1" (
    echo [FAILED] Could not write to the registry. Make sure you have admin rights.
    goto :end_pause
)
echo.
echo [DONE] Blur disabled - clear background restored.
echo Lock the screen with Win+L to see it; sign out or reboot if it does not apply.
echo Tip: if the sign-in screen shows a solid color instead of your picture,
echo open Settings, search "lock screen" and turn on
echo "Show lock screen background picture on the sign-in screen".
goto :end_pause

:do_enable
echo.
echo Restoring the default Windows blur effect...
set "_had=0"
reg query "HKLM\SOFTWARE\Policies\Microsoft\Windows\System" /v DisableAcrylicBackground >nul 2>nul
if not errorlevel 1 (
    reg delete "HKLM\SOFTWARE\Policies\Microsoft\Windows\System" /v DisableAcrylicBackground /f >nul
    set "_had=1"
)
reg query "HKLM\SOFTWARE\Policies\Microsoft\Windows\System" /v DisableAcrylicBackgroundOnLogon >nul 2>nul
if not errorlevel 1 (
    reg delete "HKLM\SOFTWARE\Policies\Microsoft\Windows\System" /v DisableAcrylicBackgroundOnLogon /f >nul
    set "_had=1"
)
if "!_had!"=="0" (
    echo Already at default, nothing to change.
    goto :end_pause
)
echo.
echo [DONE] Default restored - the sign-in screen will be blurred again.
goto :end_pause

:do_status
echo.
echo Reading current setting...
set "_found=0"
for %%V in (DisableAcrylicBackground DisableAcrylicBackgroundOnLogon) do (
    set "_val="
    for /f "tokens=3" %%a in ('reg query "HKLM\SOFTWARE\Policies\Microsoft\Windows\System" /v %%V 2^>nul ^| findstr /i "%%V"') do set "_val=%%a"
    if defined _val (
        set "_found=1"
        echo   %%V = !_val!
        if "!_val!"=="0x1" (
            echo     -- enabled: blur is disabled
        )
    )
)
if "!_found!"=="0" (
    echo   No policy set - Windows default: blur enabled
)
echo.
pause
goto :menu

:end_pause
echo.
pause
exit /b