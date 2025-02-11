'use client'

import { useState, useEffect } from 'react'
import { Form, Radio, Select, Button, Card, message, Descriptions, Input, Checkbox, Modal } from 'antd'
import type { PredictionForm, PredictionResult } from '@/types/prediction'
import { fetchPredict } from '@/service/predict'
import ReactMarkdown from 'react-markdown'
import dayjs from 'dayjs'
import 'dayjs/locale/zh-cn'
import { formatPredictionToMarkdown } from '@/utils/formatPrediction'
import remarkGfm from 'remark-gfm'
import { useRouter } from 'next/navigation'
<<<<<<< HEAD
<<<<<<< HEAD
import { Solar, Lunar } from 'lunar-typescript'
=======
>>>>>>> parent of cd4b067 (chore: Add lunar-typescript and improve type safety in prediction page)
=======
>>>>>>> parent of cd4b067 (chore: Add lunar-typescript and improve type safety in prediction page)

dayjs.locale('zh-cn')

const { TextArea } = Input
const { Option } = Select

// 预测方向配置
const directions = [
  { label: '事业发展', value: 'career', icon: '💼' },
  { label: '感情状况', value: 'relationship', icon: '❤️' },
  { label: '财运预测', value: 'wealth', icon: '💰' },
  { label: '健康状况', value: 'health', icon: '🏥' }
]

// 时辰配置
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
].map(slot => ({
  ...slot,
  label: `${slot.name} (${String(slot.start).padStart(2, '0')}:00-${String(slot.end).padStart(2, '0')}:00)`
}))

export default function PredictionPage() {
  // 基础状态管理
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
  const router = useRouter()

  // 日期选项生成
  const currentYear = new Date().getFullYear()
  const yearOptions = Array.from({ length: currentYear - 1900 + 1 }, (_, i) => currentYear - i)
  const monthOptions = Array.from({ length: 12 }, (_, i) => i + 1)
  const getDaysInMonth = (year: number, month: number) => new Date(year, month, 0).getDate()

  // 当年份或月份改变时，更新日期选项
  const currentDayOptions = Array.from(
    { length: getDaysInMonth(selectedYear, selectedMonth) },
    (_, i) => i + 1
  )

  // 实时计算农历和八字
  const calculateLunarInfo = (year?: number, month?: number, day?: number, hour?: number) => {
    if (!year || !month || !day) return null;

    try {
      const solar = Solar.fromYmd(year, month, day);
      const lunar = solar.getLunar();
      const eightChar = lunar.getEightChar();

      // 添加类型声明
      interface EightChar {
        getYear: () => string;
        getMonth: () => string;
        getDay: () => string;
        getTime: () => string;
        getYearWuXing: () => string;
        getMonthWuXing: () => string;
        getDayWuXing: () => string;
        getTimeWuXing: () => string;
        getYearNaYin: () => string;
        getMonthNaYin: () => string;
        getDayNaYin: () => string;
        getTimeNaYin: () => string;
        getYearShiShenGan: () => string;
        getMonthShiShenGan: () => string;
        getDayShiShenGan: () => string;
        getTimeShiShenGan: () => string;
        getYun: (gender: number) => any;
      }

      // 类型断言
      const typedEightChar = eightChar as unknown as EightChar;

      // 获取完整的八字信息
      const baziInfo = {
        year: typedEightChar.getYear(),
        month: typedEightChar.getMonth(),
        day: typedEightChar.getDay(),
        time: hour !== undefined ? typedEightChar.getTime() : ''
      };

      // 计算大运
      const yun = typedEightChar.getYun(form.getFieldValue('gender') === 'male' ? 1 : 0);
      const daYunArr = yun.getDaYun();

      // 获取大运信息
<<<<<<< HEAD
<<<<<<< HEAD
      const daYunInfo = daYunArr.slice(0, 8).map((daYun: any) =>
=======
      const daYunInfo = daYunArr.slice(0, 8).map((daYun, index) =>
>>>>>>> parent of cd4b067 (chore: Add lunar-typescript and improve type safety in prediction page)
=======
      const daYunInfo = daYunArr.slice(0, 8).map((daYun, index) =>
>>>>>>> parent of cd4b067 (chore: Add lunar-typescript and improve type safety in prediction page)
        `${daYun.getStartYear()}年 ${daYun.getStartAge()}岁 ${daYun.getGanZhi()}`
      );

      return {
        lunarDate: `${lunar.getYearInChinese()}年${lunar.getMonthInChinese()}月${lunar.getDayInChinese()}`,
        bazi: `${baziInfo.year} ${baziInfo.month} ${baziInfo.day} ${baziInfo.time}`.trim(),
        wuxing: `${typedEightChar.getYearWuXing()} ${typedEightChar.getMonthWuXing()} ${typedEightChar.getDayWuXing()} ${typedEightChar.getTimeWuXing()}`.trim(),
        nayin: `${typedEightChar.getYearNaYin()} ${typedEightChar.getMonthNaYin()} ${typedEightChar.getDayNaYin()} ${typedEightChar.getTimeNaYin()}`.trim(),
        shishen: `年干:${typedEightChar.getYearShiShenGan()} 月干:${typedEightChar.getMonthShiShenGan()} 日干:${typedEightChar.getDayShiShenGan()} 时干:${typedEightChar.getTimeShiShenGan()}`,
        yun: {
          startInfo: `出生${yun.getStartYear()}年${yun.getStartMonth()}月${yun.getStartDay()}天后起运`,
          daYun: daYunInfo
        }
      };
    } catch (err) {
      console.error('Calculate lunar info error:', err);
      return null;
    }
  };

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

  // 将 queryContent 提升为组件状态
  const [queryContent, setQueryContent] = useState<any>(null);

  // 更新隐私提示
  useEffect(() => {
    if (!localStorage.getItem('disclaimer_accepted')) {
      Modal.confirm({
        title: '免责声明',
        content: (
          <div className="space-y-4">
            <p>在使用本服务前，请您知悉：</p>
            <ol className="list-decimal pl-4 space-y-2">
              <li>本服务仅供娱乐参考，不构成任何建议或决策依据</li>
              <li>预测结果仅供参考，不对因使用本服务产生的任何后果负责</li>
            </ol>
          </div>
        ),
        okText: '同意并继续',
        cancelText: '不同意',
        onOk: () => localStorage.setItem('disclaimer_accepted', 'true'),
        onCancel: () => {
          message.info('您需要同意免责声明才能使用本服务')
          router.push('/')
        },
        width: 600,
      })
    }
  }, [router])

  const onFinish = async (values: any) => {
    setError('')
    setLoading(true)

    try {
      const formData = {
        ...values,
        birthDate: `${values.birthYear}-${String(values.birthMonth).padStart(2, '0')}-${String(values.birthDay).padStart(2, '0')}`,
        birthTime: `${String(values.birthHour).padStart(2, '0')}:00`,
      }

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
          yun: lunarInfo?.yun
        },
        prediction: {
          directions: formData.direction,
          custom_directions: formData.customDirections || '',
        }
      }

      setQueryContent(queryContent)

      const response = await fetchPredict({
        ...formData,
        query: JSON.stringify(queryContent),
        response_mode: "streaming",
        user: formData.user || 'anonymous',
        conversation_id: formData.conversation_id
      })

      setResult({
        id: response.id || crypto.randomUUID(),
        userId: formData.user || 'anonymous',
        timestamp: Date.now(),
        inputs: {
          gender: formData.gender,
          birthDateTime: `${formData.birthDate} ${formData.birthTime}`,
          directions: formData.direction
        },
        result: response.content
      })
    } catch (err) {
      console.error('Prediction failed')
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

      {/* 添加免责声明提示 */}
      <div className="mb-6 p-4 bg-gray-50 rounded-lg text-sm text-gray-600">
        <p className="font-medium mb-2">免责声明：</p>
        <ul className="list-disc pl-4 space-y-1">
          <li>本服务仅供娱乐参考</li>
          <li>预测结果不构成任何建议或决策依据</li>
          <li>使用本服务即表示您同意免责声明</li>
        </ul>
      </div>

      <Form
        form={form}
        layout="vertical"
        onFinish={onFinish}
        initialValues={{
          calendarType: 'solar',
          birthHour: 12,
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
            <Radio.Button value="lunar" className="w-1/2 text-center">农历</Radio.Button>
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
                  {slot.label}
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