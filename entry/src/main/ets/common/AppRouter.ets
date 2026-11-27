import { UIContext } from '@kit.ArkUI'
import { Logger } from './Logger'

/** 已实现的页面路由（唯一出处，避免字符串散落） */
export enum PageRoute {
  MONITOR = 'pages/MonitorPage',
  DISCOVER = 'pages/Discover',
  PROFILE = 'pages/Profile',
  SETTINGS = 'pages/Settings',
  CALENDAR = 'pages/CalendarPage',
  AI = 'pages/AI',
  NEWS = 'pages/ChinaAgri',
  /** 通用信息详情页（放不下全文的长文本进这里看） */
  DETAIL = 'pages/Detail'
}

/** 信息详情页的参数（router pushUrl 的 params） */
export interface DetailParams {
  label: string
  value: string
}

export class AppRouter {
  static push(ui: UIContext, route: PageRoute): void {
    ui.getRouter().pushUrl({ url: route }).catch((err: Error) => {
      Logger.error('Router', `跳转 ${route} 失败: ${err.message}`)
    })
  }

  /**
   * 打开信息详情页：设置页里「应用名」「设备 ID」这类放不下的长文本，
   * 点整行进来就能看全文，还能一键复制。
   */
  static openInfo(ui: UIContext, label: string, value: string): void {
    const params: DetailParams = { label: label, value: value }
    ui.getRouter().pushUrl({ url: PageRoute.DETAIL, params: params }).catch((err: Error) => {
      Logger.error('Router', `跳转 ${PageRoute.DETAIL} 失败: ${err.message}`)
    })
  }

  static back(ui: UIContext): void {
    ui.getRouter().back()
  }

  /**
   * 尚未实现的入口（产量估计 / 土壤肥力速算 / 农场管理等）。
   * 原实现是「静默失败」——点了没反应；这里给一次明确反馈。
   */
  static openPlanned(ui: UIContext, title: string): void {
    ui.getPromptAction().showToast({ message: `${title}功能建设中`, duration: 1800 })
  }
}
