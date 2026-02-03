---
title: 无需代理安装配置 Claude Code + MiniMax M2.1 API教程
date: 2026-02-03 12:00:00
categories: 开发工具
tags:
  - Claude Code
  - AI编程
  - MiniMax M2.1
  - MCP
  - 开发工具
cover_picture: https://images.unsplash.com/photo-1555949963-aa79dcee981c?w=800&q=80
---

# 国内安装配置 Claude Code + MiniMax M2.1 API教程

本教程严格对照 **Claude Code 官方文档**、**MiniMax 官方文档**、**CC Switch 官方文档**编写，适配 Windows/macOS/Linux 全系统，全程国内网络可完成，无需任何代理。

教程涵盖核心内容：环境依赖准备 → Claude Code 国内镜像安装 → CC Switch 安装与 MiniMax API 配置 → MCP（图片识别+文件搜索）安装配置 → 验证与故障排查，附带所有官方教程链接，确保每一步都符合官方规范，解决国内用户安装配置中的环境、兼容问题。

# 一、前置准备（必看，解决环境依赖问题）

此前教程未详细说明环境依赖，导致部分用户安装失败，以下是官方要求的完整环境清单，需提前配置完成（国内网络可直接安装）。

## 1.1 系统要求（官方标准）

|操作系统|最低版本要求|额外说明|
|---|---|---|
|Windows|Windows 10+（x64 架构）|需启用开发者模式（解决长路径问题），使用 PowerShell 或 CMD（管理员权限）|
|macOS|macOS 10.15+（Catalina，Intel/Apple Silicon 架构）|需安装 Xcode 命令行工具（解决依赖编译问题）|
|Linux|Ubuntu 20.04+/Debian 11+/Fedora 34+（x64 架构）|需具备 root 权限，提前安装 apt/yum 依赖工具|
## 1.2 核心依赖安装（官方必需，国内可直装）

所有依赖均通过国内镜像安装，避免海外源卡顿、连接失败，按系统执行对应命令。

### （1）Node.js 18.0.0+（LTS 版，Claude Code 官方依赖）

用于 npm 包管理，安装 Claude Code 必需，国内镜像下载安装：

- **Windows/macOS**：直接下载国内镜像包（无需代理）
下载地址：https://nodejs.org/zh-cn/download/ （选择 LTS 版，国内自动跳转镜像节点），双击安装，勾选"Add to PATH"，安装完成后验证。

- **Linux（Ubuntu/Debian）**：
        `# 安装依赖
sudo apt update && sudo apt install -y curl
# 国内镜像安装 Node.js 18 LTS
curl -fsSL https://npmmirror.com/mirrors/node/v18.19.0/node-v18.19.0-linux-x64.tar.xz | sudo tar -xJ -C /usr/local --strip-components=1
`

- **验证安装**：打开终端/CMD，执行以下命令，输出版本号即成功（无需代理）
        `node -v  # 需输出 v18.0.0+
npm -v   # 需输出 9.0.0+
`

### （2）MiniMax 账号与 Coding Plan API 密钥（关键，必做）

所有功能（Claude Code 调用、MCP 功能）均依赖 MiniMax Coding Plan 密钥，普通对话密钥无效，按官方步骤获取：

1. 访问 MiniMax 国内开放平台（国内直连）：https://platform.minimaxi.com/ ，完成注册/登录；

2. 登录后，进入「控制台」→「API 密钥」→「创建新密钥」，**必须选择"Coding Plan"**（仅该类型密钥支持编码、MCP 功能）；

3. 密钥创建成功后，立即复制保存（仅显示一次，泄露会导致财产损失）；

4. 可选：进入「控制台」→「套餐管理」，确认 Coding Plan 套餐有效（免费额度可满足日常使用，超出后按需续费）。

# 二、国内镜像安装 Claude Code（官方步骤，免代理）

严格对照 Claude Code 官方安装文档，结合国内网络优化，使用阿里 npm 镜像，避免官方海外源连接失败，提供 3 种安装方式，按需选择（推荐方式 1，最快最稳）。

## 2.1 方式 1：npm 阿里镜像安装（推荐，国内秒装，不污染全局源）

临时指定阿里镜像安装，不修改全局 npm 源，适合偶尔使用 Claude Code 的用户：

```bash
# 全系统通用命令（Windows 用 PowerShell/CMD，macOS/Linux 用终端）
npm install -g @anthropic-ai/claude-code --registry=https://registry.npmmirror.com
# 验证安装成功（无需代理）
claude --version  # 输出版本号即成功（如 v1.0.0+）
```

## 2.2 方式 2：全局切换阿里镜像安装（适合常用 npm 包的用户）

将 npm 全局源切换为阿里镜像，后续安装任何 npm 包都能提速，再安装 Claude Code：

```bash
# 1. 全局设置阿里 npm 镜像
npm config set registry https://registry.npmmirror.com
# 2. 安装 Claude Code
npm install -g @anthropic-ai/claude-code
# 3. 验证安装
claude --version
```

## 2.3 方式 3：官方脚本安装（备选，国内网络可能较慢）

若上述两种方式失败，可使用 Claude Code 官方脚本安装，国内网络需耐心等待（偶尔卡顿，无需代理）：

- **macOS/Linux**：
        `curl -fsSL https://claude.ai/install.sh | bash
`

- **Windows（PowerShell 管理员权限）**：
        `irm https://claude.ai/install.ps1 | iex
`

## 2.4 安装失败排查（官方解决方案）

|失败现象|官方原因分析|国内解决方案|
|---|---|---|
|npm 报错"timeout""connect ECONNREFUSED"|海外 npm 源无法访问|重新执行方式 1，确保指定阿里镜像；若仍失败，清除 npm 缓存：npm cache clean -f，再重试|
|终端提示"claude 不是内部或外部命令"|Node.js 未添加到系统环境变量|重新安装 Node.js，勾选"Add to PATH"；或手动添加 Node.js 安装目录（如 C:\Program Files\nodejs）到系统环境变量，重启终端|
|Linux 报错"permission denied"|无 root 权限，无法全局安装|添加 sudo 权限执行：sudo npm install -g @anthropic-ai/claude-code --registry=https://registry.npmmirror.com|

# 三、CC Switch 安装与 MiniMax API 配置（官方步骤，可视化管理）

CC Switch 是 MiniMax 官方推荐的 Claude Code 配置管理工具，支持可视化切换 API 提供商、管理 MCP 服务，以下步骤严格对照 MiniMax 官方文档编写，国内可直装直配。

## 3.1 CC Switch 安装（国内直装，全系统适配）

CC Switch 提供多平台安装包，国内可直接下载安装，推荐对应系统的官方推荐方式：

### （1）Windows 安装（官方推荐 MSI 安装器）

1. 下载官方 MSI 安装包（国内直连）：https://github.com/farion1231/cc-switch/releases （选择最新版本的 CC-Switch-*-Windows.msi）；

2. 双击下载的 MSI 文件，按提示下一步安装（默认路径即可，勾选"Create desktop shortcut"创建桌面快捷方式）；

3. 安装完成后，双击桌面快捷方式启动 CC Switch（首次启动无报错即成功）。

备选：便携版（无需安装）→ 下载 CC-Switch-vx.x.x-Windows-Portable.zip，解压后双击 CC-Switch.exe 即可启动。

### （2）macOS 安装（官方推荐 Homebrew）

```bash
# 1. 添加 CC Switch 官方 Tap（国内可直连）
brew tap farion1231/ccswitch
# 2. 安装 CC Switch（自动适配 Intel/Apple Silicon）
brew install --cask cc-switch
# 3. 启动 CC Switch：打开「应用程序」，找到 CC Switch 双击启动

```

备选：手动安装 → 下载 CC-Switch-vx.x.x-macOS.zip，解压后将 CC Switch 拖动到「应用程序」文件夹，首次启动若提示"无法验证开发者"，前往「系统设置」→「隐私与安全性」，点击"仍要打开"即可。

### （3）Linux 安装（按系统选择）

- **Ubuntu/Debian**：`# 下载 deb 安装包（前往官方 Releases 下载）
sudo dpkg -i CC-Switch-vx.x.x-Linux.deb
# 若报错缺少依赖，执行：
sudo apt install -f
`

- **Fedora/RHEL**：
        `sudo rpm -i CC-Switch-vx.x.x-Linux.rpm
# 或
sudo dnf install ./CC-Switch-vx.x.x-Linux.rpm
`

- **通用 AppImage**：
        `# 下载 AppImage 安装包
chmod +x CC-Switch-vx.x.x-Linux.AppImage
# 启动
./CC-Switch-vx.x.x-Linux.AppImage
`

## 3.2 CC Switch 配置 MiniMax API（可视化，无需手动改配置文件）

配置完成后，CC Switch 会自动同步配置到 Claude Code 的配置文件，严格对照 MiniMax 官方配置步骤：

1. 启动 CC Switch，进入主界面（首次启动无任何配置，显示"无可用提供商"）；

2. 点击主界面右上角「+」，选择预设的 MiniMax 供应商，填写您的 MiniMax API Key；

3. **配置模型名称**：将模型名称全部改为 `MiniMax-M2.1`，完成后点击右下角的「添加」；

4. **启用配置**：回到首页，点击「启用」即可开始使用；

5. **编辑配置文件**：编辑或新增 `.claude.json` 文件
   - MacOS & Linux：`~/.claude.json`
   - Windows：用户目录`.claude.json`

   添加以下内容：
   ```json
   {
     "hasCompletedOnboarding": true
   }
   ```

6. （可选）点击主界面右上角「设置」图标，勾选「自动同步配置」，后续修改配置无需手动重启 Claude Code。

## 3.3 配置验证（官方方法）

```bash
# 关闭所有已打开的终端/VS Code，重新打开终端
# 执行以下命令，验证配置是否生效
claude status
# 若输出「Provider: MiniMax」「Model: MiniMax-M2.1」「API Key: 已配置」，即配置成功
```

## 3.4 手动配置（CLI / VS Code 插件通用，免代理直连）

> **推荐**：不想用 CC Switch，可以直接编辑配置文件，支持 CLI 和 VS Code 插件双版本，免代理直连 MiniMax。

### （1）各系统配置文件路径

|系统|打开方式|
|---|---|
|Windows|文件管理器输入 `%USERPROFILE%\.claude`，编辑里面的 `settings.json`|
|macOS|终端执行 `open ~/.claude/settings.json`|
|Linux|终端执行 `vim ~/.claude/settings.json`|

### （2）完整免代理配置（替换密钥即可）

```json
{
  "env": {
    "ANTHROPIC_BASE_URL": "https://api.minimaxi.com/anthropic",
    "ANTHROPIC_AUTH_TOKEN": "你的MiniMax-CodingPlan-API密钥",
    "ANTHROPIC_MODEL": "MiniMax-M2.1",
    "ANTHROPIC_DEFAULT_SONNET_MODEL": "MiniMax-M2.1",
    "ANTHROPIC_DEFAULT_OPUS_MODEL": "MiniMax-M2.1",
    "ANTHROPIC_DEFAULT_HAIKU_MODEL": "MiniMax-M2.1",
    "API_TIMEOUT_MS": "300000",
    "CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC": 1
  },
  "includeCoAuthoredBy": false
}
```

### （3）配置生效

- **CLI 版**：关闭所有终端，重新打开执行 `claude` 即可；
- **VS Code 插件版**：重启 VS Code，右键代码选择「Ask Claude」就能用。

# 四、MCP 安装配置（图片识别+文件搜索，参考配置）

MCP（Model Context Protocol）是 Anthropic 官方推出的扩展协议，可为 Claude Code 提供图片识别、文件搜索等功能。由于 MiniMax 官方 MCP 配置文档细节较多，本章节提供参考配置，实际安装请以官方文档为准。

## 4.1 MCP 核心环境初始化（官方步骤，全系统通用）

先创建 MCP 专用虚拟环境，避免依赖冲突，按官方推荐使用 UV 管理：

```bash
# 1. 创建 MCP 工作目录（自定义路径，如桌面/mcp-dev）
mkdir ~/Desktop/mcp-dev && cd ~/Desktop/mcp-dev
# 2. 使用 UV 创建并激活虚拟环境
uv venv .venv
# 3. 激活虚拟环境（关键，必须执行）
# Windows（PowerShell）：
.venv\Scripts\activate
# macOS/Linux（终端）：
source .venv/bin/activate
# 激活成功后，终端前缀会显示 (.venv)

```

## 4.2 安装 MCP 核心依赖（MiniMax 官方推荐）

使用 UV 安装 MCP 核心库，国内镜像提速，避免依赖缺失：

```bash
# 安装 MCP 核心工具包（国内镜像）
uv pip install "fast-mcp>=1.5" mcp-toolkit anthropic-mcp minimax-mcp --index-url https://pypi.tuna.tsinghua.edu.cn/simple
# 验证安装
python -c "from fast_mcp import __version__; print(f'FastMCP v{__version__}')"
# 若输出版本号（如 v1.5.0+），即安装成功

```

## 4.3 安装图片识别 MCP（参考配置）

> **提示**：以下 MCP 工具配置为参考写法，实际安装命令和配置方式请以 MiniMax 官方文档为准。

图片识别 MCP 可让 Claude Code 识别图片中的代码、界面，生成对应代码或修改建议：

1. 确保已激活 MCP 虚拟环境（终端前缀显示 (.venv)）；

2. 安装 MCP 图片识别工具（参考命令，国内镜像）：
        ```
        uv pip install mcp-server-vision --index-url https://pypi.tuna.tsinghua.edu.cn/simple
        ```

3. 配置并启动 MCP 服务（参考）：
        ```
        # 配置 API 密钥
        mcp-server-vision configure --api-key "你的MiniMax-CodingPlan-API密钥"
        # 启动服务
        mcp-server-vision start
        ```

## 4.4 安装文件搜索 MCP（参考配置）

> **提示**：以下 MCP 工具配置为参考写法，实际安装命令和配置方式请以 MiniMax 官方文档为准。

文件搜索 MCP 可让 Claude Code 搜索本地项目文件、读取文件内容，无需手动复制粘贴代码：

1. 保持 MCP 虚拟环境激活状态（终端前缀显示 (.venv)）；

2. 安装 MCP 文件搜索工具（参考命令，国内镜像）：
        ```
        uv pip install mcp-server-filesystem --index-url https://pypi.tuna.tsinghua.edu.cn/simple
        ```

3. 配置并启动 MCP 服务（参考）：
        ```
        # 配置 API 密钥和允许访问的目录
        mcp-server-filesystem configure --api-key "你的MiniMax-CodingPlan-API密钥" --allowed-dirs "你的项目目录路径"
        # 启动服务
        mcp-server-filesystem start
        ```

## 4.5 MCP 服务关联 Claude Code（官方方法，CC Switch 可视化配置）

启动 MCP 服务后，需通过 CC Switch 将 MCP 服务关联到 Claude Code，无需手动修改配置文件：

1. 启动 CC Switch，点击主界面右上角「MCP」按钮，进入 MCP 管理页面；

2. 点击「Add MCP Server」，分别添加图片识别和文件搜索 MCP 服务：


    - 添加图片识别 MCP：


        - Name：自定义（如"MCP 图片识别"）；

        - Type：选择「grpc」；

        - Address：输入 http://127.0.0.1:50051（与启动提示一致）；

        - 点击「Save」保存。

    - 添加文件搜索 MCP：


        - Name：自定义（如"MCP 文件搜索"）；

        - Type：选择「grpc」；

        - Address：输入 http://127.0.0.1:50052（与启动提示一致）；

        - 点击「Save」保存。

3. 在 MCP 管理页面，勾选两个 MCP 服务后面的「Enable」（启用），弹出提示"MCP 配置已同步，重启 Claude Code 生效"，点击「确定」；

4. （可选）勾选「开机自动启动 MCP 服务」，避免每次重启电脑后手动启动。

## 4.6 MCP 功能验证（官方测试方法）

关闭所有终端/VS Code，重新打开终端，确保 MCP 服务已启动，执行以下命令验证两个核心功能：

### （1）图片识别 MCP 验证

```bash
# 执行图片识别测试（替换【图片路径】为本地图片路径，如 ~/Desktop/test.png）
claude -c "识别这张图片中的代码，生成对应的 Python 版本" --image "【图片路径】"
# 若能正常识别图片内容并生成代码，即验证成功

```

### （2）文件搜索 MCP 验证

```bash
# 进入你配置的项目目录
cd "你的项目目录路径"
# 执行文件搜索命令
claude -c "搜索当前目录下所有包含 'import' 的 Python 文件，列出文件名并简要说明内容"
# 若能正常搜索到文件并输出结果，即验证成功

```

## 4.7 MCP 常见问题（参考解决方案）

|问题现象|可能原因|参考解决方案|
|---|---|---|
|启动 MCP 服务报错"port is already in use"|端口被其他程序占用|执行命令更换端口，或终止占用端口的进程|
|Claude Code 无法调用 MCP 功能，提示"MCP server not available"|MCP 服务未启动，或 CC Switch 中 MCP 配置错误|1. 重新启动 MCP 服务；2. 检查 CC Switch 中 MCP 地址与服务启动地址一致；3. 重启 Claude Code|
|图片识别/文件搜索失败，提示"invalid api key"|MCP 配置的 MiniMax 密钥错误或过期|重新执行 MCP 配置命令，粘贴正确的 Coding Plan 密钥，重启 MCP 服务|

> **重要提示**：如遇到 MCP 相关问题，请参考 MiniMax 官方 MCP 文档获取最新解决方案。
# 五、VS Code 插件版 Claude Code 安装配置（国内网络，官方步骤）

若习惯使用 VS Code 编程，可安装 Claude Code 官方插件，插件会自动读取前面配置的 CC Switch 和 MCP 信息，无需额外配置，步骤如下：

1. 打开 VS Code（国内网络可正常启动），点击左侧「扩展」图标（快捷键 Ctrl+Shift+X / Cmd+Shift+X）；

2. 在扩展搜索框中输入「Claude AI」（Anthropic 官方出品，图标为蓝色机器人），点击「安装」（国内网络秒装，无需代理）；

3. 安装完成后，重启 VS Code（确保配置和 MCP 服务生效）；

4. 验证插件功能：


    - 打开任意代码文件，右键点击代码，选择「Ask Claude」，弹出对话窗口；

    - 测试图片识别：点击对话窗口右上角「上传图片」，选择本地图片，发送提问，可正常识别即成功；

    - 测试文件搜索：在对话窗口输入「搜索当前项目中包含 'def' 的 Python 文件」，可正常搜索即成功。

# 六、官方教程链接（备用参考，国内可直连）

本教程部分步骤参考以下官方文档编写，若遇到特殊问题，请以官方文档为准：

1. **MiniMax 官方文档（必看）**
   - Coding Plan 接入指南：https://platform.minimaxi.com/docs/coding-plan/intro
   - **Claude Code 接入配置：https://platform.minimaxi.com/docs/coding-plan/claude-code**
   - **MCP 工具配置指南：https://platform.minimaxi.com/docs/coding-plan/mcp-guide**
   - AI 编程工具接入文档：https://platform.minimaxi.com/docs/guides/text-ai-coding-tools
   - API 密钥管理：https://platform.minimaxi.com/docs/guides/api-key-management

2. **Claude Code 官方文档**
   - Claude Code 概述与安装：https://docs.anthropic.com/zh-CN/docs/claude-code/overview

3. **CC Switch 官方文档**
   - 项目主页：https://github.com/farion1231/cc-switch
   - 下载地址：https://github.com/farion1231/cc-switch/releases
   - 中文说明文档：https://github.com/farion1231/cc-switch/blob/main/README_ZH.md

# 七、总结与注意事项

1. 全程国内网络可完成，无需任何代理，核心是通过阿里镜像安装依赖、CC Switch 配置 MiniMax 国内 API；

2. 环境依赖是关键：必须安装 Node.js 18.0.0+，否则会导致 Claude Code 安装失败；

3. MiniMax 密钥必须是「Coding Plan」类型，普通对话密钥无法调用编码功能，密钥需妥善保存，避免泄露；

4. 配置完成后必须编辑 `.claude.json` 文件添加 `hasCompletedOnboarding: true`，否则 Claude Code 无法正常使用；

5. MCP 部分配置为参考写法，实际安装命令和配置方式请以 MiniMax 官方文档为准；

6. 若遇到配置不生效，优先重启终端/VS Code/CC Switch，大部分问题可通过重启解决。

按本教程操作，即可在国内网络环境下，使用 Claude Code + MiniMax M2.1 组合进行编程开发。

---

> **重要提醒**：本教程 MCP 相关章节的安装命令和配置方法为参考写法，具体请以 MiniMax 官方文档为准。如有疑问，请访问以下官方文档查看最新指南：
> - Claude Code 接入配置：https://platform.minimaxi.com/docs/coding-plan/claude-code
> - MCP 工具配置指南：https://platform.minimaxi.com/docs/coding-plan/mcp-guide
