import { PredictionResult } from '../types/prediction'

export function formatPredictionToMarkdown(prediction: PredictionResult | null): string {
  if (!prediction) return ''

  let content = prediction.result
  try {
    const jsonContent = JSON.parse(content)
    content = jsonContent.answer || jsonContent.content || jsonContent.text || content
  } catch {
    // 如果解析失败，使用原始内容
  }

  // 移除 Thinking... 部分
  content = content.replace(/<details.*?<\/details>/s, '').trim()

  // 处理特殊字符和格式
  const processContent = (text: string) => {
    return text
      // 处理标题
      .replace(/^【(.+?)】/gm, '## $1')
      // 处理列表
      .replace(/^[•·]\s*/gm, '- ')
      .replace(/^(-|\d+\.)\s*/gm, '$1 ')
      // 处理分隔线
      .replace(/[-─]{3,}/g, '---')
      // 处理空行
      .replace(/\n{3,}/g, '\n\n')
  }

  // 处理表格格式
  const formatTables = (text: string) => {
    // 处理 ASCII 风格的表格
    text = text.replace(/[┌┐└┘]/g, '+')
      .replace(/─/g, '-')
      .replace(/│/g, '|')

    // 处理表格块
    return text.replace(/(?:[+|][-+]*[+|]\n)?(?:\|[^\n]+\|\n?)+(?:[+|][-+]*[+|])?/g, (table) => {
      // 移除表格边框
      const rows = table
        .split('\n')
        .filter(row => row.trim() && !row.match(/^[+|][-+]*[+|]$/))
        .map(row => {
          // 处理每一行
          return row
            .replace(/^\||\|$/g, '')  // 移除行首尾的竖线
            .split('|')
            .map(cell => cell.trim())
            .join(' | ')
        })

      // 如果表格有内容
      if (rows.length > 0) {
        // 添加表格标记
        const processedRows = rows.map(row => `| ${row} |`)

        // 如果有多行且没有分隔行，添加分隔行
        if (rows.length > 1 && !processedRows[1].includes('---')) {
          const columnCount = (processedRows[0].match(/\|/g) || []).length - 1
          processedRows.splice(1, 0, `|${' --- |'.repeat(columnCount)}`)
        }

        return processedRows.join('\n') + '\n\n'
      }
      return table
    })
  }

  // 应用格式化
  let formatted = processContent(content)
  formatted = formatTables(formatted)

  // 最终清理
  return formatted
    .split('\n')
    .map(line => line.trim())
    .filter(line => line.length > 0)
    .join('\n')
    .trim()
} 