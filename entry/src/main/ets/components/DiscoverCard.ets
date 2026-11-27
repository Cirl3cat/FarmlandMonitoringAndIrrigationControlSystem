import { tint } from '../common/Tint'
import { AppTheme, LightTheme } from '../theme/AppTheme'

/**
 * 发现页入口卡。
 * 背景图换成 4:1 的横幅（原图是近正方形，靠 Cover 裁掉 2/3 才勉强能用），
 * 这样手机（卡片约 3:1）和折叠屏展开（约 6:1）都能cover住而不奇怪。
 */
@Component
export struct DiscoverCard {
  title: string = ''
  intro: string = ''
  icon: Resource = $r('app.media.ic_robot')
  banner?: Resource = undefined
  onTap: () => void = () => {}
  @StorageProp('theme') theme: AppTheme = LightTheme

  build() {
    Stack({ alignContent: Alignment.BottomStart }) {
      if (this.banner !== undefined) {
        Image(this.banner)
          .width('100%')
          .height('100%')
          .objectFit(ImageFit.Cover)
      }

      // 压暗遮罩：左深右浅，保证白字可读又不至于把左半边压成灰板
      Column()
        .width('100%')
        .height('100%')
        .linearGradient({
          angle: 90,
          colors: [[0x73000000, 0.0], [0x26000000, 0.55], [0x0D000000, 1.0]]
        })

      Column({ space: 6 }) {
        Stack({ alignContent: Alignment.Center }) {
          Column()
            .width(32)
            .height(32)
            .borderRadius(8)
            .backgroundColor('rgba(255,255,255,0.88)')
          Image(this.icon)
            .width(20)
            .height(20)
            .colorFilter(tint('#1F2329'))
        }
        .width(32)
        .height(32)

        Text(this.title)
          .fontSize(17)
          .fontWeight(FontWeight.Medium)
          .fontColor($r('app.color.text_on_banner'))
        Text(this.intro)
          .fontSize(13)
          .fontColor($r('app.color.text_on_banner_secondary'))
      }
      .alignItems(HorizontalAlign.Start)
      .padding(16)
    }
    .width('100%')
    // 120vp：5 张正好铺满一屏，内容能一直穿到胶囊和小白条底下（不再有页尾留白）
    .height(120)
    .borderRadius(12)
    .clip(true)
    .onClick(() => this.onTap())
  }
}
