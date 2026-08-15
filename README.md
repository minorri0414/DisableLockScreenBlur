# DisableLockScreenBlur

Remove the acrylic blur effect on the Windows 10/11 sign-in screen and restore a clear, sharp background — just like the good old days.

移除 Windows 10/11 登录屏幕上的亚克力模糊效果，恢复以前那种清晰锐利的背景。

## 功能特点 / Features

- 🖥️ **中英双语脚本** — 提供中文版（GBK 编码）和英文版两个脚本 / Chinese (GBK) and English versions
- 🎯 **一键切换** — 菜单式操作：禁用模糊 / 恢复默认 / 自定义背景色 / 查看状态 / Menu-driven: disable blur, restore default, customize background color, check status
- 🎨 **自定义界面背景色** — 修改登录/关机界面背景色（含预设色 + 自定义 RGB）/ Custom sign-in/shutdown background color (presets + custom RGB)
- 🔧 **命令行支持** — 支持 `disable` / `enable` / `color` / `resetcolor` / `status` 参数直接执行 / Direct CLI args
- 🔐 **自动提权** — 自动请求管理员权限（UAC）/ Auto UAC elevation
- 🔄 **完全可逆** — 恢复功能一键还原 Windows 默认效果 / Fully reversible
- 🏥 **兼容新旧值名** — 同时管理官方 `DisableAcrylicBackground` 与旧版 `DisableAcrylicBackgroundOnLogon` / Handles both registry value names for maximum compatibility

## 工作原理 / How it works

该工具通过修改组策略对应的注册表值来关闭登录界面的亚克力模糊，等价于组策略中的 **"显示清晰的登录屏幕背景"**，不修改任何系统文件，安全可逆。同时可通过微软官方的 OEM 接口 `OverrideColor` 自定义登录/关机界面背景色。

It disables the sign-in screen acrylic blur by writing the same registry values used by the group policy **"Show clear logon screen background"**, and customizes the sign-in/shutdown background color via the official `OverrideColor` registry key. No system files are touched — it's safe and reversible.

```
HKLM\SOFTWARE\Policies\Microsoft\Windows\System
    DisableAcrylicBackground         = 1  (REG_DWORD)
    DisableAcrylicBackgroundOnLogon  = 1  (REG_DWORD)

HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Authentication\LogonUI\OverrideColor
    BackgroundColorInbbggrr          = 0xffcc6600  (REG_DWORD, 格式: 0xFF+BBGGRR)
    ForegroundColorInbbggrr          = 0xffffffff  (REG_DWORD)
```

## 使用方法 / Usage

### 方式一：双击运行 / Double-click to run

| 文件 / File | 说明 / Description |
|---|---|
| `禁用锁屏背景模糊.cmd` | 中文版 Chinese version |
| `Disable-LockScreen-Blur.cmd` | English version |

双击后菜单：

```
1. 禁用模糊 - 恢复以前的清晰背景     / Disable blur - restore clear background
2. 恢复模糊 - Windows 默认效果       / Re-enable blur - Windows default
3. 自定义登录/关机界面背景色         / Custom sign-in/shutdown background color
4. 恢复默认背景色                   / Restore default background color
5. 查看当前状态                     / Show current status
0. 退出                            / Exit
```

背景色预设（选项 3 内）：黑色 / 深蓝（Win10 经典）/ 深灰 / 深紫 / 粉紫（MMJ 风格），也支持自定义 6 位十六进制 RGB 色值。

> ⚠️ 首次运行会弹出 UAC 提权提示，请点击 **"是" / Yes**。
> ⚠️ A UAC prompt will appear on first run — click **Yes**.
>
> 📜 **首次下载请先阅读并同意 [EULA（使用须知）](EULA.md)** / First-time downloaders: please read and agree to the [EULA](EULA.md) first.

### 方式二：命令行参数 / CLI arguments

```bat
禁用锁屏背景模糊.cmd disable      :: 禁用模糊 / disable blur
禁用锁屏背景模糊.cmd enable       :: 恢复默认 / restore default
禁用锁屏背景模糊.cmd color        :: 进入背景色选择 / open color picker
禁用锁屏背景模糊.cmd resetcolor   :: 恢复默认背景色 / restore default color
禁用锁屏背景模糊.cmd status       :: 查看状态 / show status
```

```bat
Disable-LockScreen-Blur.cmd disable
Disable-LockScreen-Blur.cmd enable
Disable-LockScreen-Blur.cmd color
Disable-LockScreen-Blur.cmd resetcolor
Disable-LockScreen-Blur.cmd status
```

## 生效方式 / When does it take effect

- 一般 **Win+L 锁屏**即可看到效果；若未生效，注销或重启一次 / Usually effective right after locking with **Win+L**; sign out or reboot if not
- 若登录界面只显示纯色而没显示图片，请在 **设置 → 个性化 → 登录屏幕** 中开启"在登录屏幕上显示锁屏背景图片" / If the sign-in screen shows a solid color only, enable **"Show lock screen background picture on the sign-in screen"** under Settings → Personalization → Sign-in screen

## 系统要求 / Requirements

- **Windows 10 19H1**：最低需为 `18237.1000.rs_prerelease.180907-1621` (Insider Preview)
- **Windows 11**：内核版本号需高于 `10.0.19483.1000.rs_wdatp.190913-1542`
- 管理员权限 / Administrator rights (auto-elevated)

> **Windows 10 19H1** requires at least build `18237.1000.rs_prerelease.180907-1621` (Insider Preview)
> **Windows 11** requires a kernel build higher than `10.0.19483.1000.rs_wdatp.190913-1542`

## 制作信息 / Credits

| 角色 / Role | 提供方 / Provider |
|---|---|
| 🤖 模型 API | **DeepSeek（深度求索）** |
| 🧩 Agent | **Hermes** |
| 👤 核心开发 | **minorri（爱丽）** |

本工具由 **DeepSeek V4-Flash**（deepseek-v4-flash 模型）协助开发制作，经人工验证后发布。

This tool was developed with the assistance of **DeepSeek V4-Flash** (deepseek-v4-flash model) and manually verified before release.

## License

[MIT](LICENSE)

Copyright (c) 2026 minorri0414
