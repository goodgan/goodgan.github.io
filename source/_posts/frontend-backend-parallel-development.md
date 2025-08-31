---
title: 前后端并行开发的接口协作详细指南
date: 2025-08-25 14:30:00
categories: 技术分享
tags:
  - 前后端分离
  - 接口协作
  - Mock数据
  - 并行开发
  - 团队协作
cover_picture: https://images.unsplash.com/photo-1517180102446-f3ece451e9d8?w=800&h=400&fit=crop&crop=center
---

# 前后端并行开发的接口协作详细指南

> 详细解答前后端并行开发中的核心问题：如何基于接口文档进行协作？Mock数据如何生成？如何实现前端无缝切换到真实后端？

<!-- more -->

## 核心问题解答

提出的问题是前后端分离开发中最关键的协作问题。让我们通过一个完整的实例来解答：

### 问题1：前后端同时开发根据什么？
**答案**：基于**接口文档**和**数据结构约定**

### 问题2：接口文档的数据怎么做？
**答案**：使用**Mock数据**和**接口模拟服务**

### 问题3：如何实现前端无缝切换到真实后端？
**答案**：通过**环境配置**和**统一的请求封装**

---

## 完整协作流程实例

### 第一步：制定接口文档和数据结构

#### 1.1 使用Swagger/OpenAPI定义接口

**后端定义接口规范**：
```java
// 用户Controller - 先定义接口，不实现具体逻辑
@RestController
@RequestMapping("/api/v1/users")
@Api(tags = "用户管理")
public class UserController {
    
    @GetMapping
    @ApiOperation("获取用户列表")
    @ApiResponses({
        @ApiResponse(code = 200, message = "成功", response = UserListResponse.class)
    })
    public ApiResponse<PageResult<UserVO>> getUserList(
            @ApiParam("当前页") @RequestParam(defaultValue = "1") Integer current,
            @ApiParam("页大小") @RequestParam(defaultValue = "10") Integer size,
            @ApiParam("搜索关键词") @RequestParam(required = false) String keyword) {
        
        // TODO: 临时返回Mock数据，供前端开发使用
        return mockUserListResponse(current, size, keyword);
    }
    
    @PostMapping
    @ApiOperation("创建用户")
    public ApiResponse<UserVO> createUser(@RequestBody @Valid CreateUserRequest request) {
        // TODO: 临时返回Mock数据
        return mockCreateUserResponse(request);
    }
    
    // Mock数据方法 - 仅供开发期使用
    private ApiResponse<PageResult<UserVO>> mockUserListResponse(Integer current, Integer size, String keyword) {
        List<UserVO> users = Arrays.asList(
            new UserVO(1L, "zhangsan", "张三", "zhangsan@example.com", "13800138001", 1, "2023-01-01 10:00:00"),
            new UserVO(2L, "lisi", "李四", "lisi@example.com", "13800138002", 1, "2023-01-02 11:00:00"),
            new UserVO(3L, "wangwu", "王五", "wangwu@example.com", "13800138003", 0, "2023-01-03 12:00:00")
        );
        
        // 模拟搜索逻辑
        if (StringUtils.hasText(keyword)) {
            users = users.stream()
                    .filter(user -> user.getUsername().contains(keyword) || user.getNickname().contains(keyword))
                    .collect(Collectors.toList());
        }
        
        // 模拟分页
        int start = (current - 1) * size;
        int end = Math.min(start + size, users.size());
        List<UserVO> pageUsers = users.subList(start, end);
        
        PageResult<UserVO> pageResult = PageResult.of(pageUsers, (long) users.size(), current, size);
        return ApiResponse.success(pageResult);
    }
}
```

#### 1.2 定义数据传输对象(DTO/VO)

```java
// 用户视图对象
@Data
@ApiModel("用户信息")
public class UserVO {
    @ApiModelProperty("用户ID")
    private Long id;
    
    @ApiModelProperty("用户名")
    private String username;
    
    @ApiModelProperty("昵称")
    private String nickname;
    
    @ApiModelProperty("邮箱")
    private String email;
    
    @ApiModelProperty("手机号")
    private String phone;
    
    @ApiModelProperty("状态：1-正常，0-禁用")
    private Integer status;
    
    @ApiModelProperty("创建时间")
    private String createTime;
    
    // 构造函数
    public UserVO(Long id, String username, String nickname, String email, String phone, Integer status, String createTime) {
        this.id = id;
        this.username = username;
        this.nickname = nickname;
        this.email = email;
        this.phone = phone;
        this.status = status;
        this.createTime = createTime;
    }
}

// 创建用户请求对象
@Data
@ApiModel("创建用户请求")
public class CreateUserRequest {
    @ApiModelProperty(value = "用户名", required = true)
    @NotBlank(message = "用户名不能为空")
    private String username;
    
    @ApiModelProperty(value = "密码", required = true)
    @NotBlank(message = "密码不能为空")
    private String password;
    
    @ApiModelProperty("昵称")
    private String nickname;
    
    @ApiModelProperty("邮箱")
    @Email(message = "邮箱格式不正确")
    private String email;
    
    @ApiModelProperty("手机号")
    private String phone;
}

// 统一分页结果
@Data
@ApiModel("分页结果")
public class PageResult<T> {
    @ApiModelProperty("数据列表")
    private List<T> records;
    
    @ApiModelProperty("总数")
    private Long total;
    
    @ApiModelProperty("当前页")
    private Integer current;
    
    @ApiModelProperty("页大小")
    private Integer size;
    
    @ApiModelProperty("总页数")
    private Integer pages;
    
    public static <T> PageResult<T> of(List<T> records, Long total, Integer current, Integer size) {
        PageResult<T> result = new PageResult<>();
        result.setRecords(records);
        result.setTotal(total);
        result.setCurrent(current);
        result.setSize(size);
        result.setPages((int) Math.ceil((double) total / size));
        return result;
    }
}
```

### 第二步：启动Mock后端服务

#### 2.1 创建Mock版本的Controller

```java
@RestController
@RequestMapping("/api/v1/users")
@Profile("mock")  // 只在mock环境下启用
public class MockUserController {
    
    @GetMapping
    public ApiResponse<PageResult<UserVO>> getUserList(
            @RequestParam(defaultValue = "1") Integer current,
            @RequestParam(defaultValue = "10") Integer size,
            @RequestParam(required = false) String keyword) {
        
        // 返回固定的Mock数据
        List<UserVO> users = generateMockUsers();
        
        // 模拟搜索
        if (StringUtils.hasText(keyword)) {
            users = users.stream()
                    .filter(user -> user.getUsername().contains(keyword) || user.getNickname().contains(keyword))
                    .collect(Collectors.toList());
        }
        
        // 模拟分页
        int start = (current - 1) * size;
        int end = Math.min(start + size, users.size());
        List<UserVO> pageUsers = users.subList(start, end);
        
        // 模拟网络延迟
        try {
            Thread.sleep(200);
        } catch (InterruptedException e) {
            Thread.currentThread().interrupt();
        }
        
        PageResult<UserVO> pageResult = PageResult.of(pageUsers, (long) users.size(), current, size);
        return ApiResponse.success(pageResult);
    }
    
    @PostMapping
    public ApiResponse<UserVO> createUser(@RequestBody CreateUserRequest request) {
        // 模拟创建用户
        UserVO newUser = new UserVO(
            System.currentTimeMillis(), // 使用时间戳作为ID
            request.getUsername(),
            request.getNickname(),
            request.getEmail(),
            request.getPhone(),
            1,
            LocalDateTime.now().format(DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss"))
        );
        
        // 模拟网络延迟
        try {
            Thread.sleep(500);
        } catch (InterruptedException e) {
            Thread.currentThread().interrupt();
        }
        
        return ApiResponse.success(newUser);
    }
    
    @PutMapping("/{id}")
    public ApiResponse<Void> updateUser(@PathVariable Long id, @RequestBody CreateUserRequest request) {
        // 模拟更新延迟
        try {
            Thread.sleep(300);
        } catch (InterruptedException e) {
            Thread.currentThread().interrupt();
        }
        
        return ApiResponse.success("用户更新成功", null);
    }
    
    @DeleteMapping("/{id}")
    public ApiResponse<Void> deleteUser(@PathVariable Long id) {
        // 模拟删除延迟
        try {
            Thread.sleep(200);
        } catch (InterruptedException e) {
            Thread.currentThread().interrupt();
        }
        
        return ApiResponse.success("用户删除成功", null);
    }
    
    private List<UserVO> generateMockUsers() {
        List<UserVO> users = new ArrayList<>();
        String[] names = {"张三", "李四", "王五", "赵六", "钱七", "孙八", "周九", "吴十"};
        String[] usernames = {"zhangsan", "lisi", "wangwu", "zhaoliu", "qianqi", "sunba", "zhoujiu", "wushi"};
        
        for (int i = 0; i < names.length; i++) {
            users.add(new UserVO(
                (long) (i + 1),
                usernames[i],
                names[i],
                usernames[i] + "@example.com",
                "1380013800" + (i + 1),
                i % 4 == 0 ? 0 : 1, // 每4个用户有一个禁用状态
                "2023-01-" + String.format("%02d", i + 1) + " 10:00:00"
            ));
        }
        
        return users;
    }
}
```

#### 2.2 配置Mock环境

```yaml
# application-mock.yml
spring:
  profiles:
    active: mock
    
server:
  port: 8080

# 不需要数据库连接
spring:
  autoconfigure:
    exclude:
      - org.springframework.boot.autoconfigure.jdbc.DataSourceAutoConfiguration

# Swagger配置
springdoc:
  api-docs:
    path: /api-docs
  swagger-ui:
    path: /swagger-ui.html
    
logging:
  level:
    com.company.project: DEBUG
```

#### 2.3 启动Mock服务器

```bash
# 启动Mock服务器
java -jar -Dspring.profiles.active=mock your-app.jar

# 或者在IDE中设置环境变量
VM Options: -Dspring.profiles.active=mock
```

### 第三步：前端基于Mock数据开发

#### 3.1 前端环境配置

```javascript
// .env.development - 开发环境配置
VITE_API_BASE_URL=http://localhost:8080/api
VITE_MOCK_MODE=true

// .env.production - 生产环境配置  
VITE_API_BASE_URL=http://your-production-server.com/api
VITE_MOCK_MODE=false

// .env.local - 本地开发配置（可选）
VITE_API_BASE_URL=http://192.168.1.100:8080/api
VITE_MOCK_MODE=false
```

#### 3.2 请求封装支持环境切换

```javascript
// utils/request.js
import axios from 'axios'
import { ElMessage } from 'element-plus'

// 从环境变量读取配置
const baseURL = import.meta.env.VITE_API_BASE_URL || '/api'
const isMockMode = import.meta.env.VITE_MOCK_MODE === 'true'

console.log('API配置:', { baseURL, isMockMode })

const request = axios.create({
  baseURL: baseURL,
  timeout: isMockMode ? 5000 : 10000, // Mock模式下短超时
  headers: {
    'Content-Type': 'application/json'
  }
})

// 请求拦截器
request.interceptors.request.use(
  config => {
    // 添加认证token
    const token = localStorage.getItem('access_token')
    if (token) {
      config.headers.Authorization = `Bearer ${token}`
    }
    
    // Mock模式下的特殊处理
    if (isMockMode) {
      console.log('Mock请求:', config.method?.toUpperCase(), config.url, config.params || config.data)
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
    
    // Mock模式下的日志
    if (isMockMode) {
      console.log('Mock响应:', response.config.url, { code, message, dataType: typeof data })
    }
    
    if (code === 200) {
      return data
    } else {
      ElMessage.error(message || '请求失败')
      return Promise.reject(new Error(message))
    }
  },
  error => {
    console.error('响应错误:', error)
    
    if (isMockMode && error.code === 'ECONNREFUSED') {
      ElMessage.error('Mock服务器未启动，请检查后端服务')
    } else if (error.response?.status === 401) {
      localStorage.removeItem('access_token')
      // router.push('/login')
    } else {
      ElMessage.error(error.message || '网络错误')
    }
    
    return Promise.reject(error)
  }
)

export default request
```

#### 3.3 API调用代码

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

// 使用示例
export default {
  async loadUserList() {
    try {
      const result = await userApi.getUserList({
        current: 1,
        size: 10,
        keyword: '张'
      })
      
      console.log('用户列表:', result)
      // 结果格式：
      // {
      //   records: [...],
      //   total: 100,
      //   current: 1,
      //   size: 10,
      //   pages: 10
      // }
      
      return result
    } catch (error) {
      console.error('获取用户列表失败:', error)
      throw error
    }
  }
}
```

### 第四步：前端页面开发

```vue
<template>
  <div class="user-management">
    <!-- 环境指示器 -->
    <div v-if="isMockMode" class="mock-indicator">
      🔧 当前使用Mock数据 - 服务器: {{ apiBaseUrl }}
    </div>
    
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
      <el-button @click="handleRefresh">刷新</el-button>
    </div>
    
    <!-- 用户表格 -->
    <el-table :data="userList" v-loading="loading" stripe>
      <el-table-column prop="id" label="ID" width="80" />
      <el-table-column prop="username" label="用户名" width="120" />
      <el-table-column prop="nickname" label="昵称" width="100" />
      <el-table-column prop="email" label="邮箱" />
      <el-table-column prop="phone" label="手机号" width="130" />
      <el-table-column label="状态" width="80">
        <template #default="scope">
          <el-tag :type="scope.row.status === 1 ? 'success' : 'danger'">
            {{ scope.row.status === 1 ? '正常' : '禁用' }}
          </el-tag>
        </template>
      </el-table-column>
      <el-table-column prop="createTime" label="创建时间" width="160" />
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
import { ref, reactive, onMounted, computed } from 'vue'
import { userApi } from '@/api/user'
import { ElMessage, ElMessageBox } from 'element-plus'

// 环境信息
const isMockMode = computed(() => import.meta.env.VITE_MOCK_MODE === 'true')
const apiBaseUrl = computed(() => import.meta.env.VITE_API_BASE_URL)

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
    console.log('开始加载用户列表...', {
      current: pagination.current,
      size: pagination.size,
      keyword: searchForm.keyword
    })
    
    const result = await userApi.getUserList({
      current: pagination.current,
      size: pagination.size,
      keyword: searchForm.keyword || undefined
    })
    
    console.log('用户列表加载成功:', result)
    
    userList.value = result.records || []
    pagination.total = result.total || 0
    
    ElMessage.success(`加载了 ${result.records?.length || 0} 条用户数据`)
  } catch (error) {
    console.error('加载用户列表失败:', error)
    ElMessage.error('加载用户列表失败: ' + error.message)
    
    // Mock模式下的特殊提示
    if (isMockMode.value) {
      ElMessage.warning('请检查Mock服务器是否正常运行')
    }
  } finally {
    loading.value = false
  }
}

// 搜索
const handleSearch = () => {
  console.log('搜索用户:', searchForm.keyword)
  pagination.current = 1
  loadUserList()
}

// 刷新
const handleRefresh = () => {
  console.log('刷新用户列表')
  searchForm.keyword = ''
  pagination.current = 1
  loadUserList()
}

// 创建用户
const handleCreate = async () => {
  try {
    // 这里可以打开创建用户的对话框，现在先用固定数据测试
    const mockUserData = {
      username: 'testuser' + Date.now(),
      password: '123456',
      nickname: '测试用户',
      email: 'test@example.com',
      phone: '13800138000'
    }
    
    console.log('创建用户:', mockUserData)
    const result = await userApi.createUser(mockUserData)
    console.log('创建用户成功:', result)
    
    ElMessage.success('用户创建成功')
    loadUserList() // 刷新列表
  } catch (error) {
    console.error('创建用户失败:', error)
    ElMessage.error('创建用户失败: ' + error.message)
  }
}

// 编辑用户
const handleEdit = async (user) => {
  try {
    console.log('编辑用户:', user)
    
    // 模拟编辑数据
    const updateData = {
      username: user.username,
      nickname: user.nickname + '_updated',
      email: user.email,
      phone: user.phone
    }
    
    await userApi.updateUser(user.id, updateData)
    console.log('更新用户成功')
    
    ElMessage.success('用户更新成功')
    loadUserList() // 刷新列表
  } catch (error) {
    console.error('更新用户失败:', error)
    ElMessage.error('更新用户失败: ' + error.message)
  }
}

// 删除用户
const handleDelete = async (user) => {
  try {
    await ElMessageBox.confirm(`确定删除用户"${user.username}"吗？`, '确认删除', {
      type: 'warning'
    })
    
    console.log('删除用户:', user.id)
    await userApi.deleteUser(user.id)
    console.log('删除用户成功')
    
    ElMessage.success('用户删除成功')
    loadUserList() // 刷新列表
  } catch (error) {
    if (error !== 'cancel') {
      console.error('删除用户失败:', error)
      ElMessage.error('删除用户失败: ' + error.message)
    }
  }
}

// 页面加载时获取数据
onMounted(() => {
  console.log('用户管理页面初始化')
  console.log('环境配置:', {
    isMockMode: isMockMode.value,
    apiBaseUrl: apiBaseUrl.value
  })
  loadUserList()
})
</script>

<style scoped>
.user-management {
  padding: 20px;
}

.mock-indicator {
  background: #fff7e6;
  border: 1px solid #ffd591;
  border-radius: 4px;
  padding: 8px 12px;
  margin-bottom: 16px;
  color: #d48806;
  font-size: 14px;
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

### 第五步：无缝切换到真实后端

#### 5.1 后端开发完成后

```java
// 真实的UserController实现
@RestController
@RequestMapping("/api/v1/users")
@Profile("!mock")  // 非mock环境下启用
public class UserController {
    
    @Autowired
    private UserService userService;
    
    @GetMapping
    public ApiResponse<PageResult<UserVO>> getUserList(
            @RequestParam(defaultValue = "1") Integer current,
            @RequestParam(defaultValue = "10") Integer size,
            @RequestParam(required = false) String keyword) {
        
        // 真实的业务逻辑实现
        PageResult<UserVO> result = userService.getUserList(current, size, keyword);
        return ApiResponse.success(result);
    }
    
    @PostMapping
    public ApiResponse<UserVO> createUser(@RequestBody @Valid CreateUserRequest request) {
        UserVO user = userService.createUser(request);
        return ApiResponse.success(user);
    }
    
    // ... 其他真实实现
}
```

#### 5.2 前端环境切换

```bash
# 方法1：修改环境变量文件
# .env.development
VITE_API_BASE_URL=http://localhost:8080/api
VITE_MOCK_MODE=false

# 方法2：创建本地环境配置
# .env.local (这个文件不提交到git)
VITE_API_BASE_URL=http://192.168.1.100:8080/api
VITE_MOCK_MODE=false

# 方法3：启动时指定环境
npm run dev --mode production
```

#### 5.3 验证切换效果

前端无需修改任何业务代码，只需要：
1. 修改环境变量中的服务器地址
2. 重启前端开发服务器
3. 自动连接到真实后端

```javascript
// 前端请求代码完全不变
const result = await userApi.getUserList({
  current: 1,
  size: 10,
  keyword: 'test'
})

// 无论是Mock数据还是真实数据，返回格式完全一致
console.log(result) // { records: [...], total: 100, current: 1, size: 10, pages: 10 }
```

---

## 高级技巧

### 1. 动态Mock数据生成

```javascript
// mock/mockData.js
import { faker } from '@faker-js/faker'

// 生成随机用户数据
export function generateUsers(count = 50) {
  const users = []
  for (let i = 0; i < count; i++) {
    users.push({
      id: faker.datatype.number({ min: 1, max: 10000 }),
      username: faker.internet.userName(),
      nickname: faker.name.fullName(),
      email: faker.internet.email(),
      phone: faker.phone.number('138########'),
      status: faker.datatype.boolean() ? 1 : 0,
      createTime: faker.date.recent(30).toISOString().slice(0, 19).replace('T', ' ')
    })
  }
  return users
}
```

### 2. 接口状态模拟

```java
@RestController
@RequestMapping("/api/v1/users")
@Profile("mock")
public class MockUserController {
    
    @GetMapping
    public ApiResponse<PageResult<UserVO>> getUserList(@RequestParam Map<String, Object> params) {
        
        // 模拟不同的响应状态
        String mockType = (String) params.get("mockType");
        
        switch (mockType) {
            case "error":
                return ApiResponse.error(500, "服务器内部错误");
            case "empty":
                return ApiResponse.success(PageResult.of(Collections.emptyList(), 0L, 1, 10));
            case "slow":
                try {
                    Thread.sleep(3000); // 模拟慢响应
                } catch (InterruptedException e) {
                    Thread.currentThread().interrupt();
                }
                break;
        }
        
        // 正常响应
        return mockUserListResponse(params);
    }
}
```

### 3. 前端Mock状态测试

```vue
<template>
  <div>
    <!-- Mock控制面板 -->
    <div v-if="isMockMode" class="mock-controls">
      <h4>Mock测试控制</h4>
      <el-button @click="testNormalResponse">正常响应</el-button>
      <el-button @click="testErrorResponse">错误响应</el-button>
      <el-button @click="testEmptyResponse">空数据</el-button>
      <el-button @click="testSlowResponse">慢响应</el-button>
    </div>
  </div>
</template>

<script setup>
// Mock测试方法
const testNormalResponse = () => {
  searchForm.mockType = undefined
  loadUserList()
}

const testErrorResponse = () => {
  searchForm.mockType = 'error'
  loadUserList()
}

const testEmptyResponse = () => {
  searchForm.mockType = 'empty'
  loadUserList()
}

const testSlowResponse = () => {
  searchForm.mockType = 'slow'
  loadUserList()
}
</script>
```

---

## 总结

通过这个完整的流程，我们解决了提出的核心问题：

### ✅ **前后端并行开发基于什么？**
- 基于**详细的接口文档**和**数据结构定义**
- 使用Swagger/OpenAPI标准化接口规范
- 前后端都按照同样的数据格式进行开发

### ✅ **接口文档的数据怎么做？**
- 后端提供**Mock Controller**返回结构化的测试数据
- 使用**faker.js**等工具生成随机但真实的Mock数据
- Mock数据与真实数据保持**完全相同的格式**

### ✅ **如何实现前端无缝切换？**
- 通过**环境变量配置**不同的服务器地址
- 统一的**请求封装**屏蔽底层差异
- 前端业务代码**零修改**即可切换

这种方式的核心优势：
1. **并行高效** - 前后端可以同时开发，不互相阻塞
2. **格式一致** - Mock数据和真实数据格式完全一致
3. **切换无缝** - 只需修改配置，业务代码不变
4. **测试完整** - 可以测试各种边界情况和异常状态

希望这个详细的解答能帮助理解前后端并行开发的核心机制！
