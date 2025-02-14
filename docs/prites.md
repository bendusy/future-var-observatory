# 未来变量观测局项目教学指南

## 一、项目概述

### 1.1 项目介绍

- 基于 Next.js 14 开发的现代命理预测平台
- 提供八字分析、运势预测等功能
- 支持深色模式、响应式设计
- 使用 Dify 作为 AI 对话引擎

### 1.2 技术栈

- 框架：Next.js 14 + TypeScript 5
- UI：Tailwind CSS 3 + Ant Design 5
- 命理：lunar-typescript
- 工具：dayjs + react-markdown
- 部署：PM2 (Linux) / Windows Service
- API：Dify AI Assistant

### 1.3 开发环境要求

- Node.js >= 22.x
- npm >= 10.x
- Dify >= 0.3.30
- 内存 >= 4GB
- 磁盘空间 >= 2GB

## 二、项目结构

### 2.1 目录结构

```
future-var-observatory/
├── app/                # Next.js 应用目录
│   ├── components/     # 共用组件
│   │   ├── ui/        # UI组件
│   │   └── business/  # 业务组件
│   ├── prediction/    # 预测功能页面
│   └── providers.tsx  # 全局提供者
├── service/           # 服务层
├── types/            # TypeScript 类型
└── utils/            # 工具函数
```

### 2.2 关键文件说明

- `app/layout.tsx`: 全局布局文件
- `app/prediction/page.tsx`: 主预测页面
- `app/providers.tsx`: 全局提供者（主题等）
- `service/predict.ts`: 预测服务实现
- `types/prediction.ts`: 类型定义

## 三、核心功能实现

### 3.1 全局布局实现

\`\`\`tsx
// app/layout.tsx
export default function RootLayout({
  children,
}: {
  children: React.ReactNode
}) {
  return (
    <html lang="zh-CN" suppressHydrationWarning>
      <body className={`${inter.className} min-h-screen bg-white dark:bg-dark-bg`}>
        <Providers>
          {/*主题切换按钮 */}
          <div className="fixed top-4 right-4 z-50">
            <ThemeSwitch />
          </div>
          {/* 主内容区*/}
          <main className="transition-colors duration-200">
            {children}
          </main>
        </Providers>
      </body>
    </html>
  )
}
\`\`\`

### 3.2 预测页面实现

\`\`\`tsx
// app/prediction/page.tsx
export default function PredictionPage() {
  // 状态管理
  const [form] = Form.useForm()
  const [loading, setLoading] = useState(false)
  const [result, setResult] = useState<PredictionResult | null>(null)
  const [lunarInfo, setLunarInfo] = useState<LunarInfo | null>(null)

  // 表单提交处理
  const onFinish = async (values: PredictionForm) => {
    setLoading(true)
    try {
      const response = await fetchPredict(values)
      setResult(response)
    } catch (err) {
      setError(err.message)
    } finally {
      setLoading(false)
    }
  }

  return (
    <div className="max-w-3xl mx-auto p-4">
      <Form form={form} onFinish={onFinish}>
        {/*基本信息*/}
        <Form.Item name="gender" label="性别">
          <Radio.Group>
            <Radio value="male">👨 男</Radio>
            <Radio value="female">👩 女</Radio>
            <Radio value="other">✨ 其他</Radio>
          </Radio.Group>
        </Form.Item>

        {/* 出生时间选择 */}
        <div className="grid grid-cols-4 gap-4">
          <Form.Item name="birthYear" label="年">
            <Select>{yearOptions}</Select>
          </Form.Item>
          <Form.Item name="birthMonth" label="月">
            <Select>{monthOptions}</Select>
          </Form.Item>
          <Form.Item name="birthDay" label="日">
            <Select>{dayOptions}</Select>
          </Form.Item>
          <Form.Item name="birthHour" label="时">
            <Select>{hourOptions}</Select>
          </Form.Item>
        </div>

        {/* 预测方向选择 */}
        <Form.Item name="direction" label="预测方向">
          <Checkbox.Group>
            <Checkbox value="career">💼 事业发展</Checkbox>
            <Checkbox value="relationship">❤️ 感情状况</Checkbox>
            <Checkbox value="wealth">💰 财运预测</Checkbox>
            <Checkbox value="health">🏥 健康状况</Checkbox>
          </Checkbox.Group>
        </Form.Item>

        <Button type="primary" htmlType="submit" loading={loading}>
          开始预测
        </Button>
      </Form>

      {/* 预测结果显示 */}
      {result && (
        <Card className="mt-8">
          <ReactMarkdown>{result.content}</ReactMarkdown>
        </Card>
      )}
    </div>
  )
}
\`\`\`

### 3.3 八字计算实现

\`\`\`tsx
// service/predict.ts
function calculateBazi(birthDate: string, birthTime: string): BaziInfo {
  const solar = Solar.fromYmd(
    parseInt(birthDate.split['-'](0)),
    parseInt(birthDate.split['-'](1)),
    parseInt(birthDate.split['-'](2))
  )
  const lunar = solar.getLunar()
  const eightChar = lunar.getEightChar()

  return {
    solarDate: birthDate,
    lunarDate: `${lunar.getYearInChinese()}年${lunar.getMonthInChinese()}月${lunar.getDayInChinese()}`,
    year: eightChar.getYear(),
    month: eightChar.getMonth(),
    day: eightChar.getDay(),
    hour: eightChar.getTime()
  }
}
\`\`\`

### 3.4 主题切换实现

\`\`\`tsx
// app/components/theme-switch/index.tsx
export default function ThemeSwitch() {
  const { theme, setTheme } = useTheme()
  
  return (
    <button
      onClick={() => setTheme(theme === 'dark' ? 'light' : 'dark')}
      className="p-2 rounded-lg bg-white/30 dark:bg-dark-container/30"
    >
      {theme === 'dark' ? '🌞' : '🌙'}
    </button>
  )
}
\`\`\`

## 四、样式实现

### 4.1 全局样式

\`\`\`css
/*app/globals.css*/
@tailwind base;
@tailwind components;
@tailwind utilities;

:root {
  --max-width: 1100px;
  --border-radius: 12px;
  --font-mono: ui-monospace, Menlo, Monaco, "Cascadia Mono";
}

.dark {
  --bg-primary: #1a1a1a;
  --text-primary: #ffffff;
}
\`\`\`

### 4.2 关键样式类说明

- 布局类
  - \`max-w-3xl\`: 最大宽度限制
  - \`mx-auto\`: 水平居中
  - \`p-4\`: 内边距
  - \`grid grid-cols-4 gap-4\`: 四列网格布局

- 暗色模式
  - \`dark:bg-dark-bg\`: 暗色背景
  - \`dark:text-dark-text\`: 暗色文本
  - \`dark:border-dark-border\`: 暗色边框

- 组件样式
  - \`rounded-lg\`: 圆角
  - \`shadow-lg\`: 阴影
  - \`transition-colors\`: 颜色过渡动画

## 五、开发流程

### 5.1 环境搭建

1. 安装 Node.js 和 npm
2. 克隆项目并安装依赖
3. 配置 Dify API
4. 启动开发服务器

### 5.2 开发步骤

1. 实现基础布局
2. 添加表单组件
3. 实现八字计算
4. 集成 Dify API
5. 添加主题切换
6. 优化样式和交互

### 5.3 测试和部署

1. 运行类型检查
\`\`\`bash
npm run type-check
\`\`\`

2. 代码格式化
\`\`\`bash
npm run format
\`\`\`

3. 构建项目
\`\`\`bash
npm run build
\`\`\`

4. 部署服务
\`\`\`bash
pm2 start npm --name "fvo" -- start

```

## 六、注意事项

### 6.1 性能优化

- 使用 React.memo 优化组件重渲染
- 实现懒加载和代码分割
- 优化图片和资源加载

### 6.2 安全考虑

- 保护 API 密钥
- 实现请求限流
- 添加输入验证
- 防止 XSS 攻击

### 6.3 兼容性

- 支持主流浏览器
- 响应式设计适配
- 暗色模式兼容

### 6.4 代码规范

- 使用 TypeScript 严格模式
- 遵循 ESLint 规则
- 编写清晰的注释
- 保持代码整洁

## 七、常见问题解决

### 7.1 构建问题

```bash
# 清理缓存
rm -rf .next
npm run build
```

### 7.2 依赖问题

```bash
# 使用淘宝镜像
npm config set registry https://registry.npmmirror.com
npm install
```

### 7.3 API 问题

- 检查 Dify 服务状态
- 验证 API 密钥
- 确认请求格式

## 八、扩展功能建议

### 8.1 功能扩展

- 添加用户系统
- 实现结果保存
- 添加批量预测
- 支持更多命理体系

### 8.2 性能提升

- 使用 Redis 缓存
- 优化八字计算
- 实现预测结果缓存

### 8.3 用户体验

- 添加动画效果
- 优化加载状态
- 改进错误提示
- 增加操作引导
