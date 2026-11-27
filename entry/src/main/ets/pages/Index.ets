import { tint } from '../common/Tint'
import { AppTheme, LightTheme } from '../theme/AppTheme'
import { acrylicOptions, acrylicStyle } from '../theme/Acrylic'
import { MonitorPage } from './MonitorPage'
import { DiscoverPage } from './Discover'
import { ProfilePage } from './Profile'

interface TabItem {
  title: string
  icon: Resource
}

const TABS: TabItem[] = [
  { title: '首页', icon: $r('app.media.ic_home') },
  { title: '发现', icon: $r('app.media.ic_world') },
  { title: '我的', icon: $r('app.media.ic_user') }
]

/**
 * 首页容器：内容铺满全屏（含状态栏与手势条区域），亚克力胶囊浮在内容之上。
 *
 * 沉浸式的三件套：
 * 1. EntryAbility 里 setWindowLayoutFullScreen(true) + 系统条透明；
 * 2. 根节点 expandSafeArea 让页面真的画到状态栏/手势条底下；
 * 3. 不留页尾 —— 列表内容要能从胶囊和手势条底下穿过去。滚到底时由各页面
 *    自己在内容末尾垫一块空白（AppConfig.bottomSpacer），让胶囊盖在空白上。
 */
@Entry
@Component
struct Index {
  @State selectedIndex: number = 0
  @StorageProp('theme') theme: AppTheme = LightTheme
  @StorageProp('insetBottom') insetBottom: number = 8

  build() {
    Stack({ alignContent: Alignment.Bottom }) {
      Column() {
        if (this.selectedIndex === 0) {
          MonitorPage()
        } else if (this.selectedIndex === 1) {
          DiscoverPage()
        } else {
          ProfilePage()
        }
      }
      .width('100%')
      .height('100%')

      Row() {
        ForEach(TABS, (tab: TabItem, index: number) => {
          Column() {
            Column({ space: 3 }) {
              Image(tab.icon)
                .width(22)
                .height(22)
                .colorFilter(tint(this.selectedIndex === index
                  ? this.theme.navIconSelected
                  : this.theme.navIcon))
              Text(tab.title)
                .fontSize(11)
                .fontWeight(this.selectedIndex === index ? FontWeight.Medium : FontWeight.Normal)
                .fontColor(this.selectedIndex === index
                  ? this.theme.navIconSelected
                  : this.theme.navIcon)
            }
            .width(72)
            .height(48)
            .justifyContent(FlexAlign.Center)
            .backgroundColor(this.selectedIndex === index ? this.theme.navSelectedBg : Color.Transparent)
            .borderRadius(24)
          }
          .layoutWeight(1)
          .alignItems(HorizontalAlign.Center)
          .onClick(() => {
            this.selectedIndex = index
          })
        })
      }
      .width('72%')
      .constraintSize({ maxWidth: 340 })
      .height(60)
      .padding({ left: 6, right: 6 })
      .backgroundColor(this.theme.glassTint)
      .backgroundBlurStyle(acrylicStyle(), acrylicOptions())
      .borderRadius(30)
      // clip 让玻璃严格止于胶囊自身的圆角，不会在四周糊出一块矩形
      .clip(true)
      .border({ width: 1, color: this.theme.glassBorder })
      // 阴影收得很小：半径大了会在胶囊周围糊出一片柔光，看起来像"被一块区域盖住"
      .shadow({
        radius: 10,
        color: this.theme.isDark ? 'rgba(0,0,0,0.40)' : 'rgba(24,39,58,0.10)',
        offsetY: 3
      })
      // 贴着系统手势条上方悬浮（insetBottom 是手势区高度），留 4vp 呼吸即可
      .margin({ bottom: Math.max(this.insetBottom - 4, 8) })
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.theme.bg)
    // 让页面画到状态栏和手势条底下，手势条周围因此显示的是内容，而不是一条底色
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
  }
}
