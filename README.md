# 未来变量观测局
基于 Next.js 14 开发的现代命理预测平台，提供精准的八字分析和运势预测功能。

## 功能特点

- 八字命理分析
  - 支持公历/农历日期转换
  - 完整的八字排盘
  - 精准的五行纳音
  - 详细的大运流年
  - 多维度运势分析

- 现代化界面
  - 响应式设计
  - 优雅的暗色模式
  - 系统主题自动切换
  - 直观的数据可视化

## 系统要求

- Node.js >= 22.x
- npm >= 10.x
- Dify >= 0.3.30
- 内存 >= 4GB
- 磁盘空间 >= 2GB

## 技术栈

- 框架：Next.js 14 + TypeScript 5
- UI：Tailwind CSS 3 + Ant Design 5
- 命理：lunar-typescript
- 工具：dayjs + react-markdown
- 部署：PM2 (Linux) / Windows Service
- API：Dify AI Assistant

## 快速开始

### 一键部署（推荐）

使用 curl 安装:

```bash
# 默认安装到当前目录下的 future-var-observatory
curl -fsSL https://raw.githubusercontent.com/bendusy/future-var-observatory/main/quickstart.sh | bash

# 安装到指定目录
curl -fsSL https://raw.githubusercontent.com/bendusy/future-var-observatory/main/quickstart.sh | bash -s -- /your/install/path
```

或使用 wget 安装:

```bash
# 默认安装到当前目录下的 future-var-observatory
wget -qO- https://raw.githubusercontent.com/bendusy/future-var-observatory/main/quickstart.sh | bash

# 安装到指定目录
wget -qO- https://raw.githubusercontent.com/bendusy/future-var-observatory/main/quickstart.sh | bash -s -- /your/install/path
```

一键更新:

```bash
# 更新当前目录下的安装
curl -fsSL https://raw.githubusercontent.com/bendusy/future-var-observatory/main/quickstart.sh | bash -s -- --update

# 更新指定目录的安装
curl -fsSL https://raw.githubusercontent.com/bendusy/future-var-observatory/main/quickstart.sh | bash -s -- --update /your/install/path
```

查看帮助:

```bash
curl -fsSL https://raw.githubusercontent.com/bendusy/future-var-observatory/main/quickstart.sh | bash -s -- --help
```

### 开发环境设置

1. 安装依赖

```bash
npm install
```

2. 配置开发环境

```bash
cp .env.example .env.local
# 编辑 .env.local 配置文件
```

3. 启动开发服务器

```bash
npm run dev
```

4. 代码质量控制

```bash
npm run lint      # 代码检查
npm run format    # 代码格式化
npm run type-check # 类型检查
```

## 测试

```bash
npm run test          # 运行所有测试
npm run test:unit     # 仅运行单元测试
npm run test:e2e      # 仅运行端到端测试
```

## 构建和部署

【注意】本项目依赖于 Dify 服务，必须先安装部署 Dify 才能正常使用。

### 前置要求

1. 部署 Dify 服务
   - 访问 [Dify 官方文档](https://docs.dify.ai/getting-started/install-self-hosted) 按照指南部署
   - 推荐使用 Docker 方式部署
   - 确保 Dify 服务正常运行（最低版本要求：0.3.30）

2. 配置 Dify 应用
   - 在 Dify 控制台创建新应用
   - 选择 "AI Assistant" 类型
   - 记录应用的 APP_ID 和 API_KEY
   - 确保应用状态为"已发布"

3. 验证 Dify 服务

   ```bash
   # 测试 Dify API 是否可用
   curl -X POST "YOUR_DIFY_API_URL/chat-messages" \
   -H "Authorization: Bearer YOUR_API_KEY" \
   -H "Content-Type: application/json"
   ```

### Windows 用户

```powershell
# 1. 克隆项目
git clone https://github.com/bendusy/future-var-observatory.git
cd future-var-observatory

# 2. 运行安装脚本（选择一种方式）

# 方式1：交互式配置（推荐）
.\install.ps1

# 方式2：命令行参数
.\install.ps1 your_app_id your_api_key https://api.dify.ai/v1

# 方式3：环境变量
$env:NEXT_PUBLIC_APP_ID = "your_app_id"
$env:NEXT_PUBLIC_APP_KEY = "your_api_key"
$env:NEXT_PUBLIC_API_URL = "https://api.dify.ai/v1"
.\install.ps1
```

### Linux/MacOS 用户

```bash
# 1. 克隆项目
git clone https://github.com/bendusy/future-var-observatory.git
cd future-var-observatory

# 2. 运行安装脚本（选择一种方式）

# 方式1：交互式配置（推荐）
chmod +x install.sh
./install.sh

# 方式2：命令行参数
chmod +x install.sh
./install.sh your_app_id your_api_key https://api.dify.ai/v1

# 方式3：环境变量
export NEXT_PUBLIC_APP_ID=your_app_id
export NEXT_PUBLIC_APP_KEY=your_api_key
export NEXT_PUBLIC_API_URL=https://api.dify.ai/v1
chmod +x install.sh
./install.sh
```

### 手动安装

1. 安装 Node.js 22.x
2. 克隆项目并进入目录
3. 安装依赖：`npm install`
4. 复制 `.env.example` 为 `.env.local` 并配置
5. 构建项目：`npm run build`
6. 启动服务：`node .next/standalone/server.js -p 33896`

## 环境变量

必要的环境变量（`.env.local`）：

```bash
# Dify API 配置
NEXT_PUBLIC_APP_ID=your_app_id      # Dify 应用 ID
NEXT_PUBLIC_APP_KEY=your_api_key    # Dify API 密钥
NEXT_PUBLIC_API_URL=https://api.dify.ai/v1  # API 地址
```

## 开发指南

```bash
# 开发模式
npm run dev

# 类型检查
npm run type-check

# 代码格式化
npm run format

# 代码检查
npm run lint
```

## 项目结构

```
future-var-observatory/
├── app/                # Next.js 应用目录
│   ├── components/     # 共用组件
│   │   ├── ui/        # UI 组件
│   │   └── business/  # 业务组件
│   ├── prediction/     # 预测功能页面
│   └── providers.tsx   # 全局提供者
├── docs/              # 项目文档
├── service/           # 服务层
├── types/             # TypeScript 类型
├── utils/             # 工具函数
└── scripts/           # 部署脚本
```

## 更新日志

详见 [CHANGELOG.md](CHANGELOG.md)

## 服务管理

### Windows

作为 Windows 服务运行：

```powershell
# 安装服务
node install-service.js

# 卸载服务
.\uninstall.ps1

# 一键更新（包含代码更新、依赖安装、重新构建）
.\install.ps1 --update
```

### Linux

使用 PM2 管理：

```bash
# 一键更新（包含代码更新、依赖安装、重新构建）
chmod +x update.sh
./update.sh

# 查看状态
pm2 status

# 查看日志
pm2 logs fvo

# 重启服务
pm2 restart fvo

# 停止服务
pm2 stop fvo
```

## 更新说明

本项目提供了两种更新方式：

### 1. 一键更新（推荐）

Linux/MacOS:

```bash
./update.sh
```

Windows:

```powershell
.\install.ps1 --update
```

一键更新会自动执行以下操作：

- 保存本地修改（如果有）
- 拉取最新代码
- 安装新依赖
- 重新构建项目
- 重启服务

### 2. 交互式更新

运行安装脚本并从菜单中选择更新选项：

Linux/MacOS:

```bash
./install.sh
# 选择选项 2 或 3
```

Windows:

```powershell
.\install.ps1
# 选择选项 2 或 3
```

## 常见问题

### 1. 端口被占用

```bash
# 修改启动端口
node .next/standalone/server.js -p 新端口号
```

### 2. 构建失败

```bash
# 清理缓存后重试
rm -rf .next
npm run build
```

### 3. 依赖安装失败

```bash
# 使用淘宝镜像
npm config set registry https://registry.npmmirror.com
npm install
```

## 贡献指南

1. Fork 项目
2. 创建功能分支
3. 提交更改
4. 推送到分支
5. 创建 Pull Request

## 许可证

MIT License

## 联系方式

- 问题反馈：[GitHub Issues](https://github.com/bendusy/future-var-observatory/issues)



## 项目结构说明

```
future-var-observatory/
├── app/                # Next.js 应用目录
│   ├── components/     # 共用组件
│   │   ├── ui/        # UI 组件
│   │   └── business/  # 业务组件
│   ├── prediction/     # 预测功能页面
│   └── providers.tsx   # 全局提供者
├── docs/              # 项目文档
├── service/           # 服务层
├── types/             # TypeScript 类型
├── utils/             # 工具函数
└── scripts/           # 部署脚本
```
