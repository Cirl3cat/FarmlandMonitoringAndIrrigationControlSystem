import { Secrets } from './Secrets'

/**
 * 环境配置。
 *
 * 这里只放**不敏感**的东西：版本号、IAM 公共端点、轮询间隔、内容限宽、服务 ID。
 * 账号口令、IoTDA 实例域名、项目 ID、设备 ID 全在 `Secrets.ets`（已 gitignore），
 * 下面三个 getter 只是把它们透出来 —— 业务代码仍然只认 AppConfig，不直接碰 Secrets。
 */
export class AppConfig {
  /** 语义化版本号 —— 唯一出处；改版本时同步 app.json5 的 versionName / versionCode */
  static readonly VERSION: string = '0.5.6'

  /** IAM 认证地址（华为云统一身份认证的公共端点，所有账号共用，非敏感） */
  static readonly IAM_ENDPOINT: string = 'https://iam.myhuaweicloud.com/v3/auth/tokens'

  /** 设备接入实例域名（每个账号实例各不相同 → 放在 Secrets.ets） */
  static get IOT_ENDPOINT(): string {
    return Secrets.IOT_ENDPOINT
  }

  /** 项目 ID（见 Secrets.ets） */
  static get PROJECT_ID(): string {
    return Secrets.PROJECT_ID
  }

  /** 设备 ID，格式 `<产品ID>_<设备节点名>`（见 Secrets.ets） */
  static get DEVICE_ID(): string {
    return Secrets.DEVICE_ID
  }

  /** 产品服务 ID（与南向上报的 service_id 必须一致；属于协议契约，非敏感） */
  static readonly SERVICE_ID: string = 'smartHome'

  /** 影子查询地址 */
  static get shadowUrl(): string {
    return `${AppConfig.IOT_ENDPOINT}/v5/iot/${AppConfig.PROJECT_ID}/devices/${AppConfig.DEVICE_ID}/shadow`
  }

  /** 自动刷新间隔（毫秒） */
  static readonly POLL_INTERVAL_MS: number = 30000

  /**
   * 内容区最大宽度（vp）。
   * 三折叠展开约 1108vp 宽，若内容铺满，卡片会被拉成 10:1、背景图只剩一条缝。
   * 700vp 让卡片宽高比落在 3:1（手机）~6.4:1（大屏）这个设计区间内。
   */
  static readonly CONTENT_MAX_WIDTH: number = 700

  /** 悬浮导航胶囊的高度（vp），与 Index 里的导航胶囊保持一致 */
  static readonly NAV_BAR_HEIGHT: number = 60

  /**
   * 导航栏总共压掉的高度（vp）= 胶囊离屏幕底边的距离 + 胶囊高度。
   * Index 里胶囊的底边距是 max(insetBottom - 4, 8)，这里必须用同一个公式。
   */
  static navBarTotalHeight(insetBottom: number): number {
    return Math.max(insetBottom - 4, 8) + AppConfig.NAV_BAR_HEIGHT
  }

  /**
   * 滚动内容尾部那块「空白内容」的高度（vp）——比导航栏总高度再高一点点。
   *
   * 内容仍然一直铺到屏幕最下沿、从胶囊底下穿过（中途滑动的观感不变）；
   * 只是在每个可滚动页面的最末尾垫一块这么高的空白。滚到底时导航栏正好
   * 盖在这块空白上，最后一项真实内容完整露在胶囊上方，点得到也看得清。
   */
  static bottomSpacer(insetBottom: number): number {
    return AppConfig.navBarTotalHeight(insetBottom) + 8
  }

  /** HTTP 连接超时 */
  static readonly CONNECT_TIMEOUT_MS: number = 10000

  /** HTTP 读取超时 */
  static readonly READ_TIMEOUT_MS: number = 15000

  /** IAM 认证请求体（由 Secrets 组装，避免在业务层重复拼结构） */
  static iamPayload(): IamPayload {
    const domain: DomainName = { name: Secrets.IAM_DOMAIN }
    const user: IamUser = { domain: domain, name: Secrets.IAM_USER, password: Secrets.IAM_PASSWORD }
    const password: IamPassword = { user: user }
    const identity: IamIdentity = { methods: ['password'], password: password }
    const scope: IamScope = { domain: domain }
    const auth: IamAuth = { identity: identity, scope: scope }
    const payload: IamPayload = { auth: auth }
    return payload
  }
}

export interface DomainName {
  name: string
}

export interface IamUser {
  domain: DomainName
  name: string
  password: string
}

export interface IamPassword {
  user: IamUser
}

export interface IamIdentity {
  methods: string[]
  password: IamPassword
}

export interface IamScope {
  domain: DomainName
}

export interface IamAuth {
  identity: IamIdentity
  scope: IamScope
}

export interface IamPayload {
  auth: IamAuth
}
