---
title: 从零开始：SpringBoot项目服务器部署完全指南
date: 2025-07-24 10:00:00
categories: 技术分享
tags:
  - 技术
  - SpringBoot
  - 服务器
  - Linux
  - 部署
cover_picture: /images/post2.jpg
---

# 从零开始：SpringBoot项目服务器部署完全指南

> 本文详细介绍了如何将SpringBoot项目从本地开发环境部署到生产服务器的全过程，包括服务器环境准备、远程连接工具使用、环境安装配置、代码部署及项目运行维护等全方位内容。

<!-- more -->

## 一、准备工作

### 1. 服务器选择与购买

选择适合的云服务器提供商：

- **国内**：阿里云、腾讯云、华为云
- **国外**：AWS、Google Cloud、DigitalOcean

购买时需要考虑的因素：

- **操作系统**：推荐 CentOS 7/8 或 Ubuntu 18.04/20.04/22.04 LTS
- **配置**：根据项目需求选择（建议最低 2核4G）
- **带宽**：根据访问量决定
- **存储**：根据数据量决定（建议最低 40GB SSD）

### 2. 域名与备案（国内服务器必须）

- 购买域名（阿里云、腾讯云、GoDaddy 等）
- 国内服务器需要进行 ICP 备案
- 配置 DNS 解析，将域名指向服务器 IP

### 3. 本地准备工作

#### 安装远程连接工具

**Windows 平台**：
- **Xshell**：SSH 终端模拟器
- **Xftp**：SFTP/FTP 文件传输工具

**Mac/Linux 平台**：
- 终端自带 SSH 客户端
- **FileZilla**：跨平台 FTP 客户端

#### SpringBoot 项目打包

确保项目可以在本地正常打包：

```bash
# Maven 项目
mvn clean package -Dmaven.test.skip=true

# Gradle 项目
gradle build -x test
```

## 二、连接与管理服务器

### 1. 使用 Xshell 连接服务器

1. **打开 Xshell**，点击"新建"按钮
2. **配置连接信息**：
   - 名称：自定义会话名
   - 协议：SSH
   - 主机：服务器 IP 地址
   - 端口：22（默认 SSH 端口）
   - 用户身份验证：
     - 方法：Password
     - 用户名：root（首次登录）
     - 密码：服务器密码

3. **连接服务器**：点击"确定"后连接

### 2. 使用 Xftp 传输文件

1. **打开 Xftp**，点击"新建"按钮
2. **配置连接信息**（同 Xshell）
3. **连接后操作**：
   - 左侧为本地文件
   - 右侧为服务器文件
   - 拖拽文件即可传输

### 3. 服务器基础设置

#### 修改密码

```bash
passwd
```

#### 创建普通用户（安全实践）

```bash
# 创建用户
useradd -m springuser

# 设置密码
passwd springuser

# 赋予 sudo 权限
usermod -aG wheel springuser  # CentOS
# 或
usermod -aG sudo springuser   # Ubuntu
```

#### 更新系统

```bash
# CentOS
yum update -y

# Ubuntu
apt update && apt upgrade -y
```

#### 配置防火墙

```bash
# CentOS 7/8
# 安装防火墙
yum install -y firewalld

# 启动防火墙
systemctl start firewalld
systemctl enable firewalld

# 开放端口
firewall-cmd --permanent --add-port=80/tcp    # HTTP
firewall-cmd --permanent --add-port=443/tcp   # HTTPS
firewall-cmd --permanent --add-port=8080/tcp  # SpringBoot 默认端口
firewall-cmd --permanent --add-port=3306/tcp  # MySQL
firewall-cmd --reload

# Ubuntu
# 安装防火墙
apt install -y ufw

# 启动防火墙
ufw enable

# 开放端口
ufw allow 80/tcp    # HTTP
ufw allow 443/tcp   # HTTPS
ufw allow 8080/tcp  # SpringBoot 默认端口
ufw allow 3306/tcp  # MySQL
```

## 三、安装宝塔面板（可选）

宝塔面板是一个简化 Linux 服务器管理的可视化工具。

### 1. 安装宝塔面板

```bash
# CentOS
yum install -y wget && wget -O install.sh http://download.bt.cn/install/install_6.0.sh && sh install.sh

# Ubuntu
wget -O install.sh http://download.bt.cn/install/install-ubuntu_6.0.sh && sudo bash install.sh
```

安装完成后，会显示以下信息：
- 宝塔面板地址
- 默认账号密码

### 2. 宝塔面板基本使用

1. **访问面板**：在浏览器中输入面板地址（http://服务器IP:8888）
2. **安装推荐软件**：
   - Nginx
   - MySQL
   - Java 项目管理器

3. **使用宝塔管理文件**：
   - 文件 > 根目录 > 上传文件
   
4. **使用宝塔管理数据库**：
   - 数据库 > 添加数据库

5. **使用宝塔配置网站**：
   - 网站 > 添加站点

## 四、手动配置服务器环境

如果不使用宝塔面板，可以按以下步骤手动配置：

### 1. 安装 JDK

```bash
# CentOS
yum install -y java-11-openjdk-devel

# Ubuntu
apt install -y openjdk-11-jdk

# 验证安装
java -version
```

### 2. 安装 MySQL

#### CentOS 7/8

```bash
# 安装 MySQL 仓库
rpm -ivh https://dev.mysql.com/get/mysql80-community-release-el7-3.noarch.rpm
yum install -y mysql-server

# 启动 MySQL
systemctl start mysqld
systemctl enable mysqld

# 获取临时密码
grep "temporary password" /var/log/mysqld.log

# 安全配置
mysql_secure_installation
```

#### Ubuntu

```bash
# 安装 MySQL
apt install -y mysql-server

# 启动 MySQL
systemctl start mysql
systemctl enable mysql

# 安全配置
mysql_secure_installation
```

### 3. 创建数据库与用户

```bash
# 登录 MySQL
mysql -u root -p

# 创建数据库
CREATE DATABASE springapp CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

# 创建用户
CREATE USER 'springuser'@'localhost' IDENTIFIED BY '密码';
GRANT ALL PRIVILEGES ON springapp.* TO 'springuser'@'localhost';
FLUSH PRIVILEGES;

# 退出
EXIT;
```

### 4. 安装 Nginx

#### CentOS 7/8

```bash
# 安装 EPEL 仓库
yum install -y epel-release

# 安装 Nginx
yum install -y nginx

# 启动 Nginx
systemctl start nginx
systemctl enable nginx
```

#### Ubuntu

```bash
# 安装 Nginx
apt install -y nginx

# 启动 Nginx
systemctl start nginx
systemctl enable nginx
```

## 五、部署 SpringBoot 项目

### 1. 上传项目 JAR 包

使用 Xftp 将打包好的 JAR 文件上传到服务器，例如：`/opt/springapp/app.jar`

```bash
# 创建部署目录
mkdir -p /opt/springapp
chmod 755 /opt/springapp

# 上传 JAR 包后设置权限
chmod 755 /opt/springapp/app.jar
```

### 2. 创建配置文件

在 JAR 包同级目录创建 `application-prod.properties` 或 `application-prod.yml` 文件：

```bash
# 示例配置（application-prod.properties）
vi /opt/springapp/application-prod.properties
```

添加内容：

```properties
server.port=8080
spring.datasource.url=jdbc:mysql://localhost:3306/springapp?useSSL=false&serverTimezone=UTC&characterEncoding=UTF-8
spring.datasource.username=springuser
spring.datasource.password=密码
spring.jpa.hibernate.ddl-auto=update

# 日志配置
logging.file.path=/opt/springapp/logs
logging.level.root=warn
logging.level.com.yourpackage=info
```

### 3. 创建启动脚本

```bash
vi /opt/springapp/start.sh
```

添加内容：

```bash
#!/bin/bash
cd /opt/springapp
nohup java -jar app.jar --spring.config.location=file:./application-prod.properties > /dev/null 2>&1 &
echo $! > app.pid
```

赋予执行权限：

```bash
chmod +x /opt/springapp/start.sh
```

### 4. 创建停止脚本

```bash
vi /opt/springapp/stop.sh
```

添加内容：

```bash
#!/bin/bash
PID_FILE=/opt/springapp/app.pid
if [ -f "$PID_FILE" ]; then
    PID=$(cat $PID_FILE)
    if [ -n "$PID" ]; then
        kill $PID
        rm $PID_FILE
        echo "Application stopped"
    else
        echo "PID file is empty"
    fi
else
    echo "PID file not found"
fi
```

赋予执行权限：

```bash
chmod +x /opt/springapp/stop.sh
```

### 5. 创建重启脚本

```bash
vi /opt/springapp/restart.sh
```

添加内容：

```bash
#!/bin/bash
/opt/springapp/stop.sh
sleep 5
/opt/springapp/start.sh
```

赋予执行权限：

```bash
chmod +x /opt/springapp/restart.sh
```

### 6. 配置 Systemd 服务（推荐）

创建服务文件：

```bash
vi /etc/systemd/system/springapp.service
```

添加内容：

```ini
[Unit]
Description=Spring Boot Application
After=syslog.target network.target

[Service]
User=root
WorkingDirectory=/opt/springapp
ExecStart=/usr/bin/java -jar /opt/springapp/app.jar --spring.config.location=file:/opt/springapp/application-prod.properties
ExecStop=/bin/kill -15 $MAINPID
SuccessExitStatus=143
Restart=always
RestartSec=5

[Install]
WantedBy=multi-user.target
```

启用服务：

```bash
systemctl daemon-reload
systemctl enable springapp
systemctl start springapp
```

管理服务：

```bash
# 查看状态
systemctl status springapp

# 启动服务
systemctl start springapp

# 停止服务
systemctl stop springapp

# 重启服务
systemctl restart springapp

# 查看日志
journalctl -u springapp -f
```

## 六、配置 Nginx 反向代理

### 1. 创建 Nginx 配置文件

```bash
# CentOS
vi /etc/nginx/conf.d/springapp.conf

# Ubuntu
vi /etc/nginx/sites-available/springapp
```

添加内容：

```nginx
server {
    listen 80;
    server_name example.com www.example.com;  # 替换为你的域名
    
    location / {
        proxy_pass http://localhost:8080;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
    
    # 静态资源处理
    location /static/ {
        alias /opt/springapp/static/;
    }
}
```

在 Ubuntu 上创建符号链接：

```bash
# 仅 Ubuntu 需要
ln -s /etc/nginx/sites-available/springapp /etc/nginx/sites-enabled/
```

### 2. 测试并重启 Nginx

```bash
# 测试配置
nginx -t

# 重启 Nginx
systemctl restart nginx
```

### 3. 配置 HTTPS（可选但推荐）

安装 Certbot：

```bash
# CentOS
yum install -y certbot python3-certbot-nginx

# Ubuntu
apt install -y certbot python3-certbot-nginx
```

获取并配置 SSL 证书：

```bash
certbot --nginx -d example.com -d www.example.com
```

按照提示完成配置。

## 七、数据库迁移和导入

### 1. 导出本地数据库

```bash
# Windows CMD
mysqldump -u username -p databasename > backup.sql

# Linux/Mac Terminal
mysqldump -u username -p databasename > backup.sql
```

### 2. 上传数据库备份文件

使用 Xftp 上传 `backup.sql` 到服务器。

### 3. 导入数据库

```bash
mysql -u springuser -p springapp < backup.sql
```

## 八、项目维护与监控

### 1. 设置日志轮转

创建 logrotate 配置：

```bash
vi /etc/logrotate.d/springapp
```

添加内容：

```
/opt/springapp/logs/*.log {
    daily
    missingok
    rotate 30
    compress
    delaycompress
    notifempty
    create 0640 root root
}
```

### 2. 监控 JVM 性能

安装和使用 `jstat`：

```bash
# 查看 GC 统计信息
jstat -gc $(pgrep -f app.jar) 5000
```

### 3. 使用 Prometheus + Grafana 监控（可选）

修改 SpringBoot 项目，添加 Actuator 和 Micrometer 依赖：

```xml
<!-- Maven -->
<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-actuator</artifactId>
</dependency>
<dependency>
    <groupId>io.micrometer</groupId>
    <artifactId>micrometer-registry-prometheus</artifactId>
</dependency>
```

配置 Prometheus 和 Grafana：

```bash
# 使用 Docker 安装 Prometheus 和 Grafana
docker run -d -p 9090:9090 --name prometheus -v /path/to/prometheus.yml:/etc/prometheus/prometheus.yml prom/prometheus
docker run -d -p 3000:3000 --name grafana grafana/grafana
```

## 九、自动化部署流程

### 1. 使用 Jenkins（可选）

安装 Jenkins：

```bash
# CentOS
sudo wget -O /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat-stable/jenkins.repo
sudo rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io-2023.key
sudo yum install -y jenkins java-11-openjdk-devel
sudo systemctl start jenkins
sudo systemctl enable jenkins

# Ubuntu
wget -q -O - https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key | sudo apt-key add -
sudo sh -c 'echo deb https://pkg.jenkins.io/debian-stable binary/ > /etc/apt/sources.list.d/jenkins.list'
sudo apt update
sudo apt install -y jenkins
sudo systemctl start jenkins
sudo systemctl enable jenkins
```

访问 `http://服务器IP:8080` 完成 Jenkins 初始设置。

### 2. 创建 Jenkins 任务

1. 创建新任务 > 流水线（Pipeline）
2. 配置 Git 仓库
3. 编写 Pipeline 脚本：

```groovy
pipeline {
    agent any
    
    stages {
        stage('Checkout') {
            steps {
                git 'https://github.com/username/repo.git'
            }
        }
        
        stage('Build') {
            steps {
                sh 'mvn clean package -Dmaven.test.skip=true'
            }
        }
        
        stage('Deploy') {
            steps {
                sh 'cp target/*.jar /opt/springapp/app.jar'
                sh 'systemctl restart springapp'
            }
        }
    }
}
```

### 3. 配置 GitHub Webhook

在 GitHub 仓库中添加 Webhook，指向：`http://服务器IP:8080/github-webhook/`

## 十、常见问题与排错

### 1. 应用启动问题

- **查看应用日志**：
  ```bash
  tail -f /opt/springapp/logs/spring.log
  # 或使用 journalctl
  journalctl -u springapp -f
  ```

- **检查端口占用**：
  ```bash
  netstat -tulpn | grep 8080
  ```

- **检查内存和 CPU**：
  ```bash
  top
  ```

### 2. 数据库连接问题

- **测试数据库连接**：
  ```bash
  mysql -u springuser -p springapp -h localhost
  ```

- **检查数据库服务状态**：
  ```bash
  systemctl status mysql
  ```

### 3. Nginx 配置问题

- **测试 Nginx 配置**：
  ```bash
  nginx -t
  ```

- **检查 Nginx 错误日志**：
  ```bash
  tail -f /var/log/nginx/error.log
  ```

### 4. 防火墙问题

- **检查防火墙状态**：
  ```bash
  # CentOS
  firewall-cmd --list-all
  
  # Ubuntu
  ufw status
  ```

### 5. 内存不足

- **添加交换空间**：
  ```bash
  # 创建 2GB 交换文件
  dd if=/dev/zero of=/swapfile bs=1M count=2048
  chmod 600 /swapfile
  mkswap /swapfile
  swapon /swapfile
  
  # 开机自动启用
  echo '/swapfile none swap sw 0 0' | tee -a /etc/fstab
  ```

- **优化 JVM 参数**：
  修改启动脚本，添加内存限制：
  ```bash
  java -Xms512m -Xmx1024m -jar app.jar
  ```

## 十一、安全最佳实践

### 1. 定期更新系统

```bash
# CentOS
yum update -y

# Ubuntu
apt update && apt upgrade -y
```

### 2. 使用 fail2ban 防止暴力破解

```bash
# CentOS
yum install -y fail2ban
systemctl enable fail2ban
systemctl start fail2ban

# Ubuntu
apt install -y fail2ban
systemctl enable fail2ban
systemctl start fail2ban
```

### 3. 禁用 root SSH 登录

编辑 SSH 配置文件：

```bash
vi /etc/ssh/sshd_config
```

修改配置：

```
PermitRootLogin no
```

重启 SSH 服务：

```bash
systemctl restart sshd
```

### 4. 定期备份数据

创建备份脚本：

```bash
vi /opt/scripts/backup.sh
```

添加内容：

```bash
#!/bin/bash
DATE=$(date +%Y%m%d)
BACKUP_DIR="/opt/backups"
mkdir -p $BACKUP_DIR

# 备份数据库
mysqldump -u springuser -p'密码' springapp > $BACKUP_DIR/springapp_$DATE.sql

# 备份应用和配置
tar -zcf $BACKUP_DIR/springapp_files_$DATE.tar.gz /opt/springapp

# 保留30天的备份
find $BACKUP_DIR -name "*.sql" -mtime +30 -delete
find $BACKUP_DIR -name "*.tar.gz" -mtime +30 -delete
```

设置执行权限并添加定时任务：

```bash
chmod +x /opt/scripts/backup.sh
crontab -e
```

添加定时任务：

```
0 2 * * * /opt/scripts/backup.sh > /dev/null 2>&1
```

## 参考资源

- [Spring Boot 官方文档](https://spring.io/projects/spring-boot)
- [MySQL 官方文档](https://dev.mysql.com/doc/)
- [Nginx 官方文档](https://nginx.org/en/docs/)
- [宝塔面板官网](https://www.bt.cn/)
- [Jenkins 官方文档](https://www.jenkins.io/doc/)

---

本指南详细介绍了从零开始将 SpringBoot 项目部署到服务器的完整流程。无论你是初学者还是有经验的开发者，按照这些步骤，都能成功搭建一个稳定、安全、高效的生产环境。如有疑问，欢迎在评论区留言交流！