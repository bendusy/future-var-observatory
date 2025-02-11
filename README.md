# AI 对话应用模板

这是一个基于 [Next.js](https://nextjs.org/) 开发的 AI 对话应用模板,可以快速搭建类似 ChatGPT 的对话应用。

## 功能特点

- 💬 支持多轮对话
- 🔄 实时流式响应
- 📝 对话历史保存
- 🎨 可自定义提示词
- 🌍 多语言支持
- 🎯 支持 Markdown 渲染

## 快速开始

### 1. 环境配置

创建 `.env.local` 文件并配置以下环境变量:

```bash
# APP ID - 应用唯一标识
# 可在 Dify 控制台应用详情页 URL 中获取,如 https://cloud.dify.ai/app/xxx/workflow 中的 xxx
NEXT_PUBLIC_APP_ID=

# API Key - API 访问密钥
# 在应用的 "API 访问" 页面右上角点击 "API Key" 按钮生成
NEXT_PUBLIC_APP_KEY=

# API URL - API 基础地址
# 使用 Dify 云服务时设置为: https://api.dify.ai/v1
NEXT_PUBLIC_API_URL=
```

### 2. 应用配置

在 `config/index.ts` 文件中配置应用信息:

```typescript
export const APP_INFO = {
  title: '对话应用',          // 应用标题
  description: '',           // 应用描述
  copyright: '',            // 版权信息
  privacy_policy: '',       // 隐私政策
  default_language: 'zh-Hans' // 默认语言
}

// 是否显示提示词
export const isShowPrompt = true
// 提示词模板
export const promptTemplate = ''
```

### 3. 本地开发

安装依赖:

```bash
npm install
# 或
yarn
# 或
pnpm install
```

启动开发服务器:

```bash
npm run dev
# 或
yarn dev
# 或
pnpm dev
```

访问 [http://localhost:3000](http://localhost:3000) 查看应用。

### 4. Docker 部署

```bash
# 构建镜像
docker build . -t <DOCKER_HUB_REPO>/webapp-conversation:latest

# 运行容器
docker run -p 3000:3000 <DOCKER_HUB_REPO>/webapp-conversation:latest
```

### 5. Vercel 部署

> ⚠️ 使用 [Vercel Hobby](https://vercel.com/pricing) 版本时,由于其限制,消息可能会被截断。

推荐使用 [Vercel 平台](https://vercel.com/new?utm_medium=default-template&filter=next.js&utm_source=create-next-app&utm_campaign=create-next-app-readme) 进行部署。

## 开发资源

- [Next.js 文档](https://nextjs.org/docs) - 了解 Next.js 特性和 API
- [Next.js 教程](https://nextjs.org/learn) - 交互式 Next.js 教程

## 注意事项

1. 确保 API Key 安全,不要提交到代码仓库
2. 开发时注意环境变量的正确配置
3. 部署前进行充分的功能测试
4. 注意处理大规模并发访问的性能优化

## 贡献指南

欢迎提交 Issue 和 Pull Request 来帮助改进这个项目。

## 许可证

本项目采用 MIT 许可证。
