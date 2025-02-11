'use client'

import { useEffect, useState } from 'react'
import { useTheme } from 'next-themes'
import { Button, Tooltip } from 'antd'
import { SunIcon, MoonIcon, ComputerDesktopIcon } from '@heroicons/react/24/outline'

const themeIcons = {
    light: <SunIcon className="w-5 h-5 text-yellow-500" />,
    dark: <MoonIcon className="w-5 h-5 text-blue-400" />,
    system: <ComputerDesktopIcon className="w-5 h-5 text-gray-500 dark:text-gray-400" />
}

const themeNames = {
    light: '浅色模式',
    dark: '深色模式',
    system: '跟随系统'
}

export default function ThemeSwitch() {
    const [mounted, setMounted] = useState(false)
    const { theme, setTheme } = useTheme()
    const [isHovering, setIsHovering] = useState(false)

    // 在组件挂载后再显示,避免服务端渲染不匹配
    useEffect(() => {
        setMounted(true)
    }, [])

    if (!mounted) {
        return null
    }

    // 切换主题的顺序
    const toggleTheme = () => {
        const themes = ['light', 'dark', 'system']
        const currentIndex = themes.indexOf(theme || 'system')
        const nextIndex = (currentIndex + 1) % themes.length
        setTheme(themes[nextIndex])
    }

    return (
        <Tooltip
            title={themeNames[theme as keyof typeof themeNames]}
            placement="left"
        >
            <Button
                type="text"
                className="w-10 h-10 p-0 hover:bg-gray-100 dark:hover:bg-dark-container rounded-lg transition-colors duration-200"
                onClick={toggleTheme}
                onMouseEnter={() => setIsHovering(true)}
                onMouseLeave={() => setIsHovering(false)}
                icon={
                    <div className={`transform transition-transform duration-200 ${isHovering ? 'scale-110' : ''}`}>
                        {themeIcons[theme as keyof typeof themeIcons]}
                    </div>
                }
            />
        </Tooltip>
    )
} 