import { DeviceSnapshot } from '../model/DeviceShadow'
import { ShadowService } from '../service/ShadowService'
import { Logger } from '../common/Logger'

/** 一次加载的结果，避免用异常驱动 UI */
export interface LoadResult {
  ok: boolean
  snapshot?: DeviceSnapshot
  message: string
}

/**
 * 首页视图模型：只负责"要不要发请求、结果如何"，不碰 UI、不碰定时器。
 * 定时器归页面管（跟着页面生命周期走）。
 */
export class MonitorVM {
  private busy: boolean = false

  isBusy(): boolean {
    return this.busy
  }

  async load(): Promise<LoadResult> {
    if (this.busy) {
      return { ok: false, message: '正在同步中' }
    }
    this.busy = true
    try {
      const snapshot: DeviceSnapshot = await ShadowService.load()
      return { ok: true, snapshot: snapshot, message: '数据同步成功' }
    } catch (err) {
      const message: string = err instanceof Error ? err.message : '同步失败'
      Logger.error('MonitorVM', message)
      return { ok: false, message: message }
    } finally {
      this.busy = false
    }
  }
}
