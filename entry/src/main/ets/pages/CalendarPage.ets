import { common } from '@kit.AbilityKit'
import { preferences } from '@kit.ArkData'
import { AppRouter } from '../common/AppRouter'
import { AppTheme, LightTheme } from '../theme/AppTheme'
import { Lunar, LunarUtil } from '../utils/Lunar'
import { AppHeader } from '../components/AppHeader'

interface Memo {
  key: string
  text: string
  timestamp: number
}

interface CalendarDay {
  date: Date
  solar: number
  lunar: string
  isCurMonth: boolean
  hasMemo: boolean
}

const WEEK_LABELS: string[] = ['日', '一', '二', '三', '四', '五', '六']

const FARM_TIPS: string[] = [
  '正月：选种育苗', '二月：翻土施肥', '三月：播种插秧',
  '四月：田间管理', '五月：防虫除草', '六月：蓄水保墒',
  '七月：追肥灌溉', '八月：防涝防旱', '九月：收获贮藏',
  '十月：秋耕备种', '冬月：农机保养', '腊月：总结规划'
]

@Entry
@Component
struct CalendarPage {
  @StorageProp('theme') theme: AppTheme = LightTheme
  @StorageProp('insetBottom') insetBottom: number = 8

  @State monthAnchor: Date = CalendarPage.firstOfMonth(new Date())
  @State selectedDate: Date = new Date()
  @State lunar: Lunar = LunarUtil.solarToLunar(new Date())
  @State memoText: string = ''
  @State memos: Memo[] = []

  private prefs: preferences.Preferences | undefined = undefined
  private swiper: SwiperController = new SwiperController()

  aboutToAppear(): void {
    this.loadMemos()
    this.memoText = this.memoFor(this.keyOf(this.selectedDate))
  }

  build() {
    Column({ space: 0 }) {
      AppHeader({
        title: '农时一页',
        subtitle: '农历 · 节气 · 备忘录',
        showClose: true,
        onClose: () => AppRouter.back(this.getUIContext())
      })

      Row() {
        ForEach(WEEK_LABELS, (label: string) => {
          Text(label)
            .layoutWeight(1)
            .textAlign(TextAlign.Center)
            .fontSize(12)
            .fontColor(this.theme.textTertiary)
        })
      }
      .width('100%')
      .padding({ top: 8, bottom: 8 })

      Swiper(this.swiper) {
        ForEach([-1, 0, 1], (offset: number) => {
          Row() {
            Grid() {
              ForEach(this.buildMonthDays(offset), (item: CalendarDay) => {
                GridItem() {
                  this.dayCell(item)
                }
              })
            }
            .columnsTemplate('1fr 1fr 1fr 1fr 1fr 1fr 1fr')
            .rowsGap(4)
            .columnsGap(4)
            // 大屏上格子会按宽度等比放大，6 行就放不下了：限制栅格最大宽度，保持手机上的密度
            .width('100%')
            .constraintSize({ maxWidth: 420 })
          }
          .width('100%')
          .justifyContent(FlexAlign.Center)
          .alignItems(VerticalAlign.Top)
        })
      }
      .layoutWeight(1)
      .loop(false)
      .cachedCount(1)
      .indicator(false)
      .onChange((index: number) => {
        if (index === 1) {
          return
        }
        const shifted = new Date(this.monthAnchor)
        shifted.setMonth(shifted.getMonth() + (index - 1))
        this.monthAnchor = CalendarPage.firstOfMonth(shifted)
        // 切完月立刻回到中间页，否则再滑一次就会连跳两个月（原实现的隐藏 bug）
        this.swiper.changeIndex(1, false)
      })

      Divider().color(this.theme.divider)

      Scroll() {
        Column({ space: 12 }) {
          Column({ space: 4 }) {
            Text(`农历 ${this.lunar.monthName}月${this.lunar.dayName}`)
              .fontSize(16)
              .fontWeight(FontWeight.Bold)
              .fontColor(this.theme.textPrimary)
            Text(`节气：${this.lunar.term}`)
              .fontSize(14)
              .fontColor(this.theme.textSecondary)
            Text(`农事：${FARM_TIPS[this.monthAnchor.getMonth()] ?? '农闲时节'}`)
              .fontSize(14)
              .fontColor(this.theme.textSecondary)
          }
          .width('100%')
          .alignItems(HorizontalAlign.Start)
          .padding({ top: 12 })

          Text('备忘录')
            .fontSize(16)
            .fontWeight(FontWeight.Bold)
            .fontColor(this.theme.textPrimary)
            .width('100%')

          TextArea({ text: this.memoText, placeholder: '记录今日农事 / 提醒…' })
            .height(96)
            .fontSize(14)
            .fontColor(this.theme.textPrimary)
            .backgroundColor(this.theme.surfaceAlt)
            .placeholderColor(this.theme.textTertiary)
            .onChange((value: string) => {
              this.memoText = value
            })

          Button('保存')
            .width('50%')
            .height(38)
            .fontSize(14)
            .backgroundColor(this.theme.primary)
            .onClick(() => {
              this.saveMemo()
            })
        }
        .width('100%')
        .padding({ left: 20, right: 20 })
      }
      .width('100%')
      .height(260)
      .scrollBar(BarState.Off)
      .align(Alignment.Top)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.theme.bg)
    // 沉浸式布局下页面铺到屏幕底边，保存按钮会压在手势条上，这里让出安全区
    .padding({ bottom: this.insetBottom + 10 })
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
  }

  @Builder
  dayCell(item: CalendarDay) {
    Column({ space: 2 }) {
      Text(`${item.solar}`)
        .fontSize(17)
        .fontColor(item.isCurMonth ? this.theme.textPrimary : this.theme.textTertiary)
      Text(item.lunar)
        .fontSize(10)
        .fontColor(item.isCurMonth ? this.theme.textSecondary : this.theme.textTertiary)
      if (item.hasMemo) {
        Circle()
          .width(5)
          .height(5)
          .fill(this.theme.danger)
      }
    }
    .width('100%')
    .height(52)
    .justifyContent(FlexAlign.Center)
    .backgroundColor(this.isSameDay(item.date, this.selectedDate) ? this.theme.brand : Color.Transparent)
    .borderRadius(8)
    .onClick(() => {
      this.selectedDate = item.date
      this.lunar = LunarUtil.solarToLunar(item.date)
      this.memoText = this.memoFor(this.keyOf(item.date))
    })
  }

  /* ==================== 业务 ==================== */

  private static firstOfMonth(date: Date): Date {
    return new Date(date.getFullYear(), date.getMonth(), 1)
  }

  private buildMonthDays(offset: number): CalendarDay[] {
    const shown = new Date(this.monthAnchor)
    shown.setMonth(shown.getMonth() + offset)
    const year: number = shown.getFullYear()
    const month: number = shown.getMonth()
    const leading: number = new Date(year, month, 1).getDay()
    const total: number = new Date(year, month + 1, 0).getDate()

    const days: CalendarDay[] = []
    for (let i = 0; i < leading; i++) {
      days.push(this.toCalendarDay(new Date(year, month, -leading + i + 1), false))
    }
    for (let i = 1; i <= total; i++) {
      days.push(this.toCalendarDay(new Date(year, month, i), true))
    }
    const trailing: number = 42 - days.length
    for (let i = 1; i <= trailing; i++) {
      days.push(this.toCalendarDay(new Date(year, month + 1, i), false))
    }
    return days
  }

  private toCalendarDay(date: Date, isCurMonth: boolean): CalendarDay {
    return {
      date: date,
      solar: date.getDate(),
      lunar: LunarUtil.solarToLunar(date).dayName,
      isCurMonth: isCurMonth,
      hasMemo: this.memoFor(this.keyOf(date)).length > 0
    }
  }

  private keyOf(date: Date): string {
    const month: string = (date.getMonth() + 1).toString().padStart(2, '0')
    const day: string = date.getDate().toString().padStart(2, '0')
    return `${date.getFullYear()}-${month}-${day}`
  }

  private memoFor(key: string): string {
    const found = this.memos.find((memo: Memo) => memo.key === key)
    return found === undefined ? '' : found.text
  }

  private isSameDay(left: Date, right: Date): boolean {
    return left.getFullYear() === right.getFullYear() &&
      left.getMonth() === right.getMonth() &&
      left.getDate() === right.getDate()
  }

  private loadMemos(): void {
    try {
      const context = this.getUIContext().getHostContext() as common.Context
      this.prefs = preferences.getPreferencesSync(context, { name: 'calendar_memo' })
      const stored = this.prefs.getSync('list', '[]')
      if (typeof stored === 'string') {
        this.memos = JSON.parse(stored) as Memo[]
      }
    } catch (err) {
      this.memos = []
    }
  }

  private async saveMemo(): Promise<void> {
    const key: string = this.keyOf(this.selectedDate)
    const index: number = this.memos.findIndex((memo: Memo) => memo.key === key)
    const text: string = this.memoText.trim()

    if (text.length > 0) {
      const memo: Memo = { key: key, text: text, timestamp: Date.now() }
      if (index >= 0) {
        this.memos[index] = memo
      } else {
        this.memos.push(memo)
      }
    } else if (index >= 0) {
      this.memos.splice(index, 1)
    }

    // 触发刷新（数组原地改动不会引起重绘）
    this.memos = this.memos.slice()

    try {
      if (this.prefs !== undefined) {
        this.prefs.putSync('list', JSON.stringify(this.memos))
        await this.prefs.flush()
      }
      this.getUIContext().getPromptAction().showToast({ message: '已保存', duration: 1500 })
    } catch (err) {
      this.getUIContext().getPromptAction().showToast({ message: '保存失败', duration: 1500 })
    }
  }
}
