import { type NextRequest } from 'next/server'
import { getInfo, setSession, fetchPredict } from '../utils/common'

export async function POST(request: NextRequest) {
  try {
    const { sessionId, user } = getInfo(request)
    const body = await request.json()

    const response = await fetchPredict({
      ...body,
      user,
      conversation_id: sessionId
    })

    return new Response(
      JSON.stringify(response),
      {
        headers: {
          ...setSession(sessionId),
          'Content-Type': 'application/json'
        }
      }
    )
  } catch (error) {
    console.error('Message API Error:', error)
    return new Response(
      JSON.stringify({ 
        success: false, 
        message: error instanceof Error ? error.message : '预测请求失败' 
      }),
      { 
        status: 500,
        headers: { 'Content-Type': 'application/json' }
      }
    )
  }
}
