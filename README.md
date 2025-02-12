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

## 技术栈

- 框架：Next.js 14 + TypeScript 5
- UI：Tailwind CSS 3 + Ant Design 5
- 命理：lunar-typescript
- 工具：dayjs + react-markdown

## 快速开始

### Windows 用户

```powershell
# 1. 克隆项目
git clone https://github.com/bendusy/webapp-8zi.git
cd webapp-8zi

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
git clone https://github.com/bendusy/webapp-8zi.git
cd webapp-8zi

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
webapp-8zi/
├── app/                # Next.js 应用目录
│   ├── components/     # 共用组件
│   ├── prediction/     # 预测功能页面
│   └── providers.tsx   # 全局提供者
├── service/           # 服务层
├── types/             # TypeScript 类型
└── utils/             # 工具函数
```

## 服务管理

### Windows

作为 Windows 服务运行：

```powershell
# 安装服务
node install-service.js

# 卸载服务
.\uninstall.ps1
```

### Linux

使用 PM2 管理：

```bash
# 查看状态
pm2 status

# 查看日志
pm2 logs webapp-8zi

# 重启服务
pm2 restart webapp-8zi

# 停止服务
pm2 stop webapp-8zi
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
