---
title: Windows远程SSH多客户端连接指南
date: 2025-08-31 16:45:00
categories: 开发工具
tags:
  - SSH
  - VS Code
  - 远程开发
  - Windows
  - 多客户端
cover_picture: /images/remote-ssh.jpg
---

# Windows远程SSH多客户端连接指南

手动部署 VS Code Server 到 Windows 远程主机的方案完全适用于多客户端连接（包括 VS Code、Windsurf、Cursor 等编辑器），因为 Server 组件本质是一个独立的后台服务，支持同时接受多个 SSH 客户端的连接请求。以下是具体步骤和多客户端支持说明：

## 一、手动部署 VS Code Server 到远程 Windows 主机

### 1. 确定需要部署的 Server 版本

不同编辑器（VS Code、Windsurf、Cursor）可能依赖特定版本的 Server，需要与编辑器版本匹配：

- **获取 Commit ID**：打开编辑器，按 `Ctrl+Shift+P` 执行 About 命令，记录「Commit ID」（如 `6f1763612105`，这是 Server 版本的唯一标识）
- **版本统一**：所有需要连接的编辑器，建议统一使用相同版本的 Server（避免版本不兼容）

### 2. 下载对应版本的 VS Code Server

**方法一：使用最新稳定版（推荐）**

直接下载最新稳定版，兼容性最好：
```
https://update.code.visualstudio.com/latest/server-win32-x64/stable
```

**方法二：使用特定 Commit ID（如果需要版本匹配）**

如果需要特定版本，访问以下链接：
```
https://update.code.visualstudio.com/commit/${commit_id}/server-win32-x64/stable

```

**注意**：旧的 commit ID 可能已过期无法下载。如果遇到 404 错误，建议：
1. 使用最新版本（方法一）
2. 或者更新本地 VS Code 到最新版本，获取新的 commit ID

下载得到压缩包 `vscode-server-win32-x64.zip`（约 150MB）。

### 3. 将 Server 压缩包传到远程 Windows 主机

**方法一：使用 scp 命令**（本地终端执行）

```bash
# 格式：scp -P 端口 本地压缩包路径 远程用户名@远程IP:目标路径
scp -P 22 C:\Downloads\vscode-server-win32-x64.zip admin@192.168.1.100:C:\Users\admin\
```

**方法二：使用 WinSCP**

- 连接远程后，直接拖拽压缩包到远程的 `C:\Users\admin\` 目录

### 4. 远程 Windows 解压并部署 Server

登录远程 Windows 的 PowerShell（管理员模式），执行以下命令：

```powershell
# 进入用户目录
cd C:\Users\admin

# 创建 Server 存放目录（必须严格按照此路径，编辑器会默认读取）
mkdir -Force .vscode-server\bin\${commit_id}  # 替换 ${commit_id} 为实际版本号

# 解压 ZIP 文件到目标目录
Expand-Archive -Path vscode-server-win32-x64.zip -DestinationPath .vscode-server\bin\${commit_id}

# 验证目录结构（应看到 server.js、package.json 等文件）
ls .vscode-server\bin\${commit_id}
```

### 5. 配置 Server 权限（关键步骤）

确保远程 Windows 的 Administrators 组和当前用户对 Server 目录有完全控制权限：

```powershell
# 给当前用户添加权限
icacls "C:\Users\admin\.vscode-server" /grant "${env:USERNAME}:F" /T
```

**如果提示"拒绝访问"**，需在远程 Windows 图形界面操作：
1. 右键 `.vscode-server` 目录
2. 选择「属性」→「安全」→「编辑」
3. 添加当前用户并勾选"完全控制"

## 二、多客户端连接支持说明

### 1. 支持的客户端类型

手动部署的 VS Code Server 本质是一个基于 SSH 的后台服务，所有兼容 VS Code Remote-SSH 协议的编辑器都可连接，包括：

- **VS Code**：官方 Remote-SSH 插件
- **Windsurf**：内置 Remote-SSH 功能
- **Cursor**：支持 Remote-SSH 扩展
- **其他编辑器**：基于 VS Code 内核的编辑器（如 VSCodium）

### 2. 多客户端同时连接的原理

- **端口监听**：Server 启动后会监听本地端口（默认随机分配），每个客户端通过 SSH 连接到远程 Windows 后，会通过端口转发与 Server 通信
- **并发支持**：Server 支持并发连接，多个客户端可同时编辑远程文件、执行命令（类似 SSH 服务器支持多终端登录）

### 3. 多客户端连接步骤（以两个客户端为例）

**客户端 1：VS Code 连接**
1. 安装 Remote-SSH 插件
2. 按 `Ctrl+Shift+P` 执行 `Remote-SSH: Connect to Host`
3. 输入 `admin@192.168.1.100`，选择远程文件夹（如 `/c/Users/admin/project`）

**客户端 2：Windsurf 连接**
1. 打开 Windsurf，左下角点击「远程窗口」图标
2. 选择「Connect to Host」
3. 输入相同的远程信息 `admin@192.168.1.100`，连接后可打开同一项目

**验证并发**
- 在 VS Code 中修改 `test.py` 并保存，Windsurf 中会实时显示更新（需开启自动刷新）
- 两个客户端的终端均可独立执行远程命令（如 `python test.py`），互不干扰

## 三、常见问题与解决

### 1. 客户端提示 "Server 版本不匹配"

- **原因**：编辑器版本与部署的 Server 版本不一致
- **解决**：重新下载对应编辑器 Commit ID 的 Server 并替换部署

### 2. 多客户端连接后卡顿

- **原因**：远程 Windows 性能不足（如内存过低）或网络带宽有限
- **解决**：关闭远程不必要的进程，或限制同时连接的客户端数量（建议不超过 3-5 个）

### 3. 部分客户端无法执行命令

- **原因**：远程用户权限不足（如非管理员用户无法访问某些目录）
- **解决**：确保所有客户端使用同一远程用户登录，或给该用户分配足够权限

## 总结

手动部署的 VS Code Server 完全支持多客户端（VS Code、Windsurf、Cursor 等）同时连接，核心是确保：

1. **版本统一**：所有客户端使用相同版本的 Server（通过 Commit ID 匹配）
2. **权限正确**：远程 Windows 目录权限正确，允许读写 Server 文件和项目文件
3. **SSH 服务**：远程 SSH 服务正常运行（支持多会话连接）

按此方案操作，局域网内的多台设备可通过不同编辑器同时开发远程 Windows 上的项目，兼顾速度与安全性。