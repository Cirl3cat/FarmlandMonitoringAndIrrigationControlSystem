import { AppRouter, PageRoute } from '../common/AppRouter'
import { AppConfig } from '../common/AppConfig'
import { AppTheme, LightTheme } from '../theme/AppTheme'
import { AppHeader } from '../components/AppHeader'

interface MenuEntry {
  title: string
  subtitle: string
  route: PageRoute | undefined
}

const MENUS: MenuEntry[] = [
  { title: '通用设置', subtitle: '外观、主题与关于', route: PageRoute.SETTINGS },
  { title: '农场管理', subtitle: '管理您的所有地块', route: undefined },
  { title: '设备中心', subtitle: '查看物联网设备状态', route: undefined },
  { title: '农事档案', subtitle: '历史记录与报表', route: undefined },
  { title: '消息通知', subtitle: '', route: undefined },
  { title: '帮助与反馈', subtitle: '', route: undefined }
]

@Component
export struct ProfilePage {
  @StorageProp('theme') theme: AppTheme = LightTheme
  @StorageProp('insetBottom') insetBottom: number = 8

  build() {
    Column() {
      AppHeader({
        title: '我的',
        subtitle: '账号与设置'
      })

      Scroll() {
        Row() {
          Column({ space: 16 }) {
            this.profileCard()
            this.menuList()

            Column({ space: 4 }) {
              Text('FarmlandMonitoringAndIrrigationControlSystem')
                .fontSize(12)
                .fontColor(this.theme.textTertiary)
              Text(`v${AppConfig.VERSION}`)
                .fontSize(11)
                .fontColor(this.theme.textTertiary)
            }
            .margin({ top: 16, bottom: 16 })
            .alignItems(HorizontalAlign.Center)

            // 尾部空白内容：高度比导航栏略高一点，滚到底时胶囊盖在这块空白上
            Row()
              .width('100%')
              .height(AppConfig.bottomSpacer(this.insetBottom))
          }
          .width('100%')
          .constraintSize({ maxWidth: AppConfig.CONTENT_MAX_WIDTH })
          .padding({ top: 4, left: 16, right: 16 })
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
  }

  @Builder
  profileCard() {
    Row({ space: 16 }) {
      Stack({ alignContent: Alignment.Center }) {
        Column()
          .width(64)
          .height(64)
          .backgroundColor(this.theme.successSurface)
          .borderRadius(32)
        Text('智')
          .fontSize(24)
          .fontWeight(FontWeight.Bold)
          .fontColor(this.theme.success)
      }
      .width(64)
      .height(64)

      Column({ space: 4 }) {
        Text('智慧农场主')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .fontColor(this.theme.textPrimary)
        Text('ID: 8839201')
          .fontSize(13)
          .fontColor(this.theme.textSecondary)
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)

      Text('编辑')
        .fontSize(13)
        .fontColor(this.theme.textSecondary)
        .padding({ left: 12, right: 12, top: 6, bottom: 6 })
        .backgroundColor(this.theme.fill)
        .borderRadius(14)
        .onClick(() => AppRouter.openPlanned(this.getUIContext(), '编辑资料'))
    }
    .width('100%')
    .padding(20)
    .backgroundColor(this.theme.surface)
    .borderRadius(12)
  }

  @Builder
  menuList() {
    Column() {
      ForEach(MENUS, (menu: MenuEntry, index: number) => {
        Column() {
          Row({ space: 12 }) {
            Column({ space: 2 }) {
              Text(menu.title)
                .fontSize(15)
                .fontColor(this.theme.textPrimary)
              if (menu.subtitle.length > 0) {
                Text(menu.subtitle)
                  .fontSize(12)
                  .fontColor(this.theme.textTertiary)
              }
            }
            .layoutWeight(1)
            .alignItems(HorizontalAlign.Start)

            Text('›')
              .fontSize(20)
              .fontColor(this.theme.textTertiary)
          }
          .width('100%')
          .height(menu.subtitle.length > 0 ? 60 : 48)
          .padding({ left: 16, right: 16 })
          .alignItems(VerticalAlign.Center)
          .onClick(() => {
            if (menu.route !== undefined) {
              AppRouter.push(this.getUIContext(), menu.route)
            } else {
              AppRouter.openPlanned(this.getUIContext(), menu.title)
            }
          })

          if (index < MENUS.length - 1) {
            Divider()
              .color(this.theme.divider)
              .margin({ left: 16, right: 16 })
          }
        }
        .width('100%')
      })
    }
    .width('100%')
    .backgroundColor(this.theme.surface)
    .borderRadius(12)
    .clip(true)
  }
}
