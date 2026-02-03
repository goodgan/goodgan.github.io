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

本教程介绍如何在国内环境安装配置 Claude Code + MiniMax M2.1，全程无需代理。

## 一、环境准备

### 1.1 Node.js 18+

Claude Code 官方依赖，通过国内镜像安装。

- **下载地址**：https://nodejs.org/zh-cn/download/
- **验证**：`node -v` / `npm -v`

### 1.2 MiniMax Coding Plan API 密钥

1. 访问 https://platform.minimaxi.com/ 注册/登录
2. 进入「控制台」→「API 密钥」→「创建新密钥」
3. **必须选择"Coding Plan"类型**（普通对话密钥无效）

> 详细步骤参考官方文档：https://platform.minimaxi.com/docs/coding-plan/intro

## 二、安装 Claude Code

使用阿里 npm 镜像安装：

```bash
npm install -g @anthropic-ai/claude-code --registry=https://registry.npmmirror.com
```

> 官方安装文档：https://docs.anthropic.com/zh-CN/docs/claude-code/overview

## 三、配置 MiniMax API

### 方式 1：CC Switch 可视化配置（推荐）

1. 下载 CC Switch：https://github.com/farion1231/cc-switch/releases
2. 启动 CC Switch，点击右上角「+」添加 MiniMax 供应商
3. 填写 API Key，模型名称设为 `MiniMax-M2.1`
4. 点击「启用」

### 方式 2：手动编辑配置文件

编辑 `~/.claude/settings.json`（Windows：`%USERPROFILE%\.claude\settings.json`）：

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

编辑 `~/.claude.json` 添加：

```json
{
  "hasCompletedOnboarding": true
}
```

> 官方配置指南：https://platform.minimaxi.com/docs/coding-plan/claude-code

## 四、MCP 配置

参考 MiniMax 官方 MCP 文档：https://platform.minimaxi.com/docs/coding-plan/mcp-guide

重要：配置MCP后 minimax m2.1 才具备图片理解和网络搜索功能。

## 五、VS Code 插件

1. VS Code 扩展市场搜索「Claude AI」（Anthropic 官方）
2. 安装后重启 VS Code
3. 右键代码选择「Ask Claude」即可使用

## 六、验证

```bash
claude
```

## 七、官方参考链接

| 用途 | 链接 |
|------|------|
| MiniMax Coding Plan 接入 | https://platform.minimaxi.com/docs/coding-plan/intro |
| Claude Code 接入配置 | https://platform.minimaxi.com/docs/coding-plan/claude-code |
| MCP 工具配置指南 | https://platform.minimaxi.com/docs/coding-plan/mcp-guide |
| Claude Code 官方文档 | https://docs.anthropic.com/zh-CN/docs/claude-code/overview |
| CC Switch 项目主页 | https://github.com/farion1231/cc-switch |
