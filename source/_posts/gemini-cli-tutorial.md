---
title: Gemini-CLI安装与使用完全指南：从注册到运行
date: 2025-08-22 11:00:00
categories: 技术分享
tags:
  - Gemini
  - CLI
  - AI
  - Google Cloud
  - 开发工具
cover_picture: /images/ai-coding-tools.jpg
---

# Gemini-CLI安装与使用完全指南：从注册到运行

> 本文提供了一份完整的教程，指导您如何从零开始，完成Google账号注册、API项目设置，并最终在本地成功安装和使用Gemini-CLI工具，让您能够通过命令行与强大的Gemini模型进行交互。

<!-- more -->

## 一、准备工作：注册谷歌账号

要使用Google的Gemini API，您首先需要一个Google账号。

1.  **访问注册页面**：打开 [Google账号创建页面](https://accounts.google.com/signup)。
2.  **填写信息**：按照页面提示，填写您的姓名、用户名和密码。
3.  **完成验证**：通过手机号等方式验证您的身份。
4.  **开启两步验证（强烈推荐）**：为了账户安全，建议您在账号管理页面开启两步验证。

## 二、创建Google Cloud项目并获取项目ID

接下来，我们需要通过 Google AI Studio 创建一个项目，并获取关键的**项目ID**。

1.  **访问Google AI Studio**：前往 [Google AI Studio](https://aistudio.google.com/)。
2.  **登录账号**：使用您的Google账号登录。
3.  **创建API密钥和项目**：
    *   点击左侧菜单栏的 “Get API key” 选项。
    *   在打开的页面中，点击 “Create API key in new project”。
    *   系统会自动为您创建一个新的Google Cloud项目，并生成一个API密钥和项目ID。
4.  **保存信息**：请务必复制并妥善保管您的**项目ID (Project ID)**，后续配置需要用到。API密钥在此次CLI配置中非必需，但建议同样保存好以备后用。

## 三、安装与配置Gemini CLI

现在，我们开始在本地安装官方的Gemini CLI工具。

- **官方地址**：[https://github.com/google-gemini/gemini-cli](https://github.com/google-gemini/gemini-cli)

### 1. 安装前提
- 确保您已安装 **Node.js** (版本 >= 18)。

### 2. 安装CLI工具
打开您的终端（CMD, PowerShell, Bash等），运行以下命令进行全局安装：
```bash
npm install -g @google/gemini-cli
```

### 3. 首次运行与认证
1.  安装完成后，在终端输入 `gemini` 并回车。
2.  程序会提示您选择认证方式，请选择第一个选项：
    > **选项 1：OAuth 登录（使用您的 Google 帐户）**
    > 这是最适合个人开发者的免费方案，无需管理API密钥，每天有1000次请求的免费额度。
3.  选择后，您的浏览器会自动打开一个Google登录和授权页面，请完成授权。

### 4. 配置项目ID（关键步骤）
为了让CLI工具知道使用哪个Google Cloud项目，您需要手动创建一个配置文件。

1.  **找到配置目录**：
    *   在Windows上，路径为 `C:\Users\{你的用户名}\.gemini`
    *   在macOS或Linux上，路径为 `~/.gemini`
2.  **创建配置文件**：在该目录下，创建一个名为 `.env` 的文件。
3.  **写入项目ID**：在 `.env` 文件中，添加以下内容，并将 `your_project_id` 替换为您在第二步中获取的项目ID。
    ```
    GOOGLE_CLOUD_PROJECT=your_project_id
    ```
    例如：
    ```
    GOOGLE_CLOUD_PROJECT=gemini-api-project-123456
    ```

完成以上步骤后，您的Gemini CLI就配置好了。

## 四、解决网络登录问题（如需要）

如果您在运行 `gemini` 进行网页认证时遇到网络错误或超时，这通常是由于网络限制导致的。您可以通过为终端设置代理来解决。

**第一步：确保代理工具稳定**
- 检查您的代理或VPN工具是否工作正常，建议切换到一个连接质量高的服务器节点。
- 确保Google相关域名（如 `*.google.com`）在代理规则内。

**第二步：为终端设置代理**
在**新的终端窗口**中，根据您的系统执行以下命令，然后再运行 `gemini`。

- **Windows (CMD)**:
  ```cmd
  set https_proxy=http://127.0.0.1:10808
  set http_proxy=http://127.0.0.1:10808
  ```

- **Windows (PowerShell)**:
  ```powershell
  $env:https_proxy="http://127.0.0.1:10808"
  $env:http_proxy="http://127.0.0.1:10808"
  ```

- **macOS / Linux (Bash/Zsh)**:
  ```bash
  export https_proxy=http://127.0.0.1:10808
  export http_proxy=http://127.0.0.1:10808
  ```

**注意**：请将 `10808` 替换为您的代理软件实际提供的HTTP代理端口。

## 五、Gemini CLI 常用命令

配置成功后，您就可以使用以下命令与Gemini进行交互了。

### 1. 交互式聊天
启动一个可以连续对话的聊天会话。
```bash
gemini chat
```

### 2. 单次提问
快速获取单个问题的答案。
```bash
gemini gen "请介绍一下北京故宫"
```

### 3. 结合文件内容提问
让Gemini读取一个文件并基于其内容进行回答。
```bash
gemini gen "总结一下这个文件的主要内容" a-document.txt
```

### 4. 识别图片内容
发送一张本地图片，让Gemini进行描述或分析。
```bash
gemini gen "描述一下这张图片里有什么" an-image.png
```

### 5. 查看历史记录
列出您最近的提问历史。
```bash
gemini history
```

### 6. 计算Token数量
在发送请求前，计算一段文本会消耗多少Token。
```bash
gemini count "这段文字有多少个token？"
```

## 六、总结

通过本教程，您已经成功配置并掌握了Gemini CLI的基本使用方法。这个工具非常适合集成到您的开发工作流或自动化脚本中。

如果想了解更多高级用法，例如设置模型参数、多模态聊天等，请务必查阅 **[Gemini CLI官方GitHub仓库](https://github.com/google-gemini/gemini-cli)** 以获取最新、最全的信息。