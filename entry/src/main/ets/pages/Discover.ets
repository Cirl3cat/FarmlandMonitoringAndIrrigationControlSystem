import { AppRouter, PageRoute } from '../common/AppRouter'
import { AppConfig } from '../common/AppConfig'
import { AppTheme, LightTheme } from '../theme/AppTheme'
import { DiscoverCard } from '../components/DiscoverCard'
import { AppHeader } from '../components/AppHeader'

interface DiscoverEntry {
  title: string
  intro: string
  icon: Resource
  banner: Resource
  /** 已实现的页面才有 route；未实现的走 openPlanned 提示 */
  route: PageRoute | undefined
}

const BASE_ENTRIES: DiscoverEntry[] = [
  {
    title: '智能农业 AI 顾问',
    intro: '问农事 一句话，AI 秒解答！',
    icon: $r('app.media.ic_robot'),
    banner: $r('app.media.banner_ai'),
    route: PageRoute.AI
  },
  {
    title: '中国农业农村信息网',
    intro: '农事信息一键达',
    icon: $r('app.media.ic_news'),
    banner: $r('app.media.banner_news'),
    route: PageRoute.NEWS
  },
  {
    title: '农时日历',
    intro: '四季农情全掌握',
    icon: $r('app.media.ic_calendar'),
    banner: $r('app.media.banner_calendar'),
    route: PageRoute.CALENDAR
  },
  {
    title: '产量估计',
    intro: '快捷亩产预测',
    icon: $r('app.media.ic_trend'),
    banner: $r('app.media.banner_yield'),
    route: undefined
  },
  {
    title: '土壤肥力速算',
    intro: '农业增效，良田有谱',
    icon: $r('app.media.ic_calculator'),
    banner: $r('app.media.banner_fertilizer'),
    route: undefined
  }
]

const ENTRIES: DiscoverEntry[] = BASE_ENTRIES

@Component
export struct DiscoverPage {
  @StorageProp('theme') theme: AppTheme = LightTheme
  @StorageProp('insetBottom') insetBottom: number = 8

  build() {
    Column() {
      AppHeader({
        title: '发现',
        subtitle: '农事资讯与实用工具'
      })

      Row() {
        List({ space: 12 }) {
          ForEach(ENTRIES, (entry: DiscoverEntry) => {
            ListItem() {
              DiscoverCard({
                title: entry.title,
                intro: entry.intro,
                icon: entry.icon,
                banner: entry.banner,
                onTap: () => {
                  if (entry.route !== undefined) {
                    AppRouter.push(this.getUIContext(), entry.route)
                  } else {
                    AppRouter.openPlanned(this.getUIContext(), entry.title)
                  }
                }
              })
            }
          })

          // 尾部空白内容：高度比导航栏略高一点。滚到底时胶囊正好盖在这块空白上，
          // 最后一张卡片完整露在胶囊上方、点得到（中途滑动仍从胶囊底下穿过）
          ListItem() {
            Row()
              .width('100%')
              .height(AppConfig.bottomSpacer(this.insetBottom))
          }
        }
        .width('100%')
        .height('100%')
        .constraintSize({ maxWidth: AppConfig.CONTENT_MAX_WIDTH })
        .padding({ left: 16, right: 16 })
        .scrollBar(BarState.Off)
      }
      .width('100%')
      .layoutWeight(1)
      .justifyContent(FlexAlign.Center)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.theme.bg)
  }
}
