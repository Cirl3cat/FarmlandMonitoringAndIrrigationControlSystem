/**
 * 账号口令模板 —— 复制成同目录的 `Secrets.ets` 再填真实值。
 *
 * `Secrets.ets` 已写进 .gitignore，不会被提交；
 * `AppConfig.ets` 只从这里取口令，业务代码不出现任何凭据。
 */
export class Secrets {
  /** IAM 用户名 */
  static readonly IAM_USER: string = 'YOUR_IAM_USER'

  /** IAM 密码 */
  static readonly IAM_PASSWORD: string = 'YOUR_IAM_PASSWORD'

  /** IAM 账号名（在主账号下，不是 IAM 用户名） */
  static readonly IAM_DOMAIN: string = 'YOUR_IAM_DOMAIN'
}
