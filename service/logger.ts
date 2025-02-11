import { v4 as uuidv4 } from 'uuid'

interface LogData {
  userId: string
  timestamp: number
  inputs: {
    gender: string
    birthDateTime: string
    directions: string[]
  }
  result: string
}

export async function logPrediction(data: LogData) {
  const logEntry = {
    id: uuidv4(),
    ...data,
  }

  console.log('Prediction Log:', logEntry)
  
  // TODO: 未来可以添加日志存储服务
  return logEntry
} 