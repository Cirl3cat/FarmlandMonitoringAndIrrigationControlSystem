/**
 * 敏感配置模板 —— 复制成同目录的 `Secrets.ets` 再填真实值。
 *
 * `Secrets.ets` 已写进 .gitignore，不会进版本库；
 * 业务代码一律通过 `AppConfig` 取值，不要直接引用本文件之外的凭据。
 *
 * 各项在华为云控制台的位置：
 * - IAM 用户名 / 密码 / 账号名（domain）：IAM → 用户
 * - 实例域名 / 项目 ID / 设备 ID：IoT 设备接入 → 总览 / 设备详情
 */
export class Secrets {
  /** IAM 用户名 */
  static readonly IAM_USER: string = 'YOUR_IAM_USER'

  /** IAM 密码 */
  static readonly IAM_PASSWORD: string = 'YOUR_IAM_PASSWORD'

  /** IAM 账号名（在主账号下，不是 IAM 用户名） */
  static readonly IAM_DOMAIN: string = 'YOUR_IAM_DOMAIN'

  /** IoTDA 实例域名，形如 https://<实例ID>.st1.iotda-app.cn-north-4.myhuaweicloud.com */
  static readonly IOT_ENDPOINT: string = 'YOUR_IOTDA_ENDPOINT'

  /** 项目 ID（32 位十六进制） */
  static readonly PROJECT_ID: string = 'YOUR_PROJECT_ID'

  /** 设备 ID，格式 `<产品ID>_<设备节点名>` */
  static readonly DEVICE_ID: string = 'YOUR_DEVICE_ID'
}
