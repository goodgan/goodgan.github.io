---
title: 通过 ZeroTier/Tailscale 使用 VS Code Remote SSH 连接内网电脑
date: 2025-08-23 10:00:00
categories: 技术分享
tags:
  - 技术
  - 开发工具
  - VS Code
  - 远程开发
  - SSH
  - ZeroTier
  - Tailscale
  - 内网穿透
cover_picture: /images/remote-ssh.jpg
---

# 通过 ZeroTier/Tailscale 使用 VS Code Remote SSH 连接内网电脑

> 本指南详细介绍了如何在两台内网电脑之间建立一个虚拟局域网 (Virtual LAN)，并通过 VS Code 的 Remote SSH 插件进行远程代码开发。适用于跨地域远程开发、内网设备互联等场景。

<!-- more -->

## 一、应用场景与优势

### 1. 适用场景

本教程特别适用于以下场景：

- **跨地域开发**：两台电脑位于不同的物理位置（例如，一台在家，一台在办公室）
- **内网互联**：两台电脑在同一个内网，但由于路由器或网络配置问题无法直接通过内网 IP 互访
- **远程办公**：需要访问公司内网的开发机器进行远程开发
- **多设备协作**：在不同设备间建立安全的开发环境连接

### 2. 技术优势

- **零配置**：无需复杂的端口转发和路由器配置
- **安全加密**：所有通信都经过端到端加密
- **P2P优先**：优先建立点对点连接，减少延迟
- **跨平台支持**：支持 Windows、macOS、Linux 等多种操作系统

## 二、核心工具概述

### 1. 虚拟局域网工具 (ZeroTier / Tailscale)

这些是 SaaS (软件即服务) 解决方案，提供全球分布的服务器网络来帮助你的设备建立安全的 P2P (点对点) 连接。它们让你的设备获得虚拟 IP，并像在一个物理局域网中一样进行通信，无需复杂的端口转发配置。

#### 主要特点

- **简单易用**：零配置，自动建立连接
- **P2P 优先**：优先建立点对点连接，减少延迟
- **安全加密**：端到端加密保护数据安全
- **跨平台**：支持多种操作系统

#### 官方网站

- **ZeroTier**: [https://www.zerotier.com/](https://www.zerotier.com/)
- **Tailscale**: [https://tailscale.com/](https://tailscale.com/)

#### 费用说明

对于个人和小型团队，两者都提供慷慨的免费计划，足够日常开发使用。

### 2. OpenSSH Server (目标开发机)

提供安全的 Shell 访问，是 VS Code Remote SSH 的基础。Windows 10/11 内置此功能。

### 3. VS Code Remote SSH 插件 (客户端)

允许你连接到远程服务器，并在其上打开任何文件夹，就像在本地一样进行编辑和开发。

## 三、实施步骤概览

1. **配置虚拟局域网** (ZeroTier 或 Tailscale) - 在所有需要互联的电脑上
2. **配置目标开发机** (作为 SSH 服务器) - 你希望远程连接的那台电脑
3. **配置客户端 VS Code** (Remote SSH) - 你用来进行开发的电脑

---

## 四、配置虚拟局域网 (以 ZeroTier 为例)

这里以 ZeroTier 为例，Tailscale 的步骤类似，都非常简单直观。

### 1. 注册账号并创建网络

#### 创建 ZeroTier 网络

1. **访问官网**
   - 打开 [ZeroTier 官网](https://www.zerotier.com/)
   - 点击 `Sign Up` 注册账号

2. **创建虚拟网络**
   - 登录后，点击 `Create A Network` 创建新的虚拟网络
   - 系统会生成一个 16 位的 `Network ID`（例如：`xxxxxxxxxxxxxxxx`）
   - **重要**：请记录这个 Network ID，后续所有设备都需要使用

### 2. 安装客户端软件

#### 下载安装包

1. **访问下载页面**
   - 打开 [ZeroTier 下载页面](https://www.zerotier.com/download/)

2. **选择对应系统**
   - **Windows**: 下载 `.msi` 安装包
   - **macOS**: 下载 `.pkg` 安装包
   - **Linux**: 使用包管理器或下载 `.deb`/`.rpm` 包

3. **安装客户端**
   - 运行安装包，按提示完成安装
   - 安装完成后，ZeroTier 会自动启动

### 3. 加入虚拟网络

#### Windows 系统

1. **找到系统托盘图标**
   - 在系统托盘中找到 ZeroTier 图标

2. **加入网络**
   - 右键点击 ZeroTier 图标
   - 选择 `Join New Network...`
   - 输入之前记录的 `Network ID`
   - 点击 `Join` 加入网络

#### Linux/macOS 系统

```bash
# 使用命令行加入网络
sudo zerotier-cli join <Your_Network_ID>

# 查看网络状态
sudo zerotier-cli listnetworks
```

### 4. 授权设备连接

#### 在管理界面授权

1. **返回 ZeroTier 管理界面**
   - 登录 ZeroTier 官网，进入网络管理页面

2. **查看成员列表**
   - 在 `Members` (成员) 部分，查看刚加入的设备
   - 新设备状态通常显示为 `Unauthorized` (未授权)

3. **授权设备**
   - 勾选每个设备旁边的 `Auth` (授权) 复选框
   - 授权后，设备将获得虚拟 IP 地址（例如：`192.168.192.x`）
   - **记录目标开发机的虚拟 IP 地址**，后续 SSH 连接需要使用

### 5. 验证网络连接

#### 测试连通性

```bash
# 在任一设备上测试连接
ping <对方设备的ZeroTier虚拟IP>

# 示例
ping 192.168.192.123
```

如果能收到回复，说明虚拟局域网已成功建立。

---

## 五、配置目标开发机 (Windows SSH 服务器)

这台是你希望通过 VS Code 远程连接上去进行代码修改的电脑。

### 1. 安装 OpenSSH 服务器

#### 通过 Windows 设置安装

**适用于 Windows 10/11 或 Windows Server 2019+**

1. **打开系统设置**
   - 按 `Win + I` 打开设置
   - 导航到 `应用` → `应用和功能`

2. **添加可选功能**
   - 点击 `可选功能`
   - 点击 `添加可选功能`
   - 搜索并选择 `OpenSSH 服务器`
   - 点击 `安装`

#### 启动和配置服务

1. **打开服务管理器**
   - 按 `Win + R`，输入 `services.msc`，按回车

2. **配置 SSH 服务**
   - 找到 `OpenSSH SSH Server` 服务
   - 右键选择 `属性`
   - 将 `启动类型` 设置为 `自动`
   - 点击 `启动` 按钮启动服务

3. **配置认证代理**
   - 同样找到 `OpenSSH Authentication Agent` 服务
   - 设置为 `自动` 启动类型
   - 启动该服务

#### 验证安装

```powershell
# 检查服务状态
Get-Service sshd

# 检查端口监听
netstat -an | findstr :22
```

### 2. 配置 Windows 防火墙

需要允许 SSH 默认端口 `22` 的入站连接。

#### 图形界面配置

1. **打开防火墙设置**
   - 搜索并打开 `Windows Defender 防火墙`
   - 点击 `高级设置`

2. **创建入站规则**
   - 在左侧选择 `入站规则`
   - 点击右侧的 `新建规则...`

3. **配置规则**
   - 选择 `端口` → 下一步
   - 选择 `TCP`，在 `特定本地端口` 中输入 `22` → 下一步
   - 选择 `允许连接` → 下一步
   - 选择网络类型（至少勾选 `专用`，因为 ZeroTier/Tailscale 创建专用网络）→ 下一步
   - 输入规则名称（例如 `SSH_Inbound_ZT`）→ 完成

#### PowerShell 命令配置

```powershell
# 创建防火墙规则
New-NetFirewallRule -DisplayName "SSH Server" -Direction Inbound -Protocol TCP -LocalPort 22 -Action Allow

# 查看规则
Get-NetFirewallRule -DisplayName "SSH Server"
```

### 3. 获取用户信息

#### 查看当前用户名

```powershell
# 查看完整用户信息
whoami

# 仅显示用户名
$env:USERNAME
```

输出示例：`DESKTOP-XXXXX\yourusername`，其中 `yourusername` 就是 SSH 连接时需要的用户名。

### 4. 设置 SSH 密钥认证（推荐）

相比密码认证，SSH 密钥更安全、更方便。

#### 生成 SSH 密钥对

1. **在目标 Windows 电脑上操作**
   ```powershell
   # 打开 PowerShell
   # 生成 SSH 密钥对
   ssh-keygen -t ed25519 -C "your-email@example.com"

   # 或使用 RSA 算法
   ssh-keygen -t rsa -b 4096 -C "your-email@example.com"
   ```

2. **设置密钥路径**
   - 默认路径：`C:\Users\YourUser\.ssh\id_ed25519`
   - 可以设置密码保护私钥（可选）

#### 配置公钥认证

1. **创建 authorized_keys 文件**
   ```powershell
   # 确保 .ssh 目录存在
   New-Item -ItemType Directory -Path "$env:USERPROFILE\.ssh" -Force

   # 将公钥内容添加到 authorized_keys
   Get-Content "$env:USERPROFILE\.ssh\id_ed25519.pub" | Add-Content "$env:USERPROFILE\.ssh\authorized_keys"
   ```

2. **设置文件权限**
   ```powershell
   # 设置 .ssh 目录权限
   icacls "$env:USERPROFILE\.ssh" /inheritance:r
   icacls "$env:USERPROFILE\.ssh" /grant:r "$env:USERNAME:(F)"

   # 设置 authorized_keys 文件权限
   icacls "$env:USERPROFILE\.ssh\authorized_keys" /inheritance:r
   icacls "$env:USERPROFILE\.ssh\authorized_keys" /grant:r "$env:USERNAME:(R)"
   ```

#### 测试 SSH 连接

```powershell
# 本地测试 SSH 连接
ssh localhost

# 测试密钥认证
ssh -i "$env:USERPROFILE\.ssh\id_ed25519" localhost
```

---

## 六、配置客户端 VS Code (Remote SSH)

这台是你用来进行远程开发的电脑。

### 1. 安装 Remote SSH 扩展

#### 安装必要扩展

1. **打开 VS Code**
   - 启动 Visual Studio Code

2. **进入扩展市场**
   - 点击左侧活动栏的 `扩展` 图标（四个方块）
   - 或使用快捷键 `Ctrl + Shift + X`

3. **搜索并安装**
   - 在搜索框中输入 `Remote - SSH`
   - 找到 Microsoft 发布的 `Remote - SSH` 扩展
   - 点击 `安装`

#### 推荐相关扩展

```
Remote - SSH                    # 核心扩展
Remote - SSH: Editing Configuration Files  # SSH 配置编辑
Remote Explorer                 # 远程资源管理器
```

### 2. 配置 SSH 连接

#### 打开 SSH 配置文件

1. **通过命令面板**
   - 按 `F1` 或 `Ctrl + Shift + P` 打开命令面板
   - 输入 `Remote-SSH: Open SSH Configuration File...`
   - 选择用户配置文件（通常是 `C:\Users\YourUser\.ssh\config`）

2. **手动创建配置文件**
   ```bash
   # 文件位置
   Windows: C:\Users\YourName\.ssh\config
   macOS/Linux: ~/.ssh/config
   ```

#### SSH 配置示例

```bash
# ~/.ssh/config

# Windows 开发服务器配置
Host my_remote_dev_win
    HostName 192.168.192.123      # ZeroTier/Tailscale 分配的虚拟IP
    User yourusername             # 目标Windows电脑的用户名
    Port 22                       # SSH端口
    IdentityFile ~/.ssh/id_ed25519  # 私钥文件路径（如果使用密钥认证）
    ForwardAgent yes              # 启用SSH代理转发
    ServerAliveInterval 60        # 保持连接活跃
    ServerAliveCountMax 3         # 最大重试次数

# 使用密码认证的配置示例
Host my_remote_dev_password
    HostName 192.168.192.124
    User developer
    Port 22
    PreferredAuthentications password
    PubkeyAuthentication no
```

#### 密钥文件配置

如果使用 SSH 密钥认证：

1. **复制私钥文件**
   - 将目标电脑的私钥文件复制到客户端电脑
   - 路径：`~/.ssh/id_ed25519`（或自定义名称）

2. **设置文件权限**
   ```bash
   # Windows (PowerShell)
   icacls "$env:USERPROFILE\.ssh\id_ed25519" /inheritance:r
   icacls "$env:USERPROFILE\.ssh\id_ed25519" /grant:r "$env:USERNAME:(R)"

   # Linux/macOS
   chmod 600 ~/.ssh/id_ed25519
   ```

### 3. 建立远程连接

#### 方法一：通过命令面板

1. **打开命令面板**
   - 按 `Ctrl + Shift + P`

2. **连接到主机**
   - 输入 `Remote-SSH: Connect to Host`
   - 选择配置的主机名称（如 `my_remote_dev_win`）

3. **选择平台**
   - 首次连接会询问远程平台类型
   - 选择 `Windows`

#### 方法二：通过远程资源管理器

1. **打开远程资源管理器**
   - 点击左侧活动栏的 `远程资源管理器` 图标

2. **连接到主机**
   - 在 `SSH TARGETS` 下找到配置的主机
   - 点击主机名旁的 `连接` 图标
   - 选择在当前窗口或新窗口中连接

#### 连接验证

1. **确认连接**
   - 首次连接可能需要确认服务器指纹
   - 输入 `yes` 确认

2. **身份验证**
   - 密码认证：输入目标电脑的用户密码
   - 密钥认证：自动使用配置的私钥文件

3. **验证成功**
   - VS Code 状态栏左下角显示 `SSH: my_remote_dev_win`
   - 文件资源管理器显示远程文件系统
   - 终端连接到远程系统

---

## 七、常见问题与故障排除

### 1. 网络连接问题

#### ZeroTier/Tailscale 客户端状态

```bash
# 检查 ZeroTier 状态
zerotier-cli info
zerotier-cli listnetworks

# 检查网络连通性
ping <目标设备的虚拟IP>
```

**解决方案：**
- 确保两台电脑的客户端都在运行
- 检查设备是否已在管理界面授权
- 重启 ZeroTier/Tailscale 客户端

#### 网络连接检查

- **互联网连接**：确保两台电脑都能正常访问互联网
- **防火墙设置**：检查目标电脑防火墙是否开放 SSH 端口
- **路由配置**：确认虚拟网络路由配置正确

### 2. SSH 连接问题

#### 连接被拒绝

```bash
# 检查 SSH 服务状态
Get-Service sshd

# 检查端口监听
netstat -an | findstr :22

# 测试连接
ssh -v username@virtual-ip
```

**解决方案：**
- 确认 SSH 服务正在运行
- 检查防火墙规则
- 验证端口配置

#### 认证失败

```bash
# 详细调试信息
ssh -vvv username@virtual-ip

# 检查密钥权限
ls -la ~/.ssh/
```

**解决方案：**
- 验证用户名和密码
- 检查 SSH 密钥文件权限
- 确认 authorized_keys 文件配置

### 3. VS Code 连接问题

#### 扩展安装失败

**解决方案：**
- 检查网络连接
- 重启 VS Code
- 手动下载并安装扩展

#### 远程服务器组件安装失败

**解决方案：**
- 确保目标电脑有足够磁盘空间
- 检查防病毒软件是否阻止
- 尝试手动安装 VS Code Server

### 4. 性能优化

#### 连接速度慢

```bash
# SSH 配置优化
Host *
    Compression yes
    ServerAliveInterval 60
    ServerAliveCountMax 3
```

#### 文件同步延迟

```json
// VS Code 设置优化
{
    "files.autoSave": "afterDelay",
    "files.autoSaveDelay": 1000,
    "remote.SSH.showLoginTerminal": false
}
```

### 5. 日志分析

#### VS Code 输出日志

1. **查看连接日志**
   - 打开 VS Code
   - 选择 `Terminal` → `Output`
   - 选择 `Remote - SSH` 输出通道

#### Windows 事件日志

```powershell
# 查看 SSH 服务日志
Get-WinEvent -LogName "OpenSSH/Operational" -MaxEvents 20
```

#### 调试命令

```bash
# SSH 详细调试
ssh -vvv -o ConnectTimeout=10 username@virtual-ip

# 网络诊断
tracert virtual-ip
telnet virtual-ip 22
```

---

## 八、最佳实践与安全建议

### 1. 安全最佳实践

- **使用 SSH 密钥认证**：禁用密码认证，提高安全性
- **定期更新系统**：保持操作系统和软件为最新版本
- **限制网络访问**：仅允许必要的设备加入虚拟网络
- **监控连接日志**：定期检查 SSH 访问日志
- **使用强密码**：如果必须使用密码，确保密码复杂度

### 2. 性能优化建议

- **网络优化**：选择延迟较低的 ZeroTier/Tailscale 节点
- **SSH 配置**：启用连接复用和压缩
- **VS Code 设置**：优化文件监控和自动保存设置
- **硬件配置**：确保目标电脑有足够的计算资源

### 3. 开发环境管理

- **项目组织**：在远程电脑上创建专门的开发目录
- **版本控制**：合理使用 Git 进行代码管理
- **环境隔离**：为不同项目使用独立的开发环境
- **备份策略**：定期备份重要的开发数据

---

通过本教程，你应该能够成功地在内网电脑之间通过虚拟局域网和 Remote SSH 实现远程开发。这种方式结合了本地 IDE 的便利性和远程服务器的强大功能，是现代远程开发的理想解决方案。

如果在实施过程中遇到问题，可以参考故障排除部分或查阅相关官方文档。祝你远程开发愉快！
