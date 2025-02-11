'use client'

import { useState, useEffect } from 'react'
import { Form, Radio, Select, Button, Card, message, Descriptions, Input, DatePicker, Checkbox } from 'antd'
import type { PredictionForm, PredictionResult, PredictionDirection } from '@/types/prediction'
import { fetchPredict } from '@/service/predict'
import ReactMarkdown from 'react-markdown'
import locale from 'antd/locale/zh_CN'
import dayjs from 'dayjs'
import 'dayjs/locale/zh-cn'
import { Solar } from 'lunar-javascript'
import { formatPredictionToMarkdown } from '@/utils/formatPrediction'
import remarkGfm from 'remark-gfm'

dayjs.locale('zh-cn')

const { TextArea } = Input
const { RangePicker } = DatePicker
const { Option } = Select

const directions = [
  { label: '事业发展', value: 'career', icon: '💼' },
  { label: '感情状况', value: 'relationship', icon: '❤️' },
  { label: '财运预测', value: 'wealth', icon: '💰' },
  { label: '健康状况', value: 'health', icon: '🏥' }
]

// 定义时辰
const timeSlots = [
  { start: 23, end: 1, name: '子时' },
  { start: 1, end: 3, name: '丑时' },
  { start: 3, end: 5, name: '寅时' },
  { start: 5, end: 7, name: '卯时' },
  { start: 7, end: 9, name: '辰时' },
  { start: 9, end: 11, name: '巳时' },
  { start: 11, end: 13, name: '午时' },
  { start: 13, end: 15, name: '未时' },
  { start: 15, end: 17, name: '申时' },
  { start: 17, end: 19, name: '酉时' },
  { start: 19, end: 21, name: '戌时' },
  { start: 21, end: 23, name: '亥时' }
]

export default function PredictionPage() {
  const [form] = Form.useForm()
  const [loading, setLoading] = useState(false)
  const [result, setResult] = useState<PredictionResult | null>(null)
  const [error, setError] = useState<string>('')
  const [calendarType, setCalendarType] = useState<'solar' | 'lunar'>('solar')
  const [selectedYear, setSelectedYear] = useState(new Date().getFullYear())
  const [selectedMonth, setSelectedMonth] = useState(1)
  const [lunarInfo, setLunarInfo] = useState<{
    lunarDate: string
    bazi: string
    wuxing: string
    nayin: string
    shishen: string
    yun?: {
      startInfo: string
      daYun: string[]
    }
  } | null>(null)

  // 生成年份选项：1900年至今年，倒序排列
  const currentYear = new Date().getFullYear()
  const yearOptions = Array.from(
    { length: currentYear - 1900 + 1 },
    (_, i) => currentYear - i
  )

  // 生成月份选项：1-12月
  const monthOptions = Array.from({ length: 12 }, (_, i) => i + 1)

  // 生成日期选项：1-31日
  const dayOptions = Array.from({ length: 31 }, (_, i) => i + 1)

  // 生成小时选项：0-23时
  const hourOptions = Array.from({ length: 24 }, (_, i) => i)

  // 根据年月计算当月天数
  const getDaysInMonth = (year: number, month: number) => {
    return new Date(year, month, 0).getDate()
  }

  // 当年份或月份改变时，更新日期选项
  const currentDayOptions = Array.from(
    { length: getDaysInMonth(selectedYear, selectedMonth) },
    (_, i) => i + 1
  )

  // 获取时辰名称
  const getTimeSlotName = (hour: number) => {
    const slot = timeSlots.find(slot => {
      if (slot.start > slot.end) { // 跨夜的子时
        return hour >= slot.start || hour < slot.end
      }
      return hour >= slot.start && hour < slot.end
    })
    return slot?.name || '子时'
  }

  // 实时计算农历和八字
  const calculateLunarInfo = (year?: number, month?: number, day?: number, hour?: number) => {
    if (!year || !month || !day) return null

    try {
      const solar = Solar.fromYmd(year, month, day)
      const lunar = solar.getLunar()
      const eightChar = lunar.getEightChar()

      // 计算大运
      const yun = eightChar.getYun(form.getFieldValue('gender') === 'male' ? 1 : 0)
      const daYunArr = yun.getDaYun()

      // 获取大运信息
      const daYunInfo = daYunArr.slice(0, 8).map((daYun, index) =>
        `${daYun.getStartYear()}年 ${daYun.getStartAge()}岁 ${daYun.getGanZhi()}`
      )

      return {
        lunarDate: `${lunar.getYearInChinese()}年${lunar.getMonthInChinese()}月${lunar.getDayInChinese()}`,
        bazi: `${eightChar.getYear()} ${eightChar.getMonth()} ${eightChar.getDay()} ${hour ? eightChar.getTime() : ''}`,
        wuxing: `${eightChar.getYearWuXing()},${eightChar.getMonthWuXing()},${eightChar.getDayWuXing()},${eightChar.getTimeWuXing()}`,
        nayin: `${eightChar.getYearNaYin()},${eightChar.getMonthNaYin()},${eightChar.getDayNaYin()},${eightChar.getTimeNaYin()}`,
        shishen: `年干:${eightChar.getYearShiShenGan()} 月干:${eightChar.getMonthShiShenGan()} 日干:${eightChar.getDayShiShenGan()} 时干:${eightChar.getTimeShiShenGan()}`,
        yun: {
          startInfo: `出生${yun.getStartYear()}年${yun.getStartMonth()}月${yun.getStartDay()}天后起运`,
          daYun: daYunInfo
        }
      }
    } catch (err) {
      console.error('Calculate lunar info error:', err)
      return null
    }
  }

  // 监听日期变化
  useEffect(() => {
    const values = form.getFieldsValue()
    if (values.birthYear && values.birthMonth && values.birthDay) {
      const info = calculateLunarInfo(
        values.birthYear,
        values.birthMonth,
        values.birthDay,
        values.birthHour
      )
      setLunarInfo(info)
    }
  }, [form.getFieldValue('birthYear'), form.getFieldValue('birthMonth'),
  form.getFieldValue('birthDay'), form.getFieldValue('birthHour')])

  const handleDateTimeChange = (type: 'year' | 'month' | 'day' | 'hour', value: number) => {
    const currentValues = form.getFieldsValue()
    const newValues = {
      ...currentValues,
      [`birth${type.charAt(0).toUpperCase() + type.slice(1)}`]: value
    }

    form.setFieldsValue(newValues)

    if (newValues.birthYear && newValues.birthMonth && newValues.birthDay) {
      const info = calculateLunarInfo(
        newValues.birthYear,
        newValues.birthMonth,
        newValues.birthDay,
        newValues.birthHour
      )
      setLunarInfo(info)
    }
  }

  const onFinish = async (values: any) => {
    const formData: PredictionForm = {
      ...values,
      birthDate: `${values.birthYear}-${String(values.birthMonth).padStart(2, '0')}-${String(values.birthDay).padStart(2, '0')}`,
      birthTime: `${String(values.birthHour).padStart(2, '0')}:00`,
    }

    // 构建查询内容
    const queryContent = {
      basic_info: {
        gender: formData.gender === 'male' ? '男' : formData.gender === 'female' ? '女' : '其他',
        birth_time: {
          solar: `${formData.birthDate} ${formData.birthTime}`,
          lunar: lunarInfo?.lunarDate || '',
        }
      },
      destiny_info: {
        bazi: lunarInfo?.bazi || '',
        wuxing: lunarInfo?.wuxing || '',
        nayin: lunarInfo?.nayin || '',
        shishen: lunarInfo?.shishen || '',
        yun: lunarInfo?.yun ? {
          start: lunarInfo.yun.startInfo,
          dayun: lunarInfo.yun.daYun
        } : undefined
      },
      prediction: {
        directions: formData.direction,
        custom_directions: formData.customDirections || '',
      }
    }

    setError('')
    setLoading(true)
    try {
      const response = await fetchPredict({
        ...formData,
        query: JSON.stringify(queryContent),
        response_mode: "streaming",
        user: formData.user || 'anonymous',
        conversation_id: formData.conversation_id
      })

      // 构造符合 PredictionResult 类型的结果
      const predictionResult: PredictionResult = {
        id: response.id || crypto.randomUUID(),
        userId: formData.user || 'anonymous',
        timestamp: Date.now(),
        inputs: {
          gender: formData.gender,
          birthDateTime: `${formData.birthDate} ${formData.birthTime}`,
          directions: formData.direction
        },
        result: response.content
      }

      setResult(predictionResult)
      message.success('预测完成')
    } catch (err) {
      console.error('Prediction Error:', err)
      setError(err instanceof Error ? err.message : '预测失败，请稍后重试')
      message.error('预测失败，请稍后重试')
    } finally {
      setLoading(false)
    }
  }

  // 修改格式化函数
  const formatPredictionContent = (content: string) => {
    try {
      // 尝试解析 JSON 字符串
      let parsedContent = content
      if (typeof content === 'string' && content.startsWith('{')) {
        const jsonContent = JSON.parse(content)
        // 获取 answer 字段中的内容
        parsedContent = jsonContent.answer || jsonContent.content || jsonContent.text || content
      }

      // 移除 Thinking... 部分
      parsedContent = parsedContent.replace(/<details.*?<\/details>/s, '').trim()

      // 处理表格部分
      const formatTables = (text: string) => {
        // 查找表格部分（包括表格标记符和表头）
        const tableRegex = /(\|[^\n]*\|\n*)+/g
        return text.replace(tableRegex, (match) => {
          // 只移除表格中的 emoji，保留其他部分的 emoji
          const cleanedTable = match.replace(/\|([^|]*[\u{1F300}-\u{1F6FF}\u{1F900}-\u{1F9FF}]|[🌐📊][^|]*)\|/gu, '|$1|')
          // 确保表格格式正确
          return cleanedTable
            .split('\n')
            .map(line => line.trim())
            .filter(line => line.length > 0)
            .join('\n')
        })
      }

      // 清理表格格式
      const cleanupTables = (text: string) => {
        return text
          .replace(/\|\s*\|/g, '|')      // 移除空列
          .replace(/\|\s+/g, '| ')       // 规范化左侧空格
          .replace(/\s+\|/g, ' |')       // 规范化右侧空格
          .replace(/^\s*\|/, '|')        // 确保行首的竖线
          .replace(/\|\s*$/, '|')        // 确保行尾的竖线
          .replace(/\n{3,}/g, '\n\n')    // 移除多余的空行
      }

      // 处理内容
      const formattedContent = formatTables(parsedContent)
      return cleanupTables(formattedContent)
    } catch (err) {
      console.error('Format prediction content error:', err)
      return content // 如果处理失败，返回原始内容
    }
  }

  const formattedResult = formatPredictionToMarkdown(result)

  return (
    <div className="max-w-3xl mx-auto p-4">
      <h1 className="text-2xl font-bold text-center mb-8">未来变量观测</h1>

      <Form
        form={form}
        layout="vertical"
        onFinish={onFinish}
        initialValues={{
          calendarType: 'solar',
          birthDate: dayjs(),
          birthHour: 12, // 默认午时
        }}
      >
        <Form.Item
          label="性别"
          name="gender"
          rules={[{ required: true, message: '请选择性别' }]}
        >
          <Radio.Group buttonStyle="solid" className="w-full">
            <Radio.Button value="male" className="w-1/3 text-center">👨 男</Radio.Button>
            <Radio.Button value="female" className="w-1/3 text-center">👩 女</Radio.Button>
            <Radio.Button value="other" className="w-1/3 text-center">⭐ 其他</Radio.Button>
          </Radio.Group>
        </Form.Item>

        <Form.Item
          label="历法选择"
          name="calendarType"
        >
          <Radio.Group
            onChange={(e) => setCalendarType(e.target.value)}
            buttonStyle="solid"
            className="w-full"
          >
            <Radio.Button value="solar" className="w-1/2 text-center">📅 公历</Radio.Button>
            <Radio.Button value="lunar" className="w-1/2 text-center">🏮 农历</Radio.Button>
          </Radio.Group>
        </Form.Item>

        <div className="grid grid-cols-2 md:grid-cols-3 gap-4">
          <Form.Item
            label="出生年份"
            name="birthYear"
            rules={[{ required: true, message: '请选择出生年份' }]}
          >
            <Select
              placeholder="年"
              onChange={(value) => handleDateTimeChange('year', value)}
              className="w-full"
            >
              {yearOptions.map(year => (
                <Option key={year} value={year}>{year}年</Option>
              ))}
            </Select>
          </Form.Item>

          <Form.Item
            label="月份"
            name="birthMonth"
            rules={[{ required: true, message: '请选择月份' }]}
          >
            <Select
              placeholder="月"
              onChange={(value) => handleDateTimeChange('month', value)}
              className="w-full"
            >
              {monthOptions.map(month => (
                <Option key={month} value={month}>{month}月</Option>
              ))}
            </Select>
          </Form.Item>

          <Form.Item
            label="日期"
            name="birthDay"
            rules={[{ required: true, message: '请选择日期' }]}
          >
            <Select
              placeholder="日"
              onChange={(value) => handleDateTimeChange('day', value)}
              className="w-full"
            >
              {currentDayOptions.map(day => (
                <Option key={day} value={day}>{day}日</Option>
              ))}
            </Select>
          </Form.Item>

          <Form.Item
            label="时辰"
            name="birthHour"
            rules={[{ required: true, message: '请选择时辰' }]}
          >
            <Select
              placeholder="时辰"
              onChange={(value) => handleDateTimeChange('hour', value)}
              className="w-full"
            >
              {timeSlots.map((slot, index) => (
                <Option
                  key={index}
                  value={slot.start}
                >
                  {slot.name} ({String(slot.start).padStart(2, '0')}:00-{String(slot.end).padStart(2, '0')}:00)
                </Option>
              ))}
            </Select>
          </Form.Item>
        </div>

        {lunarInfo && (
          <div className="my-4 p-4 bg-gray-50 rounded-lg">
            <Descriptions
              bordered
              size="small"
              column={{ xs: 1, sm: 2 }}
              className="bg-white rounded-lg"
            >
              <Descriptions.Item label="农历日期" span={2}>
                {lunarInfo.lunarDate}
              </Descriptions.Item>
              <Descriptions.Item label="八字" span={2}>
                {lunarInfo.bazi}
              </Descriptions.Item>
              <Descriptions.Item label="五行" span={2}>
                {lunarInfo.wuxing}
              </Descriptions.Item>
              <Descriptions.Item label="纳音" span={2}>
                {lunarInfo.nayin}
              </Descriptions.Item>
              <Descriptions.Item label="十神" span={2}>
                {lunarInfo.shishen}
              </Descriptions.Item>
              {lunarInfo.yun && (
                <>
                  <Descriptions.Item label="起运时间" span={2}>
                    {lunarInfo.yun.startInfo}
                  </Descriptions.Item>
                  <Descriptions.Item label="大运" span={2}>
                    <div className="grid grid-cols-2 gap-2">
                      {lunarInfo.yun.daYun.map((dayun, index) => (
                        <div key={index} className="text-sm">
                          {dayun}
                        </div>
                      ))}
                    </div>
                  </Descriptions.Item>
                </>
              )}
            </Descriptions>
          </div>
        )}

        <Form.Item
          label="预测方向"
          required
          className="mb-8"
        >
          <div className="space-y-4">
            <Form.Item
              name="direction"
              rules={[{ required: true, message: '请至少选择一个预测方向' }]}
            >
              <Checkbox.Group className="grid grid-cols-2 gap-4">
                {directions.map(d => (
                  <Checkbox key={d.value} value={d.value} className="bg-white p-3 rounded-lg shadow-sm border hover:shadow-md transition-shadow">
                    <span className="flex items-center gap-2">
                      <span className="text-xl">{d.icon}</span>
                      <span>{d.label}</span>
                    </span>
                  </Checkbox>
                ))}
              </Checkbox.Group>
            </Form.Item>

            <Form.Item
              name="customDirections"
            >
              <TextArea
                placeholder="其他感兴趣的预测方向（选填，每行一个）"
                autoSize={{ minRows: 2, maxRows: 6 }}
                className="rounded-lg"
              />
            </Form.Item>
          </div>
        </Form.Item>

        <Form.Item>
          <Button
            type="primary"
            htmlType="submit"
            loading={loading}
            block
            size="large"
            className="h-12 text-lg"
          >
            {loading ? '正在推算命运轨迹...' : '开始预测'}
          </Button>
        </Form.Item>
      </Form>

      {error && (
        <div className="mt-4 p-4 bg-red-50 text-red-500 rounded-lg">
          {error}
        </div>
      )}

      {result && (
        <Card className="mt-8 rounded-lg shadow-lg">
          <div className="text-sm text-gray-500 mb-2">
            预测时间: {new Date(result.timestamp).toLocaleString()}
          </div>
          <article className="prose prose-sm max-w-none dark:prose-invert whitespace-pre-wrap break-words">
            <ReactMarkdown
              components={{
                // 自定义表格容器样式
                table: ({ node, ...props }) => (
                  <div className="overflow-x-auto my-6">
                    <table className="min-w-full divide-y divide-gray-200 bg-white rounded-lg shadow-sm border border-gray-200" {...props} />
                  </div>
                ),

                // 自定义表格头部样式
                th: ({ node, ...props }) => (
                  <th
                    className="px-6 py-4 bg-gray-50 text-left text-sm font-semibold text-gray-600 border-b border-gray-200 first:rounded-tl-lg last:rounded-tr-lg"
                    {...props}
                  />
                ),

                // 自定义表格单元格样式
                td: ({ node, ...props }) => (
                  <td
                    className="px-6 py-4 text-sm text-gray-800 border-b border-gray-100 align-top whitespace-pre-wrap break-words"
                    {...props}
                  />
                ),

                // 自定义表格行样式
                tr: ({ node, ...props }) => (
                  <tr
                    className="hover:bg-gray-50 transition-colors even:bg-gray-50/20"
                    {...props}
                  />
                ),

                // 自定义段落样式，保留原始格式
                p: ({ node, children, ...props }) => (
                  <p className="my-4 text-base leading-relaxed whitespace-pre-wrap" {...props}>
                    {children}
                  </p>
                ),

                // 自定义标题样式
                h1: ({ node, children, ...props }) => (
                  <h1 className="text-2xl font-bold my-4 whitespace-pre-wrap" {...props}>
                    {children}
                  </h1>
                ),
                h2: ({ node, children, ...props }) => (
                  <h2 className="text-xl font-semibold my-3 whitespace-pre-wrap" {...props}>
                    {children}
                  </h2>
                ),
                h3: ({ node, children, ...props }) => (
                  <h3 className="text-lg font-medium my-2 whitespace-pre-wrap" {...props}>
                    {children}
                  </h3>
                ),

                // 自定义列表样式
                ul: ({ node, ...props }) => (
                  <ul className="list-disc pl-6 space-y-2 my-4 whitespace-pre-wrap" {...props} />
                ),
                ol: ({ node, ...props }) => (
                  <ol className="list-decimal pl-6 space-y-2 my-4 whitespace-pre-wrap" {...props} />
                ),
                li: ({ node, children, ...props }) => (
                  <li className="text-base leading-relaxed whitespace-pre-wrap" {...props}>
                    {children}
                  </li>
                ),

                // 添加分隔线样式
                hr: ({ node, ...props }) => (
                  <hr className="my-8 border-t-2 border-gray-200" {...props} />
                ),

                // 添加引用样式
                blockquote: ({ node, children, ...props }) => (
                  <blockquote
                    className="pl-4 border-l-4 border-gray-200 italic my-4 text-gray-600 whitespace-pre-wrap"
                    {...props}
                  >
                    {children}
                  </blockquote>
                ),

                // 添加代码块样式
                code: ({ node, inline, children, ...props }) => {
                  if (inline) {
                    return <code className="px-1 py-0.5 bg-gray-100 rounded" {...props}>{children}</code>
                  }
                  return (
                    <pre className="p-4 bg-gray-50 rounded-lg overflow-x-auto whitespace-pre-wrap">
                      <code {...props}>{children}</code>
                    </pre>
                  )
                }
              }}
            >
              {formattedResult}
            </ReactMarkdown>
          </article>
        </Card>
      )}
    </div>
  )
} 