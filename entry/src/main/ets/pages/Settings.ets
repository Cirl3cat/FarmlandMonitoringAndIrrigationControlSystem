import { common } from '@kit.AbilityKit'
import { display } from '@kit.ArkUI'
import { AppRouter } from '../common/AppRouter'
import { AppConfig } from '../common/AppConfig'
import { AppTheme, LightTheme } from '../theme/AppTheme'
import { ThemeManager, ThemeMode } from '../theme/ThemeManager'
import { AppHeader } from '../components/AppHeader'

interface ModeOption {
  mode: ThemeMode
  label: string
  hint: string
}

const MODE_OPTIONS: ModeOption[] = [
  { mode: ThemeMode.LIGHT, label: '浅色', hint: '始终浅色' },
  { mode: ThemeMode.DARK, label: '深色', hint: '始终深色' },
  { mode: ThemeMode.SYSTEM, label: '跟随系统', hint: '随系统切换' }
]

@Entry
@Component
struct SettingsPage {
  @StorageProp('theme') theme: AppTheme = LightTheme
  @State currentMode: ThemeMode = ThemeMode.SYSTEM

  aboutToAppear(): void {
    this.currentMode = ThemeManager.currentMode()
  }

  build() {
    Column() {
      AppHeader({
        title: '设置',
        subtitle: '外观与关于',
        showClose: true,
        onClose: () => AppRouter.back(this.getUIContext())
      })

      Scroll() {
        Row() {
          Column({ space: 12 }) {
          this.sectionTitle('主题外观')

          Column({ space: 10 }) {
            Row({ space: 8 }) {
              ForEach(MODE_OPTIONS, (option: ModeOption) => {
                this.modeChip(option)
              })
            }
            .width('100%')
          }
          .width('100%')
          .padding(14)
          .backgroundColor(this.theme.surface)
          .borderRadius(12)

          this.sectionTitle('数据源')
          Column({ space: 0 }) {
            this.infoRow('云平台', '华为云 IoTDA')
            Divider().color(this.theme.divider).strokeWidth(1)
            this.infoRow('设备', AppConfig.DEVICE_ID)
            Divider().color(this.theme.divider).strokeWidth(1)
            this.infoRow('刷新间隔', `${AppConfig.POLL_INTERVAL_MS / 1000} 秒`)
          }
          .width('100%')
          .padding({ left: 14, right: 14 })
          .backgroundColor(this.theme.surface)
          .borderRadius(12)

          this.sectionTitle('关于')
          Column({ space: 0 }) {
            this.infoRow('应用', '智能农田监测施肥灌溉一体化系统')
            Divider().color(this.theme.divider).strokeWidth(1)
            this.infoRow('版本', `v${AppConfig.VERSION}`)
          }
          .width('100%')
          .padding({ left: 14, right: 14 })
          .backgroundColor(this.theme.surface)
          .borderRadius(12)
          }
          .width('100%')
          .constraintSize({ maxWidth: AppConfig.CONTENT_MAX_WIDTH })
          .padding({ left: 16, right: 16, top: 12, bottom: 40 })
        }
        .width('100%')
        .justifyContent(FlexAlign.Center)
        .alignItems(VerticalAlign.Top)
      }
      .width('100%')
      .layoutWeight(1)
      .scrollBar(BarState.Off)
      .align(Alignment.Top)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.theme.bg)
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
  }

  @Builder
  sectionTitle(text: string) {
    Text(text)
      .fontSize(13)
      .fontColor(this.theme.textTertiary)
      .width('100%')
      .padding({ left: 4, top: 4 })
  }

  @Builder
  modeChip(option: ModeOption) {
    Column({ space: 2 }) {
      Text(option.label)
        .fontSize(14)
        .fontWeight(this.currentMode === option.mode ? FontWeight.Medium : FontWeight.Normal)
        .fontColor(this.currentMode === option.mode ? Color.White : this.theme.textPrimary)
      Text(option.hint)
        .fontSize(10)
        .fontColor(this.currentMode === option.mode
          ? $r('app.color.text_on_primary_secondary')
          : this.theme.textTertiary)
    }
    .layoutWeight(1)
    .height(52)
    .justifyContent(FlexAlign.Center)
    .backgroundColor(this.currentMode === option.mode ? this.theme.primary : this.theme.surfaceAlt)
    .borderRadius(10)
    .onClick(() => this.select(option.mode))
  }

  @Builder
  infoRow(label: string, value: string) {
    Row() {
      Text(label)
        .fontSize(14)
        .fontColor(this.theme.textPrimary)
      Blank()
      // 一行放不下就收省略号，并给一个箭头提示"点整行看全文"（判断逻辑见 isOverflow）
      Text(value)
        .fontSize(13)
        .fontColor(this.theme.textTertiary)
        .maxLines(1)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
        .constraintSize({ maxWidth: this.isOverflow(value) ? '54%' : '62%' })
      if (this.isOverflow(value)) {
        Text('›')
          .fontSize(16)
          .fontColor(this.theme.textTertiary)
          .margin({ left: 4 })
      }
    }
    .width('100%')
    .height(44)
    .alignItems(VerticalAlign.Center)
    .onClick(() => {
      // 只有真的被截断的行才值得进二级页；短信息点了不做事
      if (this.isOverflow(value)) {
        AppRouter.openInfo(this.getUIContext(), label, value)
      }
    })
  }

  /** 值文本实际可用的宽度（vp）= 卡片内宽 × 62%，与 Text 的 maxWidth 保持一致 */
  private valueWidthVp(): number {
    const screenWidth: number = display.getDefaultDisplaySync().width
    const density: number = display.getDefaultDisplaySync().densityPixels
    const screenVp: number = screenWidth / density
    // 页面左右各 16vp、卡片内左右各 14vp
    const innerVp: number = Math.min(screenVp, AppConfig.CONTENT_MAX_WIDTH) - 32 - 28
    return innerVp * 0.62
  }

  /** 这个值会不会被省略号截断（长度按系统实测字宽算，不靠字数猜） */
  private isOverflow(value: string): boolean {
    try {
      const density: number = display.getDefaultDisplaySync().densityPixels
      // measureText 返回 px，换算成 vp 再和可用宽度比
      const widthPx: number = this.getUIContext().getMeasureUtils().measureText({
        textContent: value,
        fontSize: 13
      })
      return widthPx / density > this.valueWidthVp() - 2
    } catch (err) {
      return value.length > 18
    }
  }

  private select(mode: ThemeMode): void {
    const context = this.getUIContext().getHostContext() as common.UIAbilityContext
    ThemeManager.setMode(context, mode)
    this.currentMode = mode
  }
}
