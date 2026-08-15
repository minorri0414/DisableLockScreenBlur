# DisableLockScreenBlur

Remove the acrylic blur effect on the Windows 10/11 sign-in screen and restore a clear, sharp background — just like the good old days.

移除 Windows 10/11 登录屏幕上的亚克力模糊效果，恢复以前那种清晰锐利的背景。

## 功能特点 / Features

- 🖥️ **中英双语脚本** — 提供中文版（GBK 编码）和英文版两个脚本 / Chinese (GBK) and English versions
- 🎯 **一键切换** — 菜单式操作：禁用模糊 / 恢复默认 / 查看状态 / Menu-driven: disable blur, restore default, check status
- 🔧 **命令行支持** — 支持 `disable` / `enable` / `status` 参数直接执行 / Direct CLI args
- 🔐 **自动提权** — 自动请求管理员权限（UAC）/ Auto UAC elevation
- 🔄 **完全可逆** — 恢复功能一键还原 Windows 默认效果 / Fully reversible
- 🏥 **兼容新旧值名** — 同时管理官方 `DisableAcrylicBackground` 与旧版 `DisableAcrylicBackgroundOnLogon` / Handles both registry value names for maximum compatibility

## 工作原理 / How it works

该工具通过修改组策略对应的注册表值来关闭登录界面的亚克力模糊，等价于组策略中的 **"显示清晰的登录屏幕背景"**，不修改任何系统文件，安全可逆。

It disables the sign-in screen acrylic blur by writing the same registry values used by the group policy **"Show clear logon screen background"**. No system files are touched — it's safe and reversible.

```
HKLM\SOFTWARE\Policies\Microsoft\Windows\System
    DisableAcrylicBackground         = 1  (REG_DWORD)
    DisableAcrylicBackgroundOnLogon  = 1  (REG_DWORD)
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
3. 查看当前状态                     / Show current status
0. 退出                            / Exit
```

> ⚠️ 首次运行会弹出 UAC 提权提示，请点击 **"是" / Yes**。
> ⚠️ A UAC prompt will appear on first run — click **Yes**.

### 方式二：命令行参数 / CLI arguments

```bat
禁用锁屏背景模糊.cmd disable    :: 禁用模糊 / disable blur
禁用锁屏背景模糊.cmd enable     :: 恢复默认 / restore default
禁用锁屏背景模糊.cmd status     :: 查看状态 / show status
```

```bat
Disable-LockScreen-Blur.cmd disable
Disable-LockScreen-Blur.cmd enable
Disable-LockScreen-Blur.cmd status
```

## 生效方式 / When does it take effect

- 一般 **Win+L 锁屏**即可看到效果；若未生效，注销或重启一次 / Usually effective right after locking with **Win+L**; sign out or reboot if not
- 若登录界面只显示纯色而没显示图片，请在 **设置 → 个性化 → 登录屏幕** 中开启"在登录屏幕上显示锁屏背景图片" / If the sign-in screen shows a solid color only, enable **"Show lock screen background picture on the sign-in screen"** under Settings → Personalization → Sign-in screen

## 系统要求 / Requirements

- Windows 10 1903+ / Windows 11（含 Insider 版本 / including Insider builds）
- 管理员权限 / Administrator rights (auto-elevated)

## License

[MIT](LICENSE)

Copyright (c) 2026 AngesDitgialIO
