@echo off
setlocal EnableExtensions EnableDelayedExpansion
title Lock Screen Blur Toggle

REM ====================================================
REM  Disable/restore the Windows 10-11 sign-in screen
REM  background blur effect, and customize the
REM  sign-in/shutdown screen background color.
REM  Double-click for the menu, or pass an argument:
REM    disable     Disable blur, restore clear background
REM    enable      Restore the Windows default blur
REM    color       Open the background color picker
REM    resetcolor  Restore the default background color
REM    status      Show current state
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
if /i "%~1"=="color" goto :do_color
if /i "%~1"=="resetcolor" goto :do_resetcolor
if /i "%~1"=="status" goto :do_status

:menu
cls
echo ================================================
echo      Lock Screen Blur Toggle
echo      For Windows 10 19H1+ and Windows 11
echo ================================================
echo.
echo   1. Disable blur - restore clear background
echo   2. Re-enable blur - Windows default
echo   3. Custom sign-in/shutdown background color
echo   4. Restore default background color
echo   5. Show current status
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
if "!choice!"=="3" goto :do_color
if "!choice!"=="4" goto :do_resetcolor
if "!choice!"=="5" goto :do_status
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

:do_color
cls
echo ================================================
echo      Choose the sign-in/shutdown screen color
echo      Applies to both the sign-in and shutdown UI
echo ================================================
echo.
echo   1. Black 000000
echo   2. Deep blue 0066CC - classic Win10
echo   3. Dark gray 333333
echo   4. Deep purple 522850
echo   5. Pink-purple A05094
echo   6. Custom RGB value
echo   0. Back to main menu
echo.
set "choice="
set /p choice=Enter a choice and press Enter:
if "!choice!"=="1" set "_bgr=000000"
if "!choice!"=="2" set "_bgr=cc6600"
if "!choice!"=="3" set "_bgr=333333"
if "!choice!"=="4" set "_bgr=502852"
if "!choice!"=="5" set "_bgr=9450a0"
if "!choice!"=="6" goto :color_custom
if "!choice!"=="0" goto :menu
if not defined _bgr goto :do_color
call :apply_bgr
goto :end_pause

:color_custom
echo.
set "_rgb="
set /p _rgb=Enter a 6-digit hex RGB value, e.g. 0066CC:
if "!_rgb!"=="" goto :do_color
set "_ok="
echo !_rgb!| findstr /r "^[0-9a-fA-F][0-9a-fA-F][0-9a-fA-F][0-9a-fA-F][0-9a-fA-F][0-9a-fA-F]$" >nul
if not errorlevel 1 set "_ok=1"
if not "!_ok!"=="1" (
    echo Invalid input. Enter a 6-digit hex value.
    goto :color_custom
)
powershell -NoProfile -Command "$c=0x%_rgb%;$r=$c -band 0xFF;$g=$c -band 0xFF00;$b=$c -band 0xFF0000;$r=$r -shl 16;$b=$b -shr 16;$v=$r -bor $g -bor $b;$h='{0:X6}' -f $v;reg add 'HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Authentication\LogonUI\OverrideColor' /v BackgroundColorInbbggrr /t REG_DWORD /d 0xff$h /f"
if errorlevel 1 (
    echo [FAILED] Could not set the background color. Make sure you have admin rights.
    goto :end_pause
)
echo.
echo [DONE] Background color set to RGB=!_rgb!
echo Lock the screen with Win+L or shut down to see the effect.
goto :end_pause

:apply_bgr
echo.
echo Setting the sign-in/shutdown background color...
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Authentication\LogonUI\OverrideColor" /v BackgroundColorInbbggrr /t REG_DWORD /d 0xff%_bgr% /f
if errorlevel 1 (
    echo [FAILED] Could not set the background color. Make sure you have admin rights.
    goto :end_pause
)
echo.
echo [DONE] Background color set. Lock with Win+L or shut down to see it.
goto :end_pause

:do_resetcolor
echo.
echo Restoring the default background color...
reg query "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Authentication\LogonUI\OverrideColor" /v BackgroundColorInbbggrr >nul 2>nul
if errorlevel 1 (
    echo Already at default, nothing to change.
    goto :end_pause
)
reg delete "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Authentication\LogonUI\OverrideColor" /v BackgroundColorInbbggrr /f >nul
if errorlevel 1 (
    echo [FAILED] Could not restore. Make sure you have admin rights.
    goto :end_pause
)
echo.
echo [DONE] Default background color restored.
goto :end_pause

:do_status
echo.
echo Reading current setting...
echo --- Blur effect ---
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
echo --- Background color ---
set "_bg="
for /f "tokens=3" %%a in ('reg query "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Authentication\LogonUI\OverrideColor" /v BackgroundColorInbbggrr 2^>nul ^| findstr /i "BackgroundColorInbbggrr"') do set "_bg=%%a"
if defined _bg (
    echo   BackgroundColorInbbggrr = !_bg!
    echo   -- custom color is set
) else (
    echo   Not set - using the system default color
)
echo.
pause
goto :menu

:end_pause
echo.
pause
exit /b