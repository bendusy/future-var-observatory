import type { AppInfo } from '@/types/app'
export const APP_ID = process.env.NEXT_PUBLIC_APP_ID || '209d1e08-1444-4b9a-9889-f0ab52950871'
export const API_KEY = process.env.NEXT_PUBLIC_APP_KEY || 'app-6HieEUaeU2pEhdooKhr1c9rK'
export const API_URL = process.env.NEXT_PUBLIC_API_URL || 'https://dify.nciex.com/v1'
export const APP_INFO = {
  title: '未来变量观测局',
  description: '基于人工智能的未来变量观测系统',
  copyright: '',
  privacy_policy: '',
  default_language: 'zh-Hans'
}

export const isShowPrompt = false
export const promptTemplate = 'I want you to act as a javascript console.'

export const API_PREFIX = '/api'

export const LOCALE_COOKIE_NAME = 'locale'

export const DEFAULT_VALUE_MAX_LEN = 48
