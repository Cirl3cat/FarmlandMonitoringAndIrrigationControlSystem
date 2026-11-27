import { AppConfig } from '../common/AppConfig'

/** 设备影子的原始形状（只声明我们真正读取的字段） */
export interface ShadowProperties {
  temperature?: string | number
  humidity?: string | number
  illumination?: string | number
  motorStatus?: string | number
  lightStatus?: string | number
  autoStatus?: string | number
}

export interface ShadowReported {
  properties?: ShadowProperties
}

export interface ShadowDesired {
  properties?: ShadowProperties
}

export interface ShadowItem {
  service_id?: string
  reported?: ShadowReported
  desired?: ShadowDesired
}

export interface ShadowResponse {
  shadow?: ShadowItem[]
}

/** 一个带单位的读数，例如 { value: '25.50', unit: '°C' } */
export interface DeviceProperty {
  value: string
  unit: string
}

/** 一次上报的完整快照 */
export interface DeviceSnapshot {
  temperature: DeviceProperty
  humidity: DeviceProperty
  illumination: DeviceProperty
  motorOn: boolean
  lightOn: boolean
  autoOn: boolean
  takenAt: number
}

const EMPTY: string = '--'

/**
 * 云端的物理量是「带单位的字符串」（如 "25.50℃"），
 * 单位归一化在这里做，UI 只负责把 value 和 unit 并排显示 —— 不会再出现 "25.50℃ °C"。
 */
const UNIT_MAP: Map<string, string> = new Map<string, string>([
  ['℃', '°C'],
  ['°C', '°C'],
  ['°', '°C'],
  ['%', '%RH'],
  ['%RH', '%RH'],
  ['Lux', 'lx'],
  ['lux', 'lx'],
  ['lx', 'lx'],
  ['LX', 'lx']
])

export class DeviceShadow {
  /** 从 shadow 接口返回值解析出快照；解析失败返回 undefined（调用方据此提示"数据格式异常"） */
  static parse(raw: Object | undefined): DeviceSnapshot | undefined {
    if (raw === undefined) {
      return undefined
    }
    let body: ShadowResponse
    try {
      body = JSON.parse(JSON.stringify(raw)) as ShadowResponse
    } catch (err) {
      return undefined
    }
    const items: ShadowItem[] = body.shadow ?? []
    const target: ShadowItem | undefined =
      items.find((item: ShadowItem) => item.service_id === AppConfig.SERVICE_ID)
    const properties: ShadowProperties | undefined = target?.reported?.properties
    if (properties === undefined) {
      return undefined
    }
    const snapshot: DeviceSnapshot = {
      temperature: DeviceShadow.measure(properties.temperature, '°C'),
      humidity: DeviceShadow.measure(properties.humidity, '%RH'),
      illumination: DeviceShadow.measure(properties.illumination, 'lx'),
      motorOn: DeviceShadow.isOn(properties.motorStatus),
      lightOn: DeviceShadow.isOn(properties.lightStatus),
      autoOn: DeviceShadow.isOn(properties.autoStatus),
      takenAt: Date.now()
    }
    return snapshot
  }

  /** "25.50℃" -> { value: '25.50', unit: '°C' }；"ON" / 数字 / 空 都能兜住 */
  static measure(raw: string | number | undefined, fallbackUnit: string): DeviceProperty {
    const text: string = DeviceShadow.toText(raw)
    if (text.length === 0) {
      return { value: EMPTY, unit: fallbackUnit }
    }
    const matched: RegExpMatchArray | null =
      text.match(/^\s*([-+]?\d+(?:\.\d+)?)\s*(.*?)\s*$/)
    if (matched === null) {
      // 不是数字（例如云端直接给 "ON"），原样显示
      return { value: text, unit: '' }
    }
    const value: string = matched[1]
    const rawUnit: string = matched[2]
    const unit: string = rawUnit.length === 0
      ? fallbackUnit
      : (UNIT_MAP.get(rawUnit) ?? rawUnit)
    return { value: value, unit: unit }
  }

  /**
   * 云端状态字段是 "ON"/"OFF"，也可能被改成 "开启"/"运行中"/"1"/"true"。
   * 原实现只认小写 "on"，导致状态灯永远灰色 —— 这里统一收口。
   */
  static isOn(raw: string | number | undefined): boolean {
    const text: string = DeviceShadow.toText(raw).trim().toUpperCase()
    return text === 'ON' || text === 'TRUE' || text === '1' ||
      text === '开启' || text === '运行中' || text === '开' || text === '打开'
  }

  static statusText(on: boolean): string {
    return on ? '运行中' : '已停止'
  }

  private static toText(raw: string | number | undefined): string {
    if (raw === undefined || raw === null) {
      return ''
    }
    if (typeof raw === 'string') {
      return raw
    }
    return raw.toString()
  }
}
