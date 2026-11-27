import { pasteboard } from '@kit.BasicServicesKit'
import { AppConfig } from '../common/AppConfig'
import { AppRouter, DetailParams } from '../common/AppRouter'
import { AppTheme, LightTheme } from '../theme/AppTheme'
import { AppHeader } from '../components/AppHeader'

/**
 * 通用「信息详情」二级页。
 *
 * 设置页里有些值一行放不下（应用全称、设备 ID），在那里用省略号收敛，
 * 点整行进这里看全文 —— 长 ID 这种没有空格可断的行用 breakAll 折行，
 * 并且可以直接长按选中或点「复制」。
 */
@Entry
@Component
struct DetailPage {
  @StorageProp('theme') theme: AppTheme = LightTheme

  @State label: string = '详细信息'
  @State value: string = ''

  aboutToAppear(): void {
    const params = this.getUIContext().getRouter().getParams() as DetailParams | undefined
    if (params === undefined) {
      return
    }
    if (params.label !== undefined && params.label.length > 0) {
      this.label = params.label
    }
    if (params.value !== undefined) {
      this.value = params.value
    }
  }

  build() {
    Column() {
      AppHeader({
        title: this.label,
        subtitle: '完整信息',
        showClose: true,
        onClose: () => AppRouter.back(this.getUIContext())
      })

      Scroll() {
        Row() {
          Column({ space: 16 }) {
            Column() {
              Text(this.value)
                .width('100%')
                .fontSize(16)
                .lineHeight(26)
                .fontColor(this.theme.textPrimary)
                // 设备 ID 这种超长无空格的串必须能任意位置折行，否则又会被截断
                .wordBreak(WordBreak.BREAK_ALL)
                .copyOption(CopyOptions.LocalDevice)
            }
            .width('100%')
            .padding(16)
            .backgroundColor(this.theme.surface)
            .borderRadius(12)

            Button('复制')
              .width('100%')
              .height(40)
              .fontSize(14)
              .fontColor(Color.White)
              .backgroundColor(this.theme.primary)
              .borderRadius(8)
              .onClick(() => this.copy())
          }
          .width('100%')
          .constraintSize({ maxWidth: AppConfig.CONTENT_MAX_WIDTH })
          .padding({ left: 16, right: 16, top: 16 })
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

  private copy(): void {
    try {
      const data = pasteboard.createData(pasteboard.MIMETYPE_TEXT_PLAIN, this.value)
      pasteboard.getSystemPasteboard().setData(data).then(() => {
        this.toast('已复制')
      }).catch(() => {
        this.toast('复制失败')
      })
    } catch (err) {
      this.toast('复制失败')
    }
  }

  private toast(message: string): void {
    this.getUIContext().getPromptAction().showToast({ message: message, duration: 1500 })
  }
}
