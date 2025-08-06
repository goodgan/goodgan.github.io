# 个人博客网站

基于[Hexo框架](https://hexo.io/zh-cn/)和[MiHo主题](https://github.com/WongMinHo/hexo-theme-miho)的个人博客网站。

## 目录结构

```
goodgan.github.io/
├── .deploy_git/     # 部署相关文件
├── node_modules/    # 依赖包
├── public/          # 生成的静态网站文件
├── scaffolds/       # 模板文件
├── scripts/         # 自定义脚本
├── source/          # 源文件
│   ├── _posts/      # 博客文章
│   ├── images/      # 图片资源
│   ├── css/         # 自定义样式
│   └── about/       # 关于页面
├── themes/          # 主题
│   └── miho/        # MiHo主题
├── _config.yml      # 站点配置文件
├── .gitignore       # Git忽略文件
├── package.json     # 项目依赖配置
└── README.md        # 项目说明
```

## 快速开始

### 1. 安装依赖

在项目根目录下运行：

```bash
cd /path/to/goodgan.github.io  # 进入项目根目录
npm install
```

### 2. 本地预览

在项目根目录下运行：

```bash
cd /path/to/goodgan.github.io  # 进入项目根目录
npx hexo clean           # 清除缓存
npx hexo generate        # 生成静态文件
npx hexo server          # 启动本地服务器
```

访问 http://localhost:4000 预览网站

### 3. 部署到GitHub Pages

#### 方法一：使用Hexo部署命令

在项目根目录下运行：

```bash
cd /path/to/goodgan.github.io  # 进入项目根目录
hexo clean           # 清除缓存
hexo generate        # 生成静态文件
hexo deploy          # 部署到GitHub
```

#### 方法二：手动部署public目录到gh-pages分支

如果需要手动将public目录部署到gh-pages分支，可以按照以下步骤操作：

```bash
cd /path/to/goodgan.github.io  # 进入项目根目录
hexo clean           # 清除缓存
hexo generate        # 生成静态文件

# 进入public目录
cd public

# 初始化Git仓库
git init

# 创建并切换到gh-pages分支
git checkout -b gh-pages

# 添加所有文件
git add .

# 提交更改
git commit -m "部署网站"

# 添加远程仓库
git remote add origin https://github.com/goodgan/goodgan.github.io.git

# 强制推送到gh-pages分支
git push -f origin gh-pages

# 返回项目根目录
cd ..
```

> **注意**：手动部署时，确保不要将public目录下的内容推送到main分支，这会导致源代码被静态文件覆盖。

## 项目配置

- **站点配置文件**: `_config.yml`
  - 包含网站基本信息、URL设置、部署配置等
  
- **主题配置文件**: `themes/miho/_config.yml`
  - 包含主题相关设置、导航菜单、社交链接等

## 写作

在项目根目录下运行：

```bash
cd /path/to/goodgan.github.io  # 进入项目根目录

# 创建新文章
hexo new "文章标题"

# 创建新页面
hexo new page "页面名称"
```

- 文章将保存在 `source/_posts/` 目录下
- 页面将保存在 `source/页面名称/` 目录下
- 使用Markdown格式编辑内容

## 分支管理

- **main分支**: 存储博客源代码（Markdown文章、配置文件等）
- **gh-pages分支**: 存储Hexo生成的静态网站文件（HTML、CSS、JavaScript等）
