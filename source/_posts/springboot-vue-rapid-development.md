---
title: Spring Boot + Vue 快速开发流程指南 - 小公司实用版
date: 2025-08-25 14:00:00
categories: 技术分享
tags:
  - Spring Boot
  - Vue
  - 快速开发
  - 小团队
  - 项目管理
  - 代码规范
cover_picture: https://images.unsplash.com/photo-1460925895917-afdab827c52f?w=800&h=400&fit=crop&crop=center
---

# Spring Boot + Vue 快速开发流程指南 - 小公司实用版

> 专为小公司和小团队量身定制的Spring Boot + Vue快速开发流程，精简步骤，突出重点，确保代码质量和项目可维护性。适合3-8人的开发团队，项目周期2-6周。

<!-- more -->

## 快速开发流程概览

小公司开发通常时间紧、人手少，我们将流程精简为**5个核心阶段**：

1. **需求梳理与原型设计** (2-3天) - 明确做什么
2. **数据库与接口设计** (2-3天) - 设计怎么做  
3. **并行开发实施** (10-20天) - 具体实现
4. **联调测试部署** (3-5天) - 验证上线
5. **运维监控** (持续) - 保障稳定

**核心理念**：先把架子搭好，再填充功能，确保代码易维护、易扩展。

---

## 第一阶段：需求梳理与原型设计 (2-3天)

### 1.1 快速需求梳理

**目标**：30分钟内搞清楚要做什么

**需求收集模板**：
```markdown
## 项目基本信息
- 项目名称：XX管理系统
- 核心目标：解决什么问题
- 用户角色：谁会用这个系统
- 核心功能：最重要的3-5个功能

## 功能清单（按优先级排序）
### P0 (必须有，第一版上线)
- [ ] 用户登录注册
- [ ] 核心业务功能1
- [ ] 核心业务功能2

### P1 (重要，第二版)
- [ ] 数据统计
- [ ] 权限管理

### P2 (可选，有时间再做)
- [ ] 高级功能
```

### 1.2 快速原型设计

**工具推荐**：
- 画原型：墨刀、Figma、甚至手画都行
- 画流程图：ProcessOn、draw.io

**原型要求**：
- 主要页面布局（不需要很精美）
- 核心操作流程
- 数据展示方式

**输出物**：
- 需求文档（1页A4纸即可）
- 简单原型图
- 核心业务流程图

---

## 第二阶段：数据库与接口设计 (2-3天) ⭐核心⭐

### 2.1 数据库设计 - 从需求到表结构

#### 2.1.1 需求分析到实体设计

**实例：简单的博客系统需求**
> 需求：用户可以注册登录，发布文章，其他用户可以评论

**第1步：提取核心实体**
```
用户 -> User表
文章 -> Article表  
评论 -> Comment表
```

**第2步：分析实体关系**
```
User 1:N Article (一个用户可以写多篇文章)
Article 1:N Comment (一篇文章可以有多条评论)
User 1:N Comment (一个用户可以写多条评论)
```

**第3步：设计表结构**

```sql
-- 用户表
CREATE TABLE t_user (
    id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '主键ID',
    username VARCHAR(50) NOT NULL UNIQUE COMMENT '用户名',
    password VARCHAR(255) NOT NULL COMMENT '密码(BCrypt加密)',
    nickname VARCHAR(100) COMMENT '昵称',
    email VARCHAR(100) COMMENT '邮箱',
    phone VARCHAR(20) COMMENT '手机号',
    avatar VARCHAR(255) COMMENT '头像URL',
    status TINYINT DEFAULT 1 COMMENT '状态 1-正常 0-禁用',
    create_time DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    update_time DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    
    INDEX idx_username (username),
    INDEX idx_email (email),
    INDEX idx_create_time (create_time)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='用户表';

-- 文章表
CREATE TABLE t_article (
    id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '文章ID',
    title VARCHAR(200) NOT NULL COMMENT '文章标题',
    content TEXT NOT NULL COMMENT '文章内容',
    summary VARCHAR(500) COMMENT '文章摘要',
    cover_image VARCHAR(255) COMMENT '封面图',
    author_id BIGINT NOT NULL COMMENT '作者ID',
    view_count INT DEFAULT 0 COMMENT '浏览次数',
    like_count INT DEFAULT 0 COMMENT '点赞次数',
    comment_count INT DEFAULT 0 COMMENT '评论次数',
    status TINYINT DEFAULT 1 COMMENT '状态 1-发布 0-草稿 -1-删除',
    create_time DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    update_time DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    
    FOREIGN KEY (author_id) REFERENCES t_user(id),
    INDEX idx_author_id (author_id),
    INDEX idx_status_create_time (status, create_time),
    INDEX idx_title (title)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='文章表';

-- 评论表
CREATE TABLE t_comment (
    id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '评论ID',
    article_id BIGINT NOT NULL COMMENT '文章ID',
    user_id BIGINT NOT NULL COMMENT '评论用户ID',
    parent_id BIGINT DEFAULT 0 COMMENT '父评论ID，0表示顶级评论',
    content TEXT NOT NULL COMMENT '评论内容',
    like_count INT DEFAULT 0 COMMENT '点赞数',
    status TINYINT DEFAULT 1 COMMENT '状态 1-正常 0-隐藏 -1-删除',
    create_time DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    update_time DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    
    FOREIGN KEY (article_id) REFERENCES t_article(id),
    FOREIGN KEY (user_id) REFERENCES t_user(id),
    INDEX idx_article_id (article_id),
    INDEX idx_user_id (user_id),
    INDEX idx_parent_id (parent_id),
    INDEX idx_create_time (create_time)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='评论表';
```

#### 2.1.2 数据库设计最佳实践

**表设计规范**：
```sql
-- 1. 统一字段规范
id BIGINT PRIMARY KEY AUTO_INCREMENT  -- 主键统一用BIGINT
create_time DATETIME DEFAULT CURRENT_TIMESTAMP  -- 创建时间
update_time DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP  -- 更新时间
status TINYINT DEFAULT 1  -- 状态字段，用于逻辑删除

-- 2. 外键命名规范
user_id, article_id, parent_id  -- 外键用 目标表名_id

-- 3. 索引设计规范
-- 单列索引：经常用于WHERE条件的字段
-- 复合索引：经常一起查询的字段，区分度高的放前面
-- 例：idx_status_create_time (status, create_time)

-- 4. 字符集统一
DEFAULT CHARSET=utf8mb4  -- 支持emoji和特殊字符
```

### 2.2 统一接口设计 ⭐核心⭐

#### 2.2.1 RESTful API设计规范

**URL设计规范**：
```
GET    /api/v1/users          # 获取用户列表
GET    /api/v1/users/123      # 获取单个用户
POST   /api/v1/users          # 创建用户
PUT    /api/v1/users/123      # 更新用户
DELETE /api/v1/users/123      # 删除用户

GET    /api/v1/users/123/articles     # 获取某用户的文章列表
POST   /api/v1/articles               # 创建文章
GET    /api/v1/articles/456/comments  # 获取某文章的评论
```

#### 2.2.2 统一响应格式

**成功响应格式**：
```json
{
  "code": 200,
  "message": "操作成功",
  "data": {
    // 具体业务数据
  },
  "timestamp": 1692954000000
}
```

**错误响应格式**：
```json
{
  "code": 400,
  "message": "参数错误：用户名不能为空",
  "data": null,
  "timestamp": 1692954000000
}
```

**分页响应格式**：
```json
{
  "code": 200,
  "message": "查询成功",
  "data": {
    "records": [
      // 数据列表
    ],
    "total": 100,
    "current": 1,
    "size": 10,
    "pages": 10
  },
  "timestamp": 1692954000000
}
```

#### 2.2.3 错误码设计

```java
public enum ResultCode {
    SUCCESS(200, "操作成功"),
    
    // 客户端错误 4xx
    BAD_REQUEST(400, "请求参数错误"),
    UNAUTHORIZED(401, "未登录或token过期"),
    FORBIDDEN(403, "权限不足"),
    NOT_FOUND(404, "资源不存在"),
    
    // 业务错误 5xx
    INTERNAL_ERROR(500, "系统内部错误"),
    USER_NOT_EXIST(5001, "用户不存在"),
    USER_PASSWORD_ERROR(5002, "密码错误"),
    ARTICLE_NOT_EXIST(5003, "文章不存在");
    
    private final int code;
    private final String message;
}
```

### 2.3 接口文档设计

**使用Swagger自动生成接口文档**：

```java
@RestController
@RequestMapping("/api/v1/users")
@Api(tags = "用户管理")
public class UserController {
    
    @GetMapping
    @ApiOperation("获取用户列表")
    @ApiImplicitParams({
        @ApiImplicitParam(name = "current", value = "当前页", defaultValue = "1"),
        @ApiImplicitParam(name = "size", value = "页大小", defaultValue = "10"),
        @ApiImplicitParam(name = "keyword", value = "搜索关键词", required = false)
    })
    public ApiResponse<PageResult<UserVO>> getUserList(
            @RequestParam(defaultValue = "1") Integer current,
            @RequestParam(defaultValue = "10") Integer size,
            @RequestParam(required = false) String keyword) {
        // 实现逻辑
    }
    
    @PostMapping
    @ApiOperation("创建用户")
    public ApiResponse<Void> createUser(@Valid @RequestBody CreateUserRequest request) {
        // 实现逻辑
    }
}
```

---

## 第三阶段：并行开发实施 (10-20天)

### 3.1 项目架构搭建

#### 3.1.1 后端项目结构

```
src/main/java/com/company/project/
├── config/              # 配置类
│   ├── WebConfig.java
│   ├── SecurityConfig.java
│   └── SwaggerConfig.java
├── common/              # 公共组件
│   ├── result/          # 统一响应
│   │   ├── ApiResponse.java
│   │   ├── ResultCode.java
│   │   └── PageResult.java
│   ├── exception/       # 异常处理
│   │   ├── BusinessException.java
│   │   └── GlobalExceptionHandler.java
│   └── utils/           # 工具类
│       ├── JwtUtil.java
│       └── PasswordUtil.java
├── modules/             # 业务模块
│   ├── user/
│   │   ├── controller/
│   │   ├── service/
│   │   ├── repository/
│   │   └── dto/
│   ├── article/
│   └── comment/
└── Application.java     # 启动类
```

#### 3.1.2 前端项目结构

```
src/
├── api/                 # API接口
│   ├── user.js
│   ├── article.js
│   └── comment.js
├── components/          # 公共组件
│   ├── Layout/
│   ├── Table/
│   └── Form/
├── views/               # 页面
│   ├── user/
│   ├── article/
│   └── login/
├── router/              # 路由配置
├── store/               # 状态管理
├── utils/               # 工具函数
│   ├── request.js       # HTTP请求封装
│   ├── auth.js          # 认证工具
│   └── validate.js      # 表单验证
└── styles/              # 样式文件
```

### 3.2 核心代码实现

#### 3.2.1 后端核心代码

**统一响应封装**：
```java
@Data
@AllArgsConstructor
@NoArgsConstructor
public class ApiResponse<T> {
    private Integer code;
    private String message;
    private T data;
    private Long timestamp;
    
    public static <T> ApiResponse<T> success(T data) {
        return new ApiResponse<>(200, "操作成功", data, System.currentTimeMillis());
    }
    
    public static <T> ApiResponse<T> success(String message, T data) {
        return new ApiResponse<>(200, message, data, System.currentTimeMillis());
    }
    
    public static ApiResponse<Void> error(ResultCode resultCode) {
        return new ApiResponse<>(resultCode.getCode(), resultCode.getMessage(), null, System.currentTimeMillis());
    }
    
    public static ApiResponse<Void> error(Integer code, String message) {
        return new ApiResponse<>(code, message, null, System.currentTimeMillis());
    }
}
```

**全局异常处理**：
```java
@RestControllerAdvice
@Slf4j
public class GlobalExceptionHandler {
    
    @ExceptionHandler(BusinessException.class)
    public ApiResponse<Void> handleBusinessException(BusinessException e) {
        log.warn("业务异常：{}", e.getMessage());
        return ApiResponse.error(e.getCode(), e.getMessage());
    }
    
    @ExceptionHandler(MethodArgumentNotValidException.class)
    public ApiResponse<Void> handleValidationException(MethodArgumentNotValidException e) {
        String message = e.getBindingResult().getFieldError().getDefaultMessage();
        log.warn("参数校验失败：{}", message);
        return ApiResponse.error(400, message);
    }
    
    @ExceptionHandler(Exception.class)
    public ApiResponse<Void> handleException(Exception e) {
        log.error("系统异常", e);
        return ApiResponse.error(500, "系统内部错误");
    }
}
```

**用户Controller示例**：
```java
@RestController
@RequestMapping("/api/v1/users")
@Validated
@Slf4j
public class UserController {
    
    @Autowired
    private UserService userService;
    
    @GetMapping
    public ApiResponse<PageResult<UserVO>> getUserList(
            @RequestParam(defaultValue = "1") Integer current,
            @RequestParam(defaultValue = "10") Integer size,
            @RequestParam(required = false) String keyword) {
        
        PageResult<UserVO> result = userService.getUserList(current, size, keyword);
        return ApiResponse.success(result);
    }
    
    @PostMapping
    public ApiResponse<Void> createUser(@Valid @RequestBody CreateUserRequest request) {
        userService.createUser(request);
        return ApiResponse.success("用户创建成功", null);
    }
    
    @PutMapping("/{id}")
    public ApiResponse<Void> updateUser(@PathVariable Long id, @Valid @RequestBody UpdateUserRequest request) {
        userService.updateUser(id, request);
        return ApiResponse.success("用户更新成功", null);
    }
    
    @DeleteMapping("/{id}")
    public ApiResponse<Void> deleteUser(@PathVariable Long id) {
        userService.deleteUser(id);
        return ApiResponse.success("用户删除成功", null);
    }
}
```

**Service层实现**：
```java
@Service
@Transactional(rollbackFor = Exception.class)
@Slf4j
public class UserServiceImpl implements UserService {
    
    @Autowired
    private UserRepository userRepository;
    
    @Override
    public PageResult<UserVO> getUserList(Integer current, Integer size, String keyword) {
        // 构建查询条件
        Specification<User> spec = (root, query, cb) -> {
            List<Predicate> predicates = new ArrayList<>();
            
            if (StringUtils.hasText(keyword)) {
                predicates.add(cb.or(
                    cb.like(root.get("username"), "%" + keyword + "%"),
                    cb.like(root.get("nickname"), "%" + keyword + "%")
                ));
            }
            
            // 只查询正常状态的用户
            predicates.add(cb.equal(root.get("status"), 1));
            
            return cb.and(predicates.toArray(new Predicate[0]));
        };
        
        // 分页查询
        Pageable pageable = PageRequest.of(current - 1, size, 
            Sort.by(Sort.Direction.DESC, "createTime"));
        Page<User> userPage = userRepository.findAll(spec, pageable);
        
        // 转换为VO
        List<UserVO> userVOs = userPage.getContent().stream()
                .map(this::convertToVO)
                .collect(Collectors.toList());
                
        return PageResult.of(userVOs, userPage.getTotalElements(), current, size);
    }
    
    private UserVO convertToVO(User user) {
        UserVO vo = new UserVO();
        BeanUtils.copyProperties(user, vo);
        vo.setPassword(null); // 不返回密码
        return vo;
    }
}
```

#### 3.2.2 前端核心代码

**HTTP请求封装**：
```javascript
// utils/request.js
import axios from 'axios'
import { ElMessage, ElMessageBox } from 'element-plus'
import router from '@/router'

const request = axios.create({
  baseURL: import.meta.env.VITE_API_BASE_URL || '/api',
  timeout: 10000,
  headers: {
    'Content-Type': 'application/json'
  }
})

// 请求拦截器
request.interceptors.request.use(
  config => {
    const token = localStorage.getItem('access_token')
    if (token) {
      config.headers.Authorization = `Bearer ${token}`
    }
    return config
  },
  error => {
    console.error('请求错误:', error)
    return Promise.reject(error)
  }
)

// 响应拦截器
request.interceptors.response.use(
  response => {
    const { code, message, data } = response.data
    
    if (code === 200) {
      return data
    } else if (code === 401) {
      ElMessageBox.confirm('登录已过期，请重新登录', '提示', {
        confirmButtonText: '重新登录',
        cancelButtonText: '取消',
        type: 'warning'
      }).then(() => {
        localStorage.removeItem('access_token')
        router.push('/login')
      })
      return Promise.reject(new Error(message))
    } else {
      ElMessage.error(message || '请求失败')
      return Promise.reject(new Error(message))
    }
  },
  error => {
    console.error('响应错误:', error)
    if (error.response?.status === 401) {
      localStorage.removeItem('access_token')
      router.push('/login')
    } else {
      ElMessage.error(error.message || '网络错误')
    }
    return Promise.reject(error)
  }
)

export default request
```

**API封装**：
```javascript
// api/user.js
import request from '@/utils/request'

export const userApi = {
  // 获取用户列表
  getUserList(params) {
    return request({
      url: '/v1/users',
      method: 'get',
      params
    })
  },
  
  // 创建用户
  createUser(data) {
    return request({
      url: '/v1/users',
      method: 'post',
      data
    })
  },
  
  // 更新用户
  updateUser(id, data) {
    return request({
      url: `/v1/users/${id}`,
      method: 'put',
      data
    })
  },
  
  // 删除用户
  deleteUser(id) {
    return request({
      url: `/v1/users/${id}`,
      method: 'delete'
    })
  }
}
```

**用户管理页面**：
```vue
<template>
  <div class="user-management">
    <!-- 搜索栏 -->
    <div class="search-bar">
      <el-input 
        v-model="searchForm.keyword" 
        placeholder="搜索用户名或昵称"
        style="width: 200px;"
        @keyup.enter="handleSearch">
        <template #append>
          <el-button @click="handleSearch">搜索</el-button>
        </template>
      </el-input>
      <el-button type="primary" @click="handleCreate">新增用户</el-button>
    </div>
    
    <!-- 用户表格 -->
    <el-table :data="userList" v-loading="loading" stripe>
      <el-table-column prop="id" label="ID" width="80" />
      <el-table-column prop="username" label="用户名" />
      <el-table-column prop="nickname" label="昵称" />
      <el-table-column prop="email" label="邮箱" />
      <el-table-column prop="createTime" label="创建时间" />
      <el-table-column label="状态" width="80">
        <template #default="scope">
          <el-tag :type="scope.row.status === 1 ? 'success' : 'danger'">
            {{ scope.row.status === 1 ? '正常' : '禁用' }}
          </el-tag>
        </template>
      </el-table-column>
      <el-table-column label="操作" width="150" fixed="right">
        <template #default="scope">
          <el-button size="small" @click="handleEdit(scope.row)">编辑</el-button>
          <el-button size="small" type="danger" @click="handleDelete(scope.row)">删除</el-button>
        </template>
      </el-table-column>
    </el-table>
    
    <!-- 分页 -->
    <div class="pagination">
      <el-pagination
        v-model:current-page="pagination.current"
        v-model:page-size="pagination.size"
        :total="pagination.total"
        :page-sizes="[10, 20, 50, 100]"
        layout="total, sizes, prev, pager, next, jumper"
        @size-change="loadUserList"
        @current-change="loadUserList"
      />
    </div>
  </div>
</template>

<script setup>
import { ref, reactive, onMounted } from 'vue'
import { userApi } from '@/api/user'
import { ElMessage, ElMessageBox } from 'element-plus'

// 响应式数据
const loading = ref(false)
const userList = ref([])
const searchForm = reactive({
  keyword: ''
})
const pagination = reactive({
  current: 1,
  size: 10,
  total: 0
})

// 加载用户列表
const loadUserList = async () => {
  loading.value = true
  try {
    const params = {
      current: pagination.current,
      size: pagination.size,
      keyword: searchForm.keyword || undefined
    }
    
    const result = await userApi.getUserList(params)
    userList.value = result.records
    pagination.total = result.total
  } catch (error) {
    ElMessage.error('加载用户列表失败')
  } finally {
    loading.value = false
  }
}

// 搜索
const handleSearch = () => {
  pagination.current = 1
  loadUserList()
}

// 新增用户
const handleCreate = () => {
  // 跳转到用户创建页面或打开弹框
  console.log('创建用户')
}

// 编辑用户
const handleEdit = (user) => {
  // 跳转到用户编辑页面或打开弹框
  console.log('编辑用户', user)
}

// 删除用户
const handleDelete = async (user) => {
  try {
    await ElMessageBox.confirm(`确定删除用户"${user.username}"吗？`, '确认删除', {
      type: 'warning'
    })
    
    await userApi.deleteUser(user.id)
    ElMessage.success('删除成功')
    loadUserList()
  } catch (error) {
    if (error !== 'cancel') {
      ElMessage.error('删除失败')
    }
  }
}

// 页面加载时获取数据
onMounted(() => {
  loadUserList()
})
</script>

<style scoped>
.user-management {
  padding: 20px;
}

.search-bar {
  display: flex;
  gap: 10px;
  margin-bottom: 20px;
}

.pagination {
  margin-top: 20px;
  text-align: right;
}
</style>
```

### 3.3 开发协作规范

#### 3.3.1 Git工作流

```bash
# 主分支规范
main/master  -> 生产环境，只能通过PR合并
develop     -> 开发环境，功能分支合并到这里
feature/*   -> 功能分支，从develop分出

# 分支命名规范
feature/user-management    # 用户管理功能
feature/article-crud       # 文章增删改查
bugfix/login-error         # 登录错误修复
hotfix/security-patch      # 紧急安全补丁

# 提交信息规范
feat: 添加用户管理功能
fix: 修复登录验证问题  
docs: 更新API文档
style: 代码格式调整
refactor: 重构用户服务
test: 添加用户服务测试
```

#### 3.3.2 代码审查checklist

```markdown
## 后端代码审查
- [ ] 是否遵循统一的响应格式
- [ ] 是否有适当的异常处理
- [ ] 是否有参数校验
- [ ] 数据库操作是否有事务管理
- [ ] 是否有SQL注入风险
- [ ] 敏感数据是否加密处理

## 前端代码审查  
- [ ] 组件是否可复用
- [ ] 是否有适当的错误处理
- [ ] 是否有loading状态
- [ ] 表单是否有校验
- [ ] 是否遵循组件命名规范
- [ ] 样式是否响应式
```

---

## 第四阶段：联调测试部署 (3-5天)

### 4.1 前后端联调

#### 4.1.1 联调环境准备

**后端配置**：
```yaml
# application-dev.yml
spring:
  datasource:
    url: jdbc:mysql://localhost:3306/project_dev?useSSL=false&allowPublicKeyRetrieval=true
    username: root
    password: ${DB_PASSWORD:123456}
  
  # 跨域配置
  web:
    cors:
      allowed-origins: "http://localhost:5173"
      allowed-methods: "*"
      allowed-headers: "*"
      allow-credentials: true
```

**前端配置**：
```javascript
// vite.config.js
export default defineConfig({
  server: {
    port: 5173,
    proxy: {
      '/api': {
        target: 'http://localhost:8080',
        changeOrigin: true,
        rewrite: (path) => path.replace(/^\/api/, '/api')
      }
    }
  }
})
```

#### 4.1.2 联调测试重点

```markdown
## 联调测试清单
### 基础功能测试
- [ ] 登录注册流程
- [ ] 权限验证（token过期处理）
- [ ] 数据增删改查
- [ ] 分页查询
- [ ] 文件上传下载

### 异常场景测试
- [ ] 网络错误处理
- [ ] 参数校验错误
- [ ] 权限不足错误
- [ ] 服务器错误处理

### 性能测试
- [ ] 页面加载速度
- [ ] 接口响应时间
- [ ] 大数据量列表展示
```

### 4.2 快速部署

#### 4.2.1 使用Docker容器化部署

**后端Dockerfile**：
```dockerfile
FROM openjdk:17-jdk-slim

WORKDIR /app

COPY target/*.jar app.jar

EXPOSE 8080

CMD ["java", "-jar", "-Dspring.profiles.active=prod", "app.jar"]
```

**前端Dockerfile**：
```dockerfile
# 构建阶段
FROM node:16-alpine AS builder

WORKDIR /app
COPY package*.json ./
RUN npm ci --only=production

COPY . .
RUN npm run build

# 运行阶段
FROM nginx:alpine

COPY --from=builder /app/dist /usr/share/nginx/html
COPY nginx.conf /etc/nginx/nginx.conf

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
```

**docker-compose.yml**：
```yaml
version: '3.8'

services:
  mysql:
    image: mysql:8.0
    environment:
      MYSQL_ROOT_PASSWORD: ${MYSQL_ROOT_PASSWORD}
      MYSQL_DATABASE: ${MYSQL_DATABASE}
    volumes:
      - mysql_data:/var/lib/mysql
      - ./init.sql:/docker-entrypoint-initdb.d/init.sql
    ports:
      - "3306:3306"
    
  redis:
    image: redis:6-alpine
    ports:
      - "6379:6379"
    
  backend:
    build: ./backend
    environment:
      - SPRING_PROFILES_ACTIVE=prod
      - DB_HOST=mysql
      - DB_PASSWORD=${MYSQL_ROOT_PASSWORD}
      - REDIS_HOST=redis
    depends_on:
      - mysql
      - redis
    ports:
      - "8080:8080"
  
  frontend:
    build: ./frontend
    ports:
      - "80:80"
    depends_on:
      - backend

volumes:
  mysql_data:
```

#### 4.2.2 一键部署脚本

```bash
#!/bin/bash
# deploy.sh

echo "开始部署应用..."

# 1. 停止旧容器
docker-compose down

# 2. 构建新镜像
echo "构建后端镜像..."
cd backend
mvn clean package -DskipTests
cd ..

echo "构建前端镜像..."
cd frontend  
npm run build
cd ..

# 3. 启动新容器
echo "启动应用容器..."
docker-compose up -d

# 4. 等待服务启动
echo "等待服务启动..."
sleep 30

# 5. 健康检查
echo "检查服务状态..."
if curl -f http://localhost:8080/actuator/health; then
  echo "后端服务启动成功"
else
  echo "后端服务启动失败"
  exit 1
fi

if curl -f http://localhost/; then
  echo "前端服务启动成功"
else
  echo "前端服务启动失败"
  exit 1
fi

echo "部署完成！"
echo "前端地址: http://localhost"
echo "后端地址: http://localhost:8080"
echo "API文档: http://localhost:8080/swagger-ui.html"
```

### 4.3 简单监控

#### 4.3.1 基础监控配置

**Spring Boot Actuator**：
```yaml
# application-prod.yml
management:
  endpoints:
    web:
      exposure:
        include: health,info,metrics
  endpoint:
    health:
      show-details: always
```

**简单的监控脚本**：
```bash
#!/bin/bash
# monitor.sh

# 检查服务状态
check_service() {
    local service_name=$1
    local health_url=$2
    
    if curl -f -s $health_url > /dev/null; then
        echo "✅ $service_name 正常运行"
    else
        echo "❌ $service_name 服务异常"
        # 可以在这里添加告警通知
        # 比如发送邮件或钉钉消息
    fi
}

echo "=== 服务健康检查 ==="
check_service "后端服务" "http://localhost:8080/actuator/health"
check_service "前端服务" "http://localhost/"

# 检查数据库连接
if docker exec project_mysql mysqladmin ping -h localhost -u root -p${MYSQL_ROOT_PASSWORD} --silent; then
    echo "✅ 数据库连接正常"
else
    echo "❌ 数据库连接异常"
fi

# 检查磁盘空间
disk_usage=$(df -h / | awk 'NR==2 {print $5}' | sed 's/%//')
if [ $disk_usage -gt 80 ]; then
    echo "⚠️  磁盘使用率过高: ${disk_usage}%"
else
    echo "✅ 磁盘使用率正常: ${disk_usage}%"
fi

echo "=== 检查完成 ==="
```

---

## 第五阶段：运维监控 (持续)

### 5.1 日志管理

#### 5.1.1 结构化日志配置

```xml
<!-- logback-spring.xml -->
<configuration>
    <springProfile name="prod">
        <!-- 控制台输出 -->
        <appender name="CONSOLE" class="ch.qos.logback.core.ConsoleAppender">
            <encoder class="net.logstash.logback.encoder.LoggingEventCompositeJsonEncoder">
                <providers>
                    <timestamp/>
                    <logLevel/>
                    <loggerName/>
                    <message/>
                    <mdc/>
                </providers>
            </encoder>
        </appender>
        
        <!-- 文件输出 -->
        <appender name="FILE" class="ch.qos.logback.core.rolling.RollingFileAppender">
            <file>logs/application.log</file>
            <rollingPolicy class="ch.qos.logback.core.rolling.TimeBasedRollingPolicy">
                <fileNamePattern>logs/application.%d{yyyy-MM-dd}.log</fileNamePattern>
                <maxHistory>7</maxHistory>
                <totalSizeCap>1GB</totalSizeCap>
            </rollingPolicy>
            <encoder class="net.logstash.logback.encoder.LoggingEventCompositeJsonEncoder">
                <providers>
                    <timestamp/>
                    <logLevel/>
                    <loggerName/>
                    <message/>
                    <mdc/>
                    <stackTrace/>
                </providers>
            </encoder>
        </appender>
        
        <root level="INFO">
            <appender-ref ref="CONSOLE"/>
            <appender-ref ref="FILE"/>
        </root>
    </springProfile>
</configuration>
```

#### 5.1.2 业务日志记录

```java
@Component
@Slf4j
public class BusinessLogAspect {
    
    @Around("@annotation(businessLog)")
    public Object logBusiness(ProceedingJoinPoint joinPoint, BusinessLog businessLog) throws Throwable {
        String operation = businessLog.value();
        String className = joinPoint.getTarget().getClass().getSimpleName();
        String methodName = joinPoint.getSignature().getName();
        
        // 记录操作开始
        MDC.put("operation", operation);
        MDC.put("class", className);
        MDC.put("method", methodName);
        
        log.info("业务操作开始: {}", operation);
        
        try {
            Object result = joinPoint.proceed();
            log.info("业务操作成功: {}", operation);
            return result;
        } catch (Exception e) {
            log.error("业务操作失败: {}, 错误: {}", operation, e.getMessage());
            throw e;
        } finally {
            MDC.clear();
        }
    }
}

// 使用示例
@PostMapping
@BusinessLog("创建用户")
public ApiResponse<Void> createUser(@RequestBody CreateUserRequest request) {
    userService.createUser(request);
    return ApiResponse.success("用户创建成功", null);
}
```

### 5.2 备份策略

#### 5.2.1 数据库备份脚本

```bash
#!/bin/bash
# backup.sh

# 配置
DB_HOST="localhost"
DB_USER="root"
DB_PASSWORD="your_password"
DB_NAME="your_database"
BACKUP_DIR="/backups/mysql"
DATE=$(date +%Y%m%d_%H%M%S)

# 创建备份目录
mkdir -p $BACKUP_DIR

# 执行备份
mysqldump -h $DB_HOST -u $DB_USER -p$DB_PASSWORD \
  --single-transaction \
  --routines \
  --triggers \
  $DB_NAME > $BACKUP_DIR/${DB_NAME}_${DATE}.sql

# 压缩备份文件
gzip $BACKUP_DIR/${DB_NAME}_${DATE}.sql

# 清理7天前的备份
find $BACKUP_DIR -name "*.gz" -mtime +7 -delete

echo "数据库备份完成: ${DB_NAME}_${DATE}.sql.gz"
```

#### 5.2.2 应用备份脚本

```bash
#!/bin/bash
# app_backup.sh

BACKUP_DIR="/backups/app"
DATE=$(date +%Y%m%d_%H%M%S)
APP_DIR="/app"

# 创建备份目录
mkdir -p $BACKUP_DIR

# 备份应用文件
tar -czf $BACKUP_DIR/app_${DATE}.tar.gz \
  -C $APP_DIR \
  --exclude=logs \
  --exclude=tmp \
  .

# 清理30天前的应用备份
find $BACKUP_DIR -name "app_*.tar.gz" -mtime +30 -delete

echo "应用备份完成: app_${DATE}.tar.gz"
```

---

## 开发效率提升技巧

### 1. 代码生成器

#### 1.1 MyBatis-Plus代码生成

```java
public class CodeGenerator {
    public static void main(String[] args) {
        FastAutoGenerator.create("jdbc:mysql://localhost:3306/test", "root", "password")
                .globalConfig(builder -> {
                    builder.author("your-name")
                            .outputDir("src/main/java")
                            .disableOpenDir();
                })
                .packageConfig(builder -> {
                    builder.parent("com.company.project")
                            .entity("entity")
                            .service("service")
                            .serviceImpl("service.impl")
                            .controller("controller")
                            .mapper("mapper");
                })
                .strategyConfig(builder -> {
                    builder.addInclude("t_user", "t_article", "t_comment")
                            .controllerBuilder()
                            .enableRestStyle()
                            .enableHyphenStyle()
                            .entityBuilder()
                            .enableLombok()
                            .addTableFills(
                                    new Column("create_time", FieldFill.INSERT),
                                    new Column("update_time", FieldFill.INSERT_UPDATE)
                            )
                            .serviceBuilder()
                            .formatServiceFileName("%sService");
                })
                .execute();
    }
}
```

### 2. 开发工具配置

#### 2.1 IDEA Live Templates

**创建Controller模板**：
```java
@RestController
@RequestMapping("/api/v1/$RESOURCE$")
@Api(tags = "$DESCRIPTION$")
public class $NAME$Controller {
    
    @Autowired
    private $SERVICE$ $SERVICE_VAR$;
    
    @GetMapping
    @ApiOperation("获取$DESCRIPTION$列表")
    public ApiResponse<PageResult<$VO$>> get$NAME$List(
            @RequestParam(defaultValue = "1") Integer current,
            @RequestParam(defaultValue = "10") Integer size) {
        PageResult<$VO$> result = $SERVICE_VAR$.get$NAME$List(current, size);
        return ApiResponse.success(result);
    }
}
```

#### 2.2 Vue代码片段

```json
{
  "Vue List Page": {
    "prefix": "vue-list",
    "body": [
      "<template>",
      "  <div class=\"$1-list\">",
      "    <el-table :data=\"dataList\" v-loading=\"loading\">",
      "      <el-table-column prop=\"id\" label=\"ID\" width=\"80\" />",
      "      <el-table-column label=\"操作\" width=\"150\">",
      "        <template #default=\"scope\">",
      "          <el-button size=\"small\" @click=\"handleEdit(scope.row)\">编辑</el-button>",
      "        </template>",
      "      </el-table-column>",
      "    </el-table>",
      "    <el-pagination",
      "      v-model:current-page=\"pagination.current\"",
      "      v-model:page-size=\"pagination.size\"",
      "      :total=\"pagination.total\"",
      "      @current-change=\"loadData\"",
      "    />",
      "  </div>",
      "</template>",
      "",
      "<script setup>",
      "import { ref, reactive, onMounted } from 'vue'",
      "",
      "const loading = ref(false)",
      "const dataList = ref([])",
      "const pagination = reactive({",
      "  current: 1,",
      "  size: 10,",
      "  total: 0",
      "})",
      "",
      "const loadData = async () => {",
      "  loading.value = true",
      "  try {",
      "    // TODO: 实现数据加载",
      "  } finally {",
      "    loading.value = false",
      "  }",
      "}",
      "",
      "onMounted(() => {",
      "  loadData()",
      "})",
      "</script>"
    ]
  }
}
```

---

## 常见问题与解决方案

### 1. 跨域问题
```java
@Configuration
public class CorsConfig implements WebMvcConfigurer {
    @Override
    public void addCorsMappings(CorsRegistry registry) {
        registry.addMapping("/**")
                .allowedOriginPatterns("*")
                .allowedMethods("*")
                .allowedHeaders("*")
                .allowCredentials(true);
    }
}
```

### 2. 文件上传
```java
@PostMapping("/upload")
public ApiResponse<String> uploadFile(@RequestParam("file") MultipartFile file) {
    if (file.isEmpty()) {
        return ApiResponse.error(400, "文件不能为空");
    }
    
    // 生成文件名
    String fileName = UUID.randomUUID().toString() + "." + 
        FilenameUtils.getExtension(file.getOriginalFilename());
    
    // 保存文件
    String uploadDir = "/uploads/";
    File dest = new File(uploadDir + fileName);
    dest.getParentFile().mkdirs();
    
    try {
        file.transferTo(dest);
        return ApiResponse.success("/uploads/" + fileName);
    } catch (IOException e) {
        return ApiResponse.error(500, "文件上传失败");
    }
}
```

### 3. 数据权限控制
```java
@PreAuthorize("hasRole('ADMIN') or @dataPermissionService.hasDataPermission(authentication.name, #userId)")
@GetMapping("/{userId}/articles")
public ApiResponse<List<Article>> getUserArticles(@PathVariable Long userId) {
    // 实现逻辑
}
```

---

## 总结

这份快速开发指南专门为小公司和小团队设计，核心特点：

### ✅ 精简高效
- 5个核心阶段，去除冗余步骤
- 重点关注数据库设计和接口统一
- 并行开发，缩短项目周期

### ✅ 代码质量
- 统一的响应格式和错误处理
- 规范的项目结构和命名
- 完善的异常处理机制

### ✅ 易于维护
- 清晰的分层架构
- 标准化的接口设计
- 完整的日志和监控

### ✅ 快速部署
- Docker容器化部署
- 一键部署脚本
- 简单的监控方案

**记住**：小公司开发最重要的不是流程有多完美，而是**快速交付有价值的产品**，同时**保证代码质量和可维护性**。

这套流程在保证质量的前提下，能让3-5人的小团队在2-4周内完成一个完整的Web项目。关键是**先把架子搭好，再逐步完善功能**。

如果你有任何问题或想要具体某个部分的详细说明，欢迎留言交流！
