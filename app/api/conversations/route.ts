import { type NextRequest } from 'next/server'
import { getInfo, setSession } from '../utils/common'

export async function POST(request: NextRequest) {
  try {
    const { sessionId } = getInfo(request)
    
    return new Response(
      JSON.stringify({ 
        success: true,
        data: { 
          conversation_id: sessionId 
        }
      }),
      {
        headers: {
          ...setSession(sessionId),
          'Content-Type': 'application/json'
        }
      }
    )
  } catch (error) {
    return new Response(
      JSON.stringify({ 
        success: false, 
        message: 'Failed to create conversation' 
      }),
      { 
        status: 500,
        headers: { 'Content-Type': 'application/json' }
      }
    )
  }
}
