import { webview } from '@kit.ArkWeb'
import { AppRouter } from '../common/AppRouter'
import { AppTheme, LightTheme } from '../theme/AppTheme'
import { AppHeader } from '../components/AppHeader'

@Entry
@Component
struct AI {
  private controller: webview.WebviewController = new webview.WebviewController()
  @StorageProp('theme') theme: AppTheme = LightTheme

  build() {
    Column() {
      AppHeader({
        title: '农事一句话',
        subtitle: 'AI 农事顾问',
        showClose: true,
        onClose: () => AppRouter.back(this.getUIContext())
      })

      Web({
        src: 'https://www.doubao.com/chat/?channel=itab2&source=hw_db_itab&type=tab&theme=wangzjh',
        controller: this.controller
      })
        .layoutWeight(1)
        .width('100%')
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.theme.bg)
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
  }
}
