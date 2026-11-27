import { webview } from '@kit.ArkWeb'
import { AppRouter } from '../common/AppRouter'
import { AppTheme, LightTheme } from '../theme/AppTheme'
import { AppHeader } from '../components/AppHeader'

@Entry
@Component
struct ChinaAgri {
  private controller: webview.WebviewController = new webview.WebviewController()
  @StorageProp('theme') theme: AppTheme = LightTheme

  build() {
    Column() {
      AppHeader({
        title: '农事资讯全掌握',
        subtitle: '中国农业农村信息网',
        showClose: true,
        onClose: () => AppRouter.back(this.getUIContext())
      })

      Web({ src: 'https://www.agri.cn/?from=www.13dh.com', controller: this.controller })
        .layoutWeight(1)
        .width('100%')
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.theme.bg)
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
  }
}
