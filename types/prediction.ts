// 基础方向枚举
export enum PredictionDirection {
  Career = 'career',
  Wealth = 'wealth',
  Relationship = 'relationship',
  Health = 'health'
}

// 性别类型
export type Gender = 'male' | 'female' | 'other'

// 基础信息接口
export interface BasicInfo {
  gender: Gender
  birthTime: {
    solar: string
    lunar: string
  }
}

// 命理信息接口
export interface DestinyInfo {
  bazi: string
  wuxing: string
  nayin: string
  shishen: string
  yun?: {
    start: string
    dayun: string[]
  }
}

// 预测查询接口
export interface PredictionQuery {
  basic_info: BasicInfo
  destiny_info: DestinyInfo
  prediction: {
    directions: Array<keyof typeof PredictionDirection>
    custom_directions?: string
  }
}

// 预测表单接口
export interface PredictionForm {
  gender: Gender
  birthDate: string
  birthTime: string
  calendarType: 'solar' | 'lunar'
  direction: Array<keyof typeof PredictionDirection>
  customDirections?: string
  user?: string
  conversation_id?: string
  response_mode?: 'streaming' | 'blocking'
}

// 八字信息接口
export interface BaziInfo {
  solarDate: string    // 公历日期
  lunarDate: string    // 农历日期
  year: string         // 年柱
  month: string        // 月柱
  day: string          // 日柱
  hour: string         // 时柱
  currentBazi: string  // 当前时辰八字
}

// 预测结果接口
export interface PredictionResult {
  id: string
  userId: string
  timestamp: number
  inputs: {
    gender: Gender
    birthDateTime: string
    directions: Array<keyof typeof PredictionDirection>
  }
  result: any // 建议定义具体的结果类型
} 