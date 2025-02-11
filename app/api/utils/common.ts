import { type NextRequest } from 'next/server'
import { v4 } from 'uuid'
import { API_KEY, API_URL, APP_ID } from '@/config'
import { ChatClient } from 'dify-client'

const userPrefix = `user_${APP_ID}:`

export const client = new ChatClient(API_KEY)

export const getInfo = (request: NextRequest) => {
  const sessionId = request.cookies.get('session_id')?.value || v4()
  const user = userPrefix + sessionId
  return {
    sessionId,
    user,
  }
}

export const setSession = (sessionId: string) => {
  return { 'Set-Cookie': `session_id=${sessionId}` }
}

export async function fetchPredict(data: any) {
  try {
    const response = await client.createChatMessage({}, data.query, data.user, false)
    return response
  } catch (error) {
    throw new Error('预测请求失败')
  }
}
