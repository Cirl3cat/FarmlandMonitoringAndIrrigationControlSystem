import { AppTheme, LightTheme } from '../theme/AppTheme'

/**
 * 环境数据卡片（温度 / 湿度 / 光照）。
 * 原实现是三段几乎逐行复制的代码（每段约 30 行），现在一个组件 + 参数。
 */
@Component
export struct MetricCard {
  title: string = ''
  value: string = '--'
  unit: string = ''
  icon: Resource = $r('app.media.datapage_temperature_sun')
  /** 图标底的色相（6 位 hex），透明度在组件内统一叠 */
  tint: string = '#FFC738'
  @StorageProp('theme') theme: AppTheme = LightTheme

  build() {
    Column({ space: 8 }) {
      Stack() {
        Circle()
          .width(44)
          .height(44)
          .fill(this.tint + (this.theme.isDark ? '40' : '60'))
        Image(this.icon)
          .width(26)
          .height(26)
      }
      .width(44)
      .height(44)

      Row({ space: 2 }) {
        Text(this.value)
          .fontSize(24)
          .fontWeight(FontWeight.Bold)
          .fontColor(this.theme.textPrimary)
        Text(this.unit)
          .fontSize(11)
          .fontColor(this.theme.textTertiary)
          .margin({ top: 4 })
      }
      .alignItems(VerticalAlign.Center)

      Text(this.title)
        .fontSize(13)
        .fontColor(this.theme.textSecondary)
    }
    .width('100%')
    .height(120)
    .backgroundColor(this.theme.surface)
    .borderRadius(12)
    .justifyContent(FlexAlign.Center)
    .shadow({
      radius: 10,
      color: this.theme.isDark ? 'rgba(0,0,0,0.45)' : 'rgba(0,0,0,0.06)',
      offsetY: 3
    })
  }
}
