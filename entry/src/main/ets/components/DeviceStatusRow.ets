import { tint } from '../common/Tint'
import { AppTheme, LightTheme } from '../theme/AppTheme'

/**
 * 设备状态行（电机 / 灯光 / 自动模式）。
 * 图标是描边矢量图，颜色用 ColorFilter 染色 —— 深色模式下自动变成浅色，不会再"糊"在背景里。
 */
@Component
export struct DeviceStatusRow {
  label: string = ''
  icon: Resource = $r('app.media.ic_bolt')
  on: boolean = false
  showDivider: boolean = true
  @StorageProp('theme') theme: AppTheme = LightTheme

  build() {
    Column() {
      Row() {
        Row({ space: 8 }) {
          Image(this.icon)
            .width(18)
            .height(18)
            .colorFilter(tint(this.theme.icon))
          Text(this.label)
            .fontSize(14)
            .fontColor(this.theme.textSecondary)
        }

        Blank()

        Row({ space: 5 }) {
          Circle()
            .width(6)
            .height(6)
            .fill(this.on ? this.theme.success : this.theme.textTertiary)
          Text(this.on ? '运行中' : '已停止')
            .fontSize(13)
            .fontWeight(FontWeight.Medium)
            .fontColor(this.on ? this.theme.success : this.theme.textSecondary)
        }
        .padding({ left: 8, right: 8, top: 3, bottom: 3 })
        .backgroundColor(this.on ? this.theme.successSurface : this.theme.fill)
        .borderRadius(4)
      }
      .width('100%')
      .height(40)

      if (this.showDivider) {
        Divider()
          .color(this.theme.divider)
          .strokeWidth(1)
      }
    }
    .width('100%')
  }
}
