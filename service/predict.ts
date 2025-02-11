import { type PredictionForm } from '@/types/prediction'
import { APP_ID, API_KEY, API_URL } from '@/config'
import { logPrediction } from './logger'
import { Lunar, Solar } from 'lunar-javascript'

export async function fetchPredict(data: PredictionForm) {
  try {
    const response = await fetch('/api/predict', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify(data)
    })

    if (!response.ok) {
      throw new Error('预测请求失败')
    }

    const result = await response.json()

    // 记录预测日志
    await logPrediction({
      userId: 'anonymous',
      timestamp: Date.now(),
      inputs: {
        gender: data.gender,
        birthDateTime: `${data.birthDate} ${data.birthTime}`,
        directions: data.direction
      },
      result: result.answer
    })

    return {
      content: result.answer,
      timestamp: Date.now()
    }
  } catch (error) {
    console.error('预测失败:', error)
    throw error
  }
}

function calculateBazi(date: string, time: string, isLunar: boolean): BaziInfo {
  const [year, month, day] = date.split('-').map(Number)
  const [hour] = time.split(':').map(Number)

  const solar = Solar.fromYmd(year, month, day)
  const lunar = isLunar ? Lunar.fromYmd(year, month, day) : solar.getLunar()

  return {
    solarDate: solar.toYmd(),
    lunarDate: `${lunar.getYearInChinese()}年${lunar.getMonthInChinese()}月${lunar.getDayInChinese()}`,
    year: lunar.getYearInGanZhi(),
    month: lunar.getMonthInGanZhi(),
    day: lunar.getDayInGanZhi(),
    hour: lunar.getTimeZhi()
  }
}

function generatePrompt(data: PredictionForm, bazi: BaziInfo): string {
  const directions = data.direction.join('、')
  const customDirs = data.customDirections ? `\n- 自定义方向：${data.customDirections}` : ''

  return `请根据以下信息进行未来预测：

## 基本信息
- 性别：${data.gender === 'male' ? '男' : data.gender === 'female' ? '女' : '其他'}
- 公历：${bazi.solarDate}
- 农历：${bazi.lunarDate}
- 八字：${bazi.year} ${bazi.month} ${bazi.day} ${bazi.hour}
- 预测方向：${directions}${customDirs}`
} 