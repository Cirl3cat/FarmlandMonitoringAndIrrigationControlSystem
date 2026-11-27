import { AppConfig } from '../common/AppConfig'
import { ApiError, Http } from '../common/Http'
import { Logger } from '../common/Logger'

interface IamTokenInfo {
  expires_at?: string
}

interface IamTokenBody {
  token?: IamTokenInfo
}

/** IAM 认证：token 复用 + 过期自动续期 */
export class IamAuthService {
  /** 提前 5 分钟视为过期，避免边界失效 */
  private static readonly SKEW_MS: number = 5 * 60 * 1000
  private static readonly FALLBACK_TTL_MS: number = 60 * 60 * 1000

  private static token: string = ''
  private static expiresAt: number = 0

  /**
   * 取可用 token。原实现每次刷新都重新登录 IAM（30 秒一次），
   * 这里改成缓存到真正的过期时间。
   */
  static async ensure(forceRefresh: boolean = false): Promise<string> {
    if (!forceRefresh && IamAuthService.token.length > 0 && Date.now() < IamAuthService.expiresAt) {
      return IamAuthService.token
    }
    return IamAuthService.login()
  }

  static invalidate(): void {
    IamAuthService.token = ''
    IamAuthService.expiresAt = 0
  }

  private static async login(): Promise<string> {
    const response = await Http.post(AppConfig.IAM_ENDPOINT, AppConfig.iamPayload(), '')
    if (response.responseCode !== 201 && response.responseCode !== 200) {
      throw new ApiError(response.responseCode, `认证失败（${response.responseCode}）`)
    }

    const token: string | undefined = response.header['x-subject-token'] as string
    if (token === undefined || token.length === 0) {
      throw new ApiError(response.responseCode, '认证响应中缺少 token')
    }

    IamAuthService.token = token
    IamAuthService.expiresAt = IamAuthService.resolveExpiry(response.result)
    AppStorage.setOrCreate('hw_token', token)
    Logger.info('IamAuthService', `登录成功，有效期至 ${new Date(IamAuthService.expiresAt).toISOString()}`)
    return token
  }

  /** 从响应体 token.expires_at 解析过期时间；解析不出来就按 1 小时兜底 */
  private static resolveExpiry(raw: Object | string | ArrayBuffer | undefined): number {
    const now: number = Date.now()
    try {
      const body: IamTokenBody = JSON.parse(JSON.stringify(raw)) as IamTokenBody
      const expiresAt: string | undefined = body.token?.expires_at
      if (expiresAt !== undefined) {
        const parsed: number = new Date(expiresAt).getTime()
        if (!Number.isNaN(parsed)) {
          return parsed - IamAuthService.SKEW_MS
        }
      }
    } catch (err) {
      Logger.warn('IamAuthService', `解析 token 有效期失败: ${JSON.stringify(err)}`)
    }
    return now + IamAuthService.FALLBACK_TTL_MS
  }
}
