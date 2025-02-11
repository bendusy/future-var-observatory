'use client'

import { ThemeProvider, useTheme } from 'next-themes'
import { ConfigProvider, theme } from 'antd'
import { useEffect, useState } from 'react'

export function Providers({ children }: { children: React.ReactNode }) {
  const [mounted, setMounted] = useState(false)

  // 避免服务端渲染不匹配
  useEffect(() => {
    setMounted(true)
  }, [])

  if (!mounted) {
    return null
  }

  return (
    <ThemeProvider
      attribute="class"
      defaultTheme="system"
      enableSystem
      disableTransitionOnChange
    >
      <AntdProvider>{children}</AntdProvider>
    </ThemeProvider>
  )
}

// 分离 Ant Design 主题配置
function AntdProvider({ children }: { children: React.ReactNode }) {
  const { theme: currentTheme } = useTheme()

  return (
    <ConfigProvider
      theme={{
        algorithm:
          currentTheme === 'dark'
            ? theme.darkAlgorithm
            : theme.defaultAlgorithm,
        token: {
          colorPrimary: '#1677ff',
          borderRadius: 8,
        },
        components: {
          Button: {
            controlHeight: 40,
            paddingContentHorizontal: 24,
          },
          Input: {
            controlHeight: 40,
            paddingContentHorizontal: 16,
          },
          Select: {
            controlHeight: 40,
          },
          Modal: {
            borderRadiusLG: 12,
            paddingContentHorizontalLG: 24,
          }
        }
      }}
    >
      {children}
    </ConfigProvider>
  )
} 