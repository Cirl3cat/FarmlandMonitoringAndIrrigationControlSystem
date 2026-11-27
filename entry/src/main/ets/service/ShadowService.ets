import { AppConfig } from '../common/AppConfig'
import { Http } from '../common/Http'
import { Logger } from '../common/Logger'
import { DeviceShadow, DeviceSnapshot } from '../model/DeviceShadow'
import { IamAuthService } from './IamAuthService'

/** 设备影子读取：唯一负责"认证 + 取影子 + 解析"的地方 */
export class ShadowService {
  static async load(): Promise<DeviceSnapshot> {
    const token: string = await IamAuthService.ensure()
    let response = await Http.get(AppConfig.shadowUrl, token)

    // token 被服务端提前判失效时，强制重登一次再试（原实现会一直失败到下次刷新）
    if (response.responseCode === 401) {
      Logger.warn('ShadowService', 'token 失效，重新认证后重试一次')
      IamAuthService.invalidate()
      const freshToken: string = await IamAuthService.ensure(true)
      response = await Http.get(AppConfig.shadowUrl, freshToken)
    }

    Http.ensureOk(response, '获取设备数据')

    const snapshot: DeviceSnapshot | undefined = DeviceShadow.parse(response.result)
    if (snapshot === undefined) {
      throw new Error('设备数据格式异常')
    }
    return snapshot
  }
}
