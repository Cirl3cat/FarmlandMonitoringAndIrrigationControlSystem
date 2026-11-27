import { AppTheme, LightTheme } from '../theme/AppTheme'

/**
 * 全站统一页眉。
 *
 * 原来首页是「白底 + 底部圆角 + 投影 + 品牌色标题 + 状态行」，
 * 其它页却是「灰底上一行小标题」，观感割裂 —— 现在所有页面共用这一种。
 *
 * 沉浸式布局下页面会绘制到状态栏下面，所以顶部内边距要加上 insetTop。
 */
@Component
export struct AppHeader {
  /**
   * 这几个必须是 @Prop：普通成员只在初始化时取值，父页面状态变了不会同步过来
   * （v0.5.6 修的就是这个 —— 首页状态行一直停在「正在同步...」）。
   */
  @Prop title: string = ''
  /** 普通副标题（与状态行二选一） */
  @Prop subtitle: string = ''
  /** 带色点的状态行，如"数据同步成功" */
  @Prop statusText: string = ''
  @Prop statusColor: string = ''
  /** 状态行右侧的次要信息，如"14:28 更新" */
  @Prop metaText: string = ''
  /** 右上角关闭（二级页面用） */
  @Prop showClose: boolean = false
  onClose: () => void = () => {}

  @StorageProp('theme') theme: AppTheme = LightTheme
  @StorageProp('insetTop') insetTop: number = 0

  build() {
    Column({ space: 4 }) {
      Row() {
        Text(this.title)
          .fontSize(24)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.theme.brand)
        Blank()
        if (this.showClose) {
          Text('关闭')
            .fontSize(13)
            .fontColor(this.theme.textSecondary)
            .padding({ left: 14, right: 14, top: 7, bottom: 7 })
            .backgroundColor(this.theme.fill)
            .borderRadius(16)
            .onClick(() => this.onClose())
        }
      }
      .width('100%')

      if (this.statusText.length > 0) {
        Row({ space: 6 }) {
          Circle()
            .width(7)
            .height(7)
            .fill(this.statusColor)
          Text(this.statusText)
            .fontSize(12)
            .fontColor(this.statusColor)
          if (this.metaText.length > 0) {
            Text(this.metaText)
              .fontSize(11)
              .fontColor(this.theme.textTertiary)
          }
        }
        .width('100%')
      } else if (this.subtitle.length > 0) {
        Text(this.subtitle)
          .fontSize(12)
          .fontColor(this.theme.textTertiary)
          .width('100%')
      }
    }
    .width('100%')
    .height(72 + this.insetTop)
    .padding({ left: 20, right: 20, top: 12 + this.insetTop })
    .alignItems(HorizontalAlign.Start)
    .backgroundColor(this.theme.surface)
    .borderRadius({ bottomLeft: 16, bottomRight: 16 })
    .shadow({
      radius: 8,
      color: this.theme.isDark ? 'rgba(0,0,0,0.45)' : 'rgba(0,0,0,0.05)',
      offsetY: 2
    })
  }
}
