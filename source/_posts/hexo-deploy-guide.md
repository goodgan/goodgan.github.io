---
title: Hexo部署个人网站到GitHub详细教程
date: 2025-07-23 14:30:00
categories: 技术分享
tags:
  - 技术
  - 博客
  - Hexo
  - GitHub
  - 教程
cover_picture: /images/post.jpg
---

# Hexo部署个人网站到GitHub详细教程

> 本文提供了使用Hexo框架搭建个人网站并部署到GitHub Pages的完整流程，包括环境搭建、主题配置、插件安装、部署设置以及网站维护等全方位指南。

<!-- more -->

## 一、前期准备

### 1. 安装必要的软件

在开始前，需要安装以下软件：

#### Node.js和npm

Hexo基于Node.js，需要先安装Node.js和npm：

- **Windows**: 下载并安装 [Node.js官方安装包](https://nodejs.org/)
- **Mac**: 使用Homebrew安装 `brew install node`
- **Linux**: 使用包管理器安装 `sudo apt install nodejs npm` 或 `sudo yum install nodejs npm`

检查安装是否成功：

```bash
node -v  # 查看Node.js版本
npm -v   # 查看npm版本
```

#### Git

Git用于版本控制和部署：

- **Windows**: 下载并安装 [Git for Windows](https://gitforwindows.org/)
- **Mac**: 使用Homebrew安装 `brew install git`
- **Linux**: `sudo apt install git` 或 `sudo yum install git`

检查安装：

```bash
git --version
```

### 2. GitHub账号设置

1. **创建GitHub账号**：访问[GitHub官网](https://github.com/)注册
2. **创建新仓库**：仓库名必须为 `username.github.io`（username是你的GitHub用户名）
3. **配置SSH密钥**（推荐）：
   ```bash
   ssh-keygen -t rsa -C "你的邮箱"
   # 复制公钥内容
   cat ~/.ssh/id_rsa.pub  # Linux/Mac
   # 或 
   type %USERPROFILE%\.ssh\id_rsa.pub  # Windows
   ```
   然后在GitHub的Settings -> SSH and GPG keys -> New SSH key中添加

## 二、Hexo安装与初始化

### 1. 全局安装Hexo-CLI

```bash
npm install -g hexo-cli
```

检查安装：

```bash
hexo version
```

### 2. 初始化博客项目

```bash
# 创建博客文件夹并初始化
hexo init myblog
cd myblog
npm install
```

### 3. 目录结构说明

```
myblog/
├── _config.yml     # 网站配置文件
├── package.json    # 应用程序信息
├── scaffolds/      # 模板文件夹
├── source/         # 存放用户资源的文件夹
│   ├── _drafts/    # 草稿
│   └── _posts/     # 文章
└── themes/         # 主题文件夹
```


### 4. 本地预览

```bash
hexo clean   # 清除缓存
hexo generate # 生成静态文件
hexo server   # 启动本地服务器
```

访问 `http://localhost:4000` 预览效果

## 三、博客基本配置

### 1. 修改站点配置

编辑根目录下的 `_config.yml`：

```yaml
# 网站信息
title: 我的个人博客
subtitle: '个人技术分享'
description: '分享技术与生活'
keywords: 博客,hexo,技术
author: 你的名字
language: zh-CN
timezone: 'Asia/Shanghai'

# 网址设置
url: https://username.github.io  # 替换成你的GitHub用户名
root: /
permalink: :year/:month/:day/:title/

# 目录设置
source_dir: source
public_dir: public
```

### 2. 安装必备插件

#### 部署插件

```bash
npm install hexo-deployer-git --save
```

#### 其他实用插件

```bash
# RSS订阅
npm install hexo-generator-feed --save

# 站点地图
npm install hexo-generator-sitemap --save
npm install hexo-generator-baidu-sitemap --save

# 文章压缩
npm install hexo-all-minifier --save

# 搜索功能
npm install hexo-generator-searchdb --save

# 字数统计与阅读时间
npm install hexo-word-counter --save

# 本地搜索
npm install hexo-generator-search --save
```

## 四、主题安装与配置

### 1. 选择并安装主题

可以在[Hexo主题列表](https://hexo.io/themes/)浏览，这里以Next主题为例：

```bash
# 下载主题
git clone https://github.com/next-theme/hexo-theme-next themes/next

# 或者安装其他流行主题如Butterfly
git clone https://github.com/jerryc127/hexo-theme-butterfly themes/butterfly
```

### 2. 启用主题

在站点配置文件`_config.yml`中设置：

```yaml
theme: next  # 或其他主题名称
```

### 3. 配置主题

编辑主题配置文件 `themes/next/_config.yml`：

```yaml
# 菜单设置
menu:
  home: / || fa fa-home
  archives: /archives/ || fa fa-archive
  tags: /tags/ || fa fa-tags
  categories: /categories/ || fa fa-th
  about: /about/ || fa fa-user

# 主题方案 - 可选Muse/Mist/Pisces/Gemini
scheme: Gemini

# 侧边栏设置
sidebar:
  position: left
  display: post

# 头像设置
avatar:
  url: /images/avatar.png
  rounded: true
  rotated: false
```

### 4. 创建关于页面等

```bash
hexo new page about
hexo new page categories
hexo new page tags
```

编辑这些页面的 `index.md` 文件，添加 front-matter：

```yaml
---
title: 关于我
date: 2025-07-23
type: "about"
---
```

## 五、部署到GitHub Pages

### 1. 配置部署设置

编辑站点配置文件 `_config.yml`：

```yaml
deploy:
  type: git
  repo: https://github.com/username/username.github.io.git  # 替换为你的仓库地址
  branch: main  # GitHub的默认分支可能是main或master
  message: Site updated: {{ now('YYYY-MM-DD HH:mm:ss') }}
```

如果使用SSH方式，则更改repo为：

```yaml
repo: git@github.com:username/username.github.io.git
```

### 2. 执行部署命令

```bash
# 清理、生成并部署
hexo clean
hexo generate
hexo deploy
```

或者简写为：

```bash
hexo clean && hexo g -d
```

### 3. 部署自动化脚本（可选）

可以创建一个部署脚本 `deploy.sh`：

```bash
#!/bin/bash
hexo clean
hexo generate
hexo deploy
```

设置执行权限：

```bash
chmod +x deploy.sh
```

使用时只需执行：

```bash
./deploy.sh
```

## 六、高级配置与功能增强

### 1. 配置评论系统

Hexo支持多种评论系统，以Gitalk为例：

1. 在GitHub创建OAuth应用：Settings -> Developer settings -> OAuth Apps

2. 安装Gitalk：

   ```bash
   npm install gitalk --save
   ```

3. 在主题配置中设置：

   ```yaml
   gitalk:
     enable: true
     clientID: 你的客户端ID
     clientSecret: 你的客户端密钥
     repo: username.github.io
     owner: username
     admin: [username]
   ```

### 2. 添加数据统计

#### Google Analytics

在 `_config.yml` 中配置：

```yaml
google_analytics: UA-XXXXXXXXX-X
```

#### 百度统计

```yaml
baidu_analytics: 你的百度统计ID
```

### 3. SEO优化

添加网站验证：

```yaml
# Google Site Verification
google_site_verification: 验证码

# Baidu Site Verification
baidu_site_verification: 验证码
```

### 4. 文章加密（插件安装）

```bash
npm install hexo-blog-encrypt --save
```

在文章front-matter中设置：

```yaml
---
title: 私密文章
date: 2025-07-23
password: yourpassword
abstract: 这是一篇加密文章，请输入密码访问。
message: 请输入密码
---
```

### 5. 图片优化与CDN

安装图片处理插件：

```bash
npm install hexo-image-link --save
```

配置CDN（以七牛云为例）：

```yaml
# _config.yml
cdn:
  enable: true
  base: https://your-cdn-domain.com
```

## 七、博客日常维护与更新

### 1. 创建新文章

```bash
# 创建普通文章
hexo new "文章标题"

# 创建指定布局的文章
hexo new post "文章标题"

# 创建草稿
hexo new draft "草稿标题"
```

### 2. 文章格式与Front-matter

```yaml
---
title: 文章标题
date: 2025-07-23 14:30:00
updated: 2025-07-24 15:00:00
categories: 
  - 分类名称
tags:
  - 标签1
  - 标签2
permalink: 自定义永久链接
cover: /images/cover.jpg
comments: true
toc: true  # 显示目录
---
```

### 3. 将草稿转为正式文章

```bash
# 发布草稿
hexo publish draft "草稿标题"

# 预览包括草稿的文章
hexo server --draft
```

### 4. 管理与备份源文件

使用Git管理源文件（推荐采用两个分支管理）：

```bash
# 初始化Git仓库（如果尚未初始化）
git init

# 添加远程仓库（假设使用source分支存储源文件）
git remote add origin https://github.com/username/username.github.io.git

# 创建source分支
git checkout -b source

# 添加.gitignore文件
echo "public/" >> .gitignore
echo "node_modules/" >> .gitignore
echo ".deploy_git/" >> .gitignore
echo "db.json" >> .gitignore

# 提交源文件
git add .
git commit -m "Source files update"
git push origin source
```

### 5. 更新发布流程

完整的更新发布流程：

```bash
# 1. 创建或修改文章
hexo new "新文章"
# 编辑文章...

# 2. 本地预览
hexo clean
hexo server

# 3. 部署到GitHub Pages
hexo clean
hexo generate
hexo deploy

# 4. 备份源文件
git add .
git commit -m "更新文章: 新文章"
git push origin source
```

### 6. 在不同设备上工作

在新电脑上继续博客工作：

```bash
# 1. 安装必要软件 (Node.js, Git, Hexo)
npm install -g hexo-cli

# 2. 克隆源文件
git clone -b source https://github.com/username/username.github.io.git myblog
cd myblog

# 3. 安装依赖
npm install

# 4. 开始工作
# ... 编辑文章等

# 5. 部署
hexo clean && hexo g -d
```

## 八、常见问题与解决方案

### 1. 部署问题

**问题**: 部署时出现 "ERROR Deployer not found: git"
**解决**: 安装部署插件 `npm install hexo-deployer-git --save`

**问题**: 部署后网站无法访问
**解决**: 
- 检查仓库名是否正确（必须是username.github.io）
- 检查部署配置中的分支名（main或master）
- 查看GitHub Pages设置是否启用

### 2. 主题问题

**问题**: 主题应用后样式丢失
**解决**:
- 检查主题名称是否与文件夹名一致
- 重新执行 `hexo clean && hexo g`
- 确保主题配置文件格式正确

### 3. 图片显示问题

**问题**: 本地可见但部署后图片不显示
**解决**:
1. 使用绝对路径：`![](/images/photo.jpg)`
2. 安装资源引用插件：`npm install hexo-asset-image --save`
3. 在站点配置中设置 `post_asset_folder: true`

### 4. 自定义域名设置

1. 购买域名并添加解析记录:
   - 类型: CNAME
   - 主机记录: www 或 @
   - 记录值: username.github.io

2. 在GitHub仓库设置中添加自定义域名

3. 创建CNAME文件:
   ```bash
   echo "yourdomain.com" > source/CNAME
   ```

## 九、进阶定制与优化

### 1. 使用GitHub Actions自动部署

创建 `.github/workflows/deploy.yml` 文件：

```yaml
name: Deploy Hexo

on:
  push:
    branches:
      - source  # 监听source分支的push事件

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout source
        uses: actions/checkout@v2

      - name: Setup Node.js
        uses: actions/setup-node@v2
        with:
          node-version: '16'

      - name: Install dependencies
        run: npm install

      - name: Generate and deploy
        run: |
          hexo clean
          hexo generate
          cd public
          git init
          git config user.name "GitHub Actions"
          git config user.email "actions@github.com"
          git add .
          git commit -m "Site updated by GitHub Actions"
          git push -f https://${{ secrets.GITHUB_TOKEN }}@github.com/username/username.github.io.git master:main
```

### 2. 优化加载速度

1. **启用GZIP压缩**:
   安装插件：`npm install hexo-all-minifier --save`

   在站点配置文件中添加：
   ```yaml
   all_minifier: true
   ```

2. **懒加载图片**:
   安装插件：`npm install hexo-lazyload-image --save`

   配置：
   ```yaml
   lazyload:
     enable: true
     loadingImg: /images/loading.gif
   ```

3. **使用CDN加速**:
   配置主流CDN服务，如jsDelivr：
   ```yaml
   # 主题配置中
   cdn:
     enable: true
     jquery: https://cdn.jsdelivr.net/npm/jquery@3.6.0/dist/jquery.min.js
   ```

### 3. 添加友情链接页面

创建友链页面：

```bash
hexo new page links
```

编辑`source/links/index.md`：

```markdown
---
title: 友情链接
date: 2025-07-23
type: "links"
---

## 朋友们的博客

- [朋友博客一](https://example1.com) - 简短描述
- [朋友博客二](https://example2.com) - 简短描述
```

## 十、参考资源

### 官方文档

- [Hexo官方文档](https://hexo.io/zh-cn/docs/)
- [GitHub Pages官方指南](https://docs.github.com/en/pages)

### 实用工具

- [Markdown编辑器推荐](https://www.typora.io/)
- [免费SSL证书](https://letsencrypt.org/)
- [图床服务](https://sm.ms/)

### 延伸阅读

- [Git基础教程](https://git-scm.com/book/zh/v2)
- [Markdown语法指南](https://www.markdownguide.org/)
- [常用前端CDN服务对比](https://www.jsdelivr.com/)

---

希望这份详细教程能帮助你顺利搭建并部署自己的Hexo个人网站。如果在过程中遇到任何问题，欢迎在评论区留言讨论！