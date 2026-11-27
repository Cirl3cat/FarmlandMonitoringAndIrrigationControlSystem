import { http } from '@kit.NetworkKit'
import { AppConfig } from './AppConfig'
import { Logger } from './Logger'

/** 统一错误：业务层只需要 message + httpStatus */
export class ApiError extends Error {
  readonly httpStatus: number

  constructor(httpStatus: number, message: string) {
    super(message)
    this.name = 'ApiError'
    this.httpStatus = httpStatus
  }
}

/**
 * HTTP 唯一的出口。
 * 原来 HttpTool 有 6 个近乎重复的方法（callback 版 + Promise 版），现在只剩一个。
 */
export class Http {
  static async get(url: string, token: string): Promise<http.HttpResponse> {
    return Http.send(http.RequestMethod.GET, url, undefined, token)
  }

  static async post(url: string, body: Object, token: string): Promise<http.HttpResponse> {
    return Http.send(http.RequestMethod.POST, url, body, token)
  }

  private static async send(method: http.RequestMethod, url: string, body: Object | undefined,
    token: string): Promise<http.HttpResponse> {
    const request = http.createHttp()
    try {
      const header: Record<string, string> = {
        'Content-Type': 'application/json'
      }
      if (token.length > 0) {
        header['X-Auth-Token'] = token
      }
      const options: http.HttpRequestOptions = {
        method: method,
        header: header,
        expectDataType: http.HttpDataType.OBJECT,
        connectTimeout: AppConfig.CONNECT_TIMEOUT_MS,
        readTimeout: AppConfig.READ_TIMEOUT_MS,
        usingCache: false
      }
      if (body !== undefined) {
        options.extraData = JSON.stringify(body)
      }
      const response = await request.request(url, options)
      Logger.info('Http', `${method} ${url} -> ${response.responseCode}`)
      return response
    } catch (err) {
      Logger.error('Http', `${method} ${url} 失败: ${JSON.stringify(err)}`)
      throw new ApiError(0, '网络请求失败，请检查网络连接')
    } finally {
      request.destroy()
    }
  }

  /** 把非 2xx 统一转成异常，业务层不用每处重复判 responseCode */
  static ensureOk(response: http.HttpResponse, what: string): void {
    const code = response.responseCode
    if (code >= 200 && code < 300) {
      return
    }
    const hint: string = code === 401 ? '认证已过期' : code === 403 ? '无访问权限' : '服务异常'
    throw new ApiError(code, `${what}失败（${code}，${hint}）`)
  }
}
