import { AppConfig } from '../common/AppConfig'
import { tint } from '../common/Tint'
import { AppTheme, LightTheme } from '../theme/AppTheme'
import { DeviceProperty, DeviceSnapshot } from '../model/DeviceShadow'
import { LoadResult, MonitorVM } from '../viewmodel/MonitorVM'
import { MetricCard } from '../components/MetricCard'
import { DeviceStatusRow } from '../components/DeviceStatusRow'
import { AppHeader } from '../components/AppHeader'

/**
 * 首页「农田监测」。
 * 网络、解析、鉴权都下沉到 service / model / viewmodel，
 * 这里只负责：定时器、页面状态、渲染。
 */
@Component
export struct MonitorPage {
  @StorageProp('theme') theme: AppTheme = LightTheme
  @StorageProp('insetBottom') insetBottom: number = 8

  @State temperature: DeviceProperty = { value: '--', unit: '°C' }
  @State humidity: DeviceProperty = { value: '--', unit: '%RH' }
  @State illumination: DeviceProperty = { value: '--', unit: 'lx' }
  @State motorOn: boolean = false
  @State lightOn: boolean = false
  @State autoOn: boolean = false

  @State loading: boolean = false
  @State connection: string = '未连接'
  @State errorMsg: string = ''
  @State lastUpdate: string = ''

  private vm: MonitorVM = new MonitorVM()
  private timerId: number = -1

  aboutToAppear(): void {
    this.refresh()
    this.timerId = setInterval(() => {
      if (!this.loading) {
        this.refresh()
      }
    }, AppConfig.POLL_INTERVAL_MS)
  }

  aboutToDisappear(): void {
    if (this.timerId !== -1) {
      clearInterval(this.timerId)
      this.timerId = -1
    }
  }

  async refresh(): Promise<void> {
    if (this.loading) {
      return
    }
    this.loading = true
    this.errorMsg = ''
    this.connection = '正在同步...'

    const result: LoadResult = await this.vm.load()
    if (result.ok && result.snapshot !== undefined) {
      this.apply(result.snapshot)
      this.connection = '数据同步成功'
      this.lastUpdate = this.formatTime()
    } else {
      this.connection = '同步失败'
      this.errorMsg = result.message
    }
    this.loading = false
  }

  private apply(snapshot: DeviceSnapshot): void {
    this.temperature = snapshot.temperature
    this.humidity = snapshot.humidity
    this.illumination = snapshot.illumination
    this.motorOn = snapshot.motorOn
    this.lightOn = snapshot.lightOn
    this.autoOn = snapshot.autoOn
  }

  private formatTime(): string {
    const now = new Date()
    const hh: string = now.getHours().toString().padStart(2, '0')
    const mm: string = now.getMinutes().toString().padStart(2, '0')
    return `${hh}:${mm}`
  }

  private statusColor(): string {
    if (this.connection === '数据同步成功') {
      return this.theme.success
    }
    if (this.connection === '正在同步...') {
      return this.theme.primary
    }
    if (this.connection === '同步失败') {
      return this.theme.danger
    }
    return this.theme.textTertiary
  }

  build() {
    Column() {
      // ---------- 统一页眉 ----------
      AppHeader({
        title: '农田监测',
        statusText: this.connection,
        statusColor: this.statusColor(),
        metaText: this.lastUpdate.length > 0 ? `· ${this.lastUpdate} 更新` : ''
      })

      // ---------- 内容 ----------
      Scroll() {
        Row() {
          Column({ space: 12 }) {
          Row({ space: 12 }) {
            MetricCard({
              title: '温度',
              value: this.temperature.value,
              unit: this.temperature.unit,
              icon: $r('app.media.datapage_temperature_sun'),
              tint: '#FFC738'
            })
              .layoutWeight(1)

            MetricCard({
              title: '湿度',
              value: this.humidity.value,
              unit: this.humidity.unit,
              icon: $r('app.media.datapage_cloud_rain'),
              tint: '#A4C2D8'
            })
              .layoutWeight(1)

            MetricCard({
              title: '光照',
              value: this.illumination.value,
              unit: this.illumination.unit,
              icon: $r('app.media.datapage_sun_high'),
              tint: '#F9D29D'
            })
              .layoutWeight(1)
          }
          .width('100%')
          .height(140)

          // ---------- 设备状态 ----------
          Column({ space: 4 }) {
            Row({ space: 8 }) {
              Image($r('app.media.ic_settings'))
                .width(20)
                .height(20)
                .colorFilter(tint(this.theme.icon))
              Text('设备状态')
                .fontSize(16)
                .fontWeight(FontWeight.Medium)
                .fontColor(this.theme.textPrimary)
            }
            .width('100%')
            .height(40)

            DeviceStatusRow({
              label: '电机 / 水泵',
              icon: $r('app.media.ic_bolt'),
              on: this.motorOn
            })
            DeviceStatusRow({
              label: '补光灯',
              icon: $r('app.media.ic_bulb'),
              on: this.lightOn
            })
            DeviceStatusRow({
              label: '自动模式',
              icon: $r('app.media.ic_auto'),
              on: this.autoOn,
              showDivider: false
            })

            if (this.errorMsg.length > 0) {
              Text(this.errorMsg)
                .fontSize(12)
                .fontColor(this.theme.danger)
                .width('100%')
                .padding({ top: 4 })
            }

            Button() {
              Row({ space: 6 }) {
                if (this.loading) {
                  LoadingProgress()
                    .width(16)
                    .height(16)
                    .color(Color.White)
                } else {
                  Image($r('app.media.ic_refresh'))
                    .width(16)
                    .height(16)
                    .colorFilter(tint('#FFFFFF'))
                }
                Text(this.loading ? '同步中...' : '刷新数据')
                  .fontSize(14)
                  .fontWeight(FontWeight.Medium)
                  .fontColor(Color.White)
              }
            }
            .width('100%')
            .height(40)
            .backgroundColor(this.loading ? this.theme.textTertiary : this.theme.primary)
            .borderRadius(8)
            .enabled(!this.loading)
            .margin({ top: 8 })
            .onClick(() => {
              this.refresh()
            })
          }
          .width('100%')
          .backgroundColor(this.theme.surface)
          .borderRadius(12)
          .padding(16)
          .shadow({
            radius: 10,
            color: this.theme.isDark ? 'rgba(0,0,0,0.45)' : 'rgba(0,0,0,0.06)',
            offsetY: 3
          })

          // 尾部空白内容：高度比导航栏略高一点，滚到底时胶囊盖在这块空白上
          Row()
            .width('100%')
            .height(AppConfig.bottomSpacer(this.insetBottom))
        }
          .width('100%')
          .constraintSize({ maxWidth: AppConfig.CONTENT_MAX_WIDTH })
          .padding({ left: 16, right: 16, top: 12 })
        }
        .width('100%')
        .justifyContent(FlexAlign.Center)
        .alignItems(VerticalAlign.Top)
      }
      .width('100%')
      .layoutWeight(1)
      .scrollBar(BarState.Off)
      // 内容比视口矮时 Scroll 默认垂直居中，会把整块内容压到中间，这里强制贴顶
      .align(Alignment.Top)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.theme.bg)
  }
}
