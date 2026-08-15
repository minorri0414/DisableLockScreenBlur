@echo off
chcp 936 >nul
setlocal EnableExtensions EnableDelayedExpansion
title 锁屏背景模糊切换工具

REM ====================================================
REM  禁用/恢复 Windows 10-11 登录屏幕背景模糊效果
REM  双击运行显示菜单; 也支持命令行参数:
REM    disable  直接禁用模糊, 恢复清晰背景
REM    enable   恢复 Windows 默认模糊效果
REM    status   查看当前状态
REM ====================================================

if /i "%~1"=="-check" (
    echo [PARSE-OK]
    exit /b 0
)

whoami /groups 2>nul | findstr "S-1-16-12288" >nul
if errorlevel 1 (
    echo [提示] 需要管理员权限, 正在请求提权, 请在 UAC 弹窗中点"是"...
    powershell -NoProfile -Command "Start-Process -FilePath '%~f0' -ArgumentList '%*' -Verb RunAs -WorkingDirectory '%~dp0'"
    exit /b
)

if /i "%~1"=="disable" goto :do_disable
if /i "%~1"=="enable" goto :do_enable
if /i "%~1"=="status" goto :do_status

:menu
cls
echo ================================================
echo      锁屏背景模糊效果切换工具
echo      适用于 Windows 10 1903+ 和 Windows 11
echo ================================================
echo.
echo   1. 禁用模糊 - 恢复以前的清晰背景
echo   2. 恢复模糊 - Windows 默认效果
echo   3. 查看当前状态
echo   0. 退出
echo.
set "choice="
set /p choice=请输入选项后回车:
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
echo 正在禁用登录屏幕背景模糊...
set "_fail=0"
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\System" /v DisableAcrylicBackground /t REG_DWORD /d 1 /f
if errorlevel 1 set "_fail=1"
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\System" /v DisableAcrylicBackgroundOnLogon /t REG_DWORD /d 1 /f
if errorlevel 1 set "_fail=1"
if "!_fail!"=="1" (
    echo [失败] 注册表写入失败, 请确认已授予管理员权限。
    goto :end_pause
)
echo.
echo [完成] 已禁用背景模糊, 登录屏幕恢复清晰背景。
echo 一般锁屏 Win+L 即可看到效果, 若未生效请注销或重启一次。
echo 提示: 若登录界面只有纯色而没有图片, 请打开系统设置,
echo 搜索"登录屏幕", 开启"在登录屏幕上显示锁屏背景图片"。
goto :end_pause

:do_enable
echo.
echo 正在恢复 Windows 默认的模糊效果...
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
    echo 当前已是默认状态, 无需修改。
    goto :end_pause
)
echo.
echo [完成] 已恢复默认, 登录屏幕将重新使用模糊背景。
goto :end_pause

:do_status
echo.
echo 正在读取当前设置...
set "_found=0"
for %%V in (DisableAcrylicBackground DisableAcrylicBackgroundOnLogon) do (
    set "_val="
    for /f "tokens=3" %%a in ('reg query "HKLM\SOFTWARE\Policies\Microsoft\Windows\System" /v %%V 2^>nul ^| findstr /i "%%V"') do set "_val=%%a"
    if defined _val (
        set "_found=1"
        echo   %%V = !_val!
        if "!_val!"=="0x1" (
            echo     -- 该项已启用: 模糊已禁用
        )
    )
)
if "!_found!"=="0" (
    echo   未设置任何相关策略, 当前为 Windows 默认: 模糊启用
)
echo.
pause
goto :menu

:end_pause
echo.
pause
exit /b