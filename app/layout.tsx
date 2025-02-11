import './globals.css'
import { Inter } from 'next/font/google'
import { Providers } from './providers'
import ThemeSwitch from './components/theme-switch'

const inter = Inter({ subsets: ['latin'] })

export const metadata = {
  title: '未来变量观测局',
  description: '基于 Next.js 的现代命理预测平台',
}

export default function RootLayout({
  children,
}: {
  children: React.ReactNode
}) {
  return (
    <html lang="zh-CN" suppressHydrationWarning>
      <body className={`${inter.className} min-h-screen bg-white dark:bg-dark-bg text-gray-900 dark:text-dark-text antialiased`}>
        <Providers>
          <div className="fixed top-4 right-4 z-50 backdrop-blur-sm bg-white/30 dark:bg-dark-container/30 rounded-lg shadow-sm">
            <ThemeSwitch />
          </div>
          <main className="transition-colors duration-200">
            {children}
          </main>
        </Providers>
      </body>
    </html>
  )
}
