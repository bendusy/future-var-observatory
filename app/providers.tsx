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
  const { theme: currentTheme, systemTheme } = useTheme()
  const [mounted, setMounted] = useState(false)

  useEffect(() => {
    setMounted(true)
  }, [])

  if (!mounted) {
    return <ConfigProvider theme={{
      algorithm: theme.defaultAlgorithm,
      token: {
        colorPrimary: '#1677ff',
        borderRadius: 8,
      }
    }}>{children}</ConfigProvider>
  }

  const isDark =
    currentTheme === 'dark' ||
    (currentTheme === 'system' && systemTheme === 'dark')

  return (
    <ConfigProvider
      theme={{
        algorithm: isDark ? theme.darkAlgorithm : theme.defaultAlgorithm,
        token: {
          colorPrimary: '#1677ff',
          borderRadius: 8,
        },
        components: {
          Button: {
            controlHeight: 40,
            paddingContentHorizontal: 24,
            colorBgContainer: isDark ? '#1f1f1f' : '#ffffff',
            colorText: isDark ? '#ffffff' : undefined,
          },
          Input: {
            controlHeight: 40,
            paddingContentHorizontal: 16,
            colorBgContainer: isDark ? '#1f1f1f' : '#ffffff',
            colorText: isDark ? '#ffffff' : undefined,
          },
          Select: {
            controlHeight: 40,
            colorBgContainer: isDark ? '#1f1f1f' : '#ffffff',
            colorText: isDark ? '#ffffff' : undefined,
            colorBgElevated: isDark ? '#1f1f1f' : '#ffffff',
            optionSelectedBg: isDark ? '#141414' : '#e6f4ff',
          },
          Modal: {
            borderRadiusLG: 12,
            paddingContentHorizontalLG: 24,
            colorBgElevated: isDark ? '#1f1f1f' : '#ffffff',
            colorText: isDark ? '#ffffff' : undefined,
          }
        }
      }}
    >
      {children}
    </ConfigProvider>
  )
} 