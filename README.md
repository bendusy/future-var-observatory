# 未来变量观测局

基于 Next.js 14 开发的现代命理预测平台，提供精准的八字分析和运势预测功能。

## 功能特点

- 支持公历/农历日期转换
- 八字信息计算
- 五行纳音分析
- 大运流年预测
- 多维度运势分析
- 响应式界面设计
- 支持暗色模式
- 系统主题自动切换
- 完整的八字排盘
- 精准的五行纳音
- 详细的大运流年
- 多维度运势分析
- 直观的数据可视化
- 完整的免责声明
- 优雅的暗色模式

## 技术栈

- Next.js 14
- TypeScript 5
- Tailwind CSS 3
- Ant Design 5
- lunar-typescript
- dayjs
- react-markdown
- remark-gfm
- remark-breaks

## 开发环境要求

- Node.js >= 22 (脚本会自动安装)
- npm >= 10 (脚本会自动安装/更新)

## 依赖说明

主要依赖包及其用途:

- `lunar-typescript`: 农历日期转换和八字计算
- `antd`: UI组件库
- `tailwindcss`: 原子化CSS框架
- `@tailwindcss/typography`: Markdown样式支持
- `dayjs`: 日期处理工具
- `react-markdown`: Markdown渲染
- `remark-gfm`: GitHub风格Markdown支持
- `remark-breaks`: 支持换行符
- `pm2`: Node.js进程管理

## 安装部署

### 方法一：一键部署（推荐）

#### Linux/MacOS 用户

```bash
# 1. 克隆项目
git clone https://github.com/bendusy/webapp-8zi.git
cd webapp-8zi

# 2. 运行安装脚本（三种方式）

# 方式1：交互式配置（推荐新手）
chmod +x install.sh
./install.sh

# 方式2：命令行直接传入参数
chmod +x install.sh
./install.sh your_app_id your_api_key https://api.dify.ai/v1

# 方式3：使用环境变量
export NEXT_PUBLIC_APP_ID=your_app_id
export NEXT_PUBLIC_APP_KEY=your_api_key
export NEXT_PUBLIC_API_URL=https://api.dify.ai/v1
chmod +x install.sh
./install.sh
```

#### Windows 用户

```powershell
# 1. 克隆项目
git clone https://github.com/bendusy/webapp-8zi.git
cd webapp-8zi

# 2. 运行安装脚本（三种方式）

# 方式1：交互式配置（推荐新手）
.\install.ps1

# 方式2：命令行直接传入参数
.\install.ps1 your_app_id your_api_key https://api.dify.ai/v1

# 方式3：使用环境变量
$env:NEXT_PUBLIC_APP_ID = "your_app_id"
$env:NEXT_PUBLIC_APP_KEY = "your_api_key"
$env:NEXT_PUBLIC_API_URL = "https://api.dify.ai/v1"
.\install.ps1
```

> 说明：
>
> 1. 如果系统没有安装 Node.js，脚本会提示是否自动安装
> 2. 如果使用交互式配置，脚本会提示输入必要的配置信息
> 3. 所有配置信息会保存在项目根目录的 `.env.local` 文件中
> 4. 安装完成后，服务会自动启动，打开浏览器访问：<http://localhost:33896>

### 方法二：手动安装

1. 安装 Node.js
   - Windows 用户：
     - 访问 [Node.js 官网](https://nodejs.org/)
     - 下载并安装 Node.js 22.x LTS 版本
     - 安装时勾选"Automatically install the necessary tools"

   - Linux 用户：

     ```bash
     # Ubuntu/Debian
     curl -fsSL https://deb.nodesource.com/setup_22.x | sudo -E bash -
     sudo apt-get install -y nodejs

     # CentOS/RHEL
     curl -fsSL https://rpm.nodesource.com/setup_22.x | sudo bash -
     sudo yum install -y nodejs
     ```

   - Mac 用户：

     ```bash
     # 使用 brew 安装
     brew install node@22
     ```

2. 克隆项目

```bash
git clone https://github.com/bendusy/webapp-8zi.git
cd webapp-8zi
```

3. 安装依赖

```bash
npm install
```

4. 配置环境变量
   - 复制项目根目录下的 `.env.example` 文件并重命名为 `.env.local`
   - 使用记事本或任何文本编辑器打开 `.env.local`
   - 填入以下配置信息：

   ```
   NEXT_PUBLIC_APP_ID=your_app_id    # 替换为你的 Dify 应用 ID
   NEXT_PUBLIC_APP_KEY=your_api_key  # 替换为你的 Dify API 密钥
   NEXT_PUBLIC_API_URL=https://api.dify.ai/v1
   ```

5. 启动服务

```bash
# 开发模式
npm run dev

# 或者生产模式
npm run build
npm start

# 启动成功后，打开浏览器访问：http://localhost:33896
```

## 项目结构

```
future-var-observatory/
├── app/                # Next.js 应用目录
├── components/         # 共用组件
├── config/            # 配置文件
├── service/           # 服务层
├── types/             # TypeScript 类型定义
├── utils/             # 工具函数
└── test/              # 测试文件
```

## 环境变量说明

必要的环境变量配置（填写在项目根目录的 `.env.local` 文件中）：

- `NEXT_PUBLIC_APP_ID`: Dify 应用 ID
- `NEXT_PUBLIC_APP_KEY`: Dify API 密钥
- `NEXT_PUBLIC_API_URL`: Dify API 地址（默认：<https://api.dify.ai/v1）>
- `PORT`: 服务端口（默认：33896，已在配置文件中固定，一般无需修改）
- `NODE_ENV`: 运行环境（development/production）

### 修改默认端口

如果需要修改默认端口 33896，可以：

1. 方法一：使用环境变量（临时）

```bash
# Linux/Mac
PORT=3000 npm run dev  # 开发模式
PORT=3000 npm start    # 生产模式

# Windows PowerShell
$env:PORT=3000; npm run dev  # 开发模式
$env:PORT=3000; npm start    # 生产模式
```

2. 方法二：修改配置文件（永久）
   - 编辑 `package.json`，修改 `scripts` 中的端口号
   - 编辑 `next.config.js`，修改 `devServer.port` 的值
   - 编辑 `.env.local`，修改 `PORT` 的值

## 测试

```bash
# 运行测试
npm test

# 监听模式
npm run test:watch
```

## 镜像信息

- 镜像名称：yobservatory/future-var-observatory
- 镜像大小：约 248MB
- 基础镜像：node:19-alpine
- 默认端口：33896

## 常见问题

### 1. 克隆项目时提示"目录已存在"

如果看到以下错误：

```bash
fatal: destination path 'webapp-8zi' already exists and is not an empty directory.
```

解决方法：

```bash
# 方法1：删除已存在的目录后重新克隆
rm -rf webapp-8zi    # Linux/Mac
rd /s /q webapp-8zi  # Windows
git clone https://github.com/bendusy/webapp-8zi.git

# 方法2：进入已存在的目录，拉取最新代码
cd webapp-8zi
git fetch origin
git reset --hard origin/main

# 方法3：换个目录名称重新克隆
git clone https://github.com/bendusy/webapp-8zi.git webapp-8zi-new
```

### 2. Node.js 安装失败

如果自动安装失败，可以：

1. 访问 [Node.js 官网](https://nodejs.org/)
2. 下载 22.x 版本的安装包
3. 手动安装

### 3. npm 安装依赖失败

如果看到网络超时等错误，可以：

```bash
# 方法1：使用淘宝镜像
npm config set registry https://registry.npmmirror.com
npm install

# 方法2：清除缓存后重试
npm cache clean --force
npm install

# 方法3：删除 node_modules 后重装
rm -rf node_modules    # Linux/Mac
rd /s /q node_modules  # Windows
npm install
```

### 4. 启动服务时端口被占用

如果看到端口 33896 被占用，可以：

```bash
# 方法1：找到并关闭占用端口的进程
# Windows:
netstat -ano | findstr "33896"
taskkill /F /PID 对应的进程ID

# Linux/Mac:
lsof -i :33896
kill -9 对应的进程ID

# 方法2：修改 .env.local 文件，使用其他端口
echo "PORT=33897" >> .env.local  # 使用 33897 端口
```

## 许可证

MIT License

## 功能说明

### 1. 八字排盘

- 支持公历/农历日期选择
- 自动计算八字信息
- 显示五行属性
- 计算纳音五行
- 分析十神关系
- 排列大运流年

### 2. 运势预测

- 事业发展分析
- 感情状况预测
- 财运趋势判断
- 健康状况评估
- 自定义预测方向

### 3. 界面特性

- 响应式设计
- 暗色模式支持
- 系统主题跟随
- 优雅的动画过渡
- 直观的数据展示

### 4. 其他功能

- 完整的错误处理
- 用户隐私保护
- 免责声明
- 优雅降级处理
- 性能优化
