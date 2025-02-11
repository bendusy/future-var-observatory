export interface PredictionQuery {
  basic_info: {
    gender: string
    birth_time: {
      solar: string
      lunar: string
    }
  }
  destiny_info: {
    bazi: string
    wuxing: string
    nayin: string
    shishen: string
    yun?: {
      start: string
      dayun: string[]
    }
  }
  prediction: {
    directions: string[]
    custom_directions: string
  }
}

export interface PredictionForm {
  gender: 'male' | 'female' | 'other'
  birthDate: string
  birthTime: string
  calendarType: 'solar' | 'lunar'
  direction: string[]
  customDirections?: string
  user?: string
  conversation_id?: string
  response_mode?: 'streaming' | 'blocking'
}

export interface BaziInfo {
  solarDate: string    // 公历日期
  lunarDate: string    // 农历日期
  year: string         // 年柱
  month: string        // 月柱
  day: string          // 日柱
  hour: string         // 时柱
  currentBazi: string  // 当前时辰八字
}

// 定义预测输入参数的接口
export interface PredictionInput {
  gender: 'male' | 'female'
  birthDateTime: string
  directions: Array<'career' | 'wealth' | 'relationship' | 'health'>
}

// 定义预测结果的接口
export interface PredictionResult {
  id: string
  userId: string
  timestamp: number
  inputs: {
    gender: string
    birthDateTime: string
    directions: string[]
  }
  result: any
}

// 定义预测方向的枚举
export enum PredictionDirection {
  Career = 'career',
  Wealth = 'wealth',
  Relationship = 'relationship',
  Health = 'health'
} 