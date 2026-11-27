# 实现「沉浸式亚克力胶囊导航栏」的 Prompt

> 直接复制下面整段给 AI 代理（或作为需求文档）。它自带完整规格，不需要读原仓库。

---

## 角色与目标

你是 HarmonyOS（ArkTS / ArkUI，API 12+，实测 API 20）开发。请实现一个**悬浮式亚克力胶囊导航栏**，视觉目标是对齐 iOS 26 的 "liquid glass" 标签栏：

- 屏幕底部浮着一个**胶囊形状**的半透明玻璃条，里面是 3 个 Tab（图标 + 文字）。
- 玻璃**只覆盖胶囊自身**，胶囊的**四周和下方**必须能透出页面内容（滚动中的列表、图片），不能出现任何一条底色栏、白边或矩形块。
- 页面内容要能**一直延伸到屏幕最下沿**，从胶囊底下、以及系统手势条（小白条）底下穿过去。
- 系统的状态栏与手势条必须是**沉浸式**的：手势条周围看到的也是页面内容，而不是一条白色或黑色区域。

## 技术前提

- 工程为 HarmonyOS Stage 模型，`entry` 模块，`targetSdkVersion` 与 `compatibleSdkVersion` 均为 6.0.0(20)。
- 已有：主题系统（浅色/深色两套语义色板，通过 `@StorageProp('theme')` 订阅）、一套 24×24 的描边矢量图标（stroke 风格，`fill="none"`）。
- 页面结构：`Index`（`@Entry`，用 `Stack` 承载页面内容 + 导航胶囊），其余页面通过 `router` 跳转。

## 视觉规格（请严格按这些数值）

| 元素 | 规格 |
|---|---|
| 胶囊容器 | 宽 `72%`，`constraintSize({ maxWidth: 340 })`，高 `60vp`，`borderRadius(30)`，水平居中 |
| 胶囊底边距 | `max(insetBottom - 4, 8)` vp（`insetBottom` 为手势区高度，通常 28vp）|
| 玻璃材质 | `backgroundBlurStyle(BlurStyle.COMPONENT_THICK, { colorMode: ThemeColorMode.SYSTEM, adaptiveColor: AdaptiveColor.AVERAGE, scale: 1.0 })` |
| 加色 | 浅色 `rgba(252,253,255,0.45)`；深色 `rgba(38,42,48,0.55)` |
| 描边 | `1vp`，浅色 `rgba(255,255,255,0.85)`；深色 `rgba(255,255,255,0.16)` |
| 阴影 | `radius: 10`，`offsetY: 3`，浅色 `rgba(24,39,58,0.10)`；深色 `rgba(0,0,0,0.40)`。**半径不要超过 12**，否则会在胶囊周围糊出一片柔光，看起来像"被一块区域盖住" |
| 裁剪 | 容器加 `.clip(true)`，让材质严格止于圆角 |
| Tab 项 | 每个 `72×48`，`borderRadius(24)`；选中项背景 = 主色 10%（浅）/22%（深），未选中透明 |
| 图标 | `22×22`，用 `ColorFilter` 染色（见下） |
| 文字 | `11fp`；选中主色 + `FontWeight.Medium`，未选中灰色 |
| 主色 | 浅 `#1677FF`；深 `#4A9EFF`；未选中灰：浅 `#8A9099` / 深 `#8A9099` |

## 实现步骤

### A. 窗口层（EntryAbility）

```ts
this.mainWindow = windowStage.getMainWindowSync()
// 1) 全屏布局
this.mainWindow.setWindowLayoutFullScreen(true).catch((e: Error) => { /* log */ })
// 2) 两条系统栏设为透明（注意：太早调用会抛 1300002「窗口状态异常」）
this.mainWindow.setWindowSystemBarProperties({
  statusBarColor: '#00000000',
  statusBarContentColor: theme.isDark ? '#FFFFFF' : '#000000',
  navigationBarColor: '#00000000',
  navigationBarContentColor: theme.isDark ? '#FFFFFF' : '#000000'
})
```

- 以上「系统栏属性」必须**在 `loadContent` 的回调里再调用一次**，否则冷启动时会被启动页覆盖（表现为深色主题下状态栏是白的）。
- 读取避让区并换算成 vp 写进 `AppStorage`：

```ts
const sys = this.mainWindow.getWindowAvoidArea(window.AvoidAreaType.TYPE_SYSTEM)
const nav = this.mainWindow.getWindowAvoidArea(window.AvoidAreaType.TYPE_NAVIGATION_INDICATOR)
const density = display.getDefaultDisplaySync().densityPixels
AppStorage.setOrCreate('insetTop', Math.max(Math.round(sys.topRect.height / density), 36))
AppStorage.setOrCreate('insetBottom', Math.max(Math.round(nav.bottomRect.height / density), 8))
```

### B. 页面根节点（这是沉浸式的关键，最容易漏）

`@Entry` 页面的根容器必须加：

```ts
.expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
```

**只做 A 不做 B 的话**：窗口虽然全屏，ArkUI 仍会把根节点限制在安全区内，手势条周围会出现一条**窗口底色**——这就是常见的"小白条周围一块白/黑"。

页眉（标题栏）要用 `insetTop` 撑高：`height(72 + insetTop)`、`padding({ top: 12 + insetTop })`，否则标题会压到状态栏上。

### C. 导航栏（Index 页面）

```ts
Stack({ alignContent: Alignment.Bottom }) {
  Column() { /* 三个 tab 对应的页面内容，height('100%') */ }
  Row() { /* 3 个 Tab 项，见下 */ }
    .width('72%')
    .constraintSize({ maxWidth: 340 })
    .height(60)
    .padding({ left: 6, right: 6 })
    .backgroundColor(theme.glassTint)
    .backgroundBlurStyle(BlurStyle.COMPONENT_THICK, {
      colorMode: ThemeColorMode.SYSTEM,
      adaptiveColor: AdaptiveColor.AVERAGE,
      scale: 1.0
    })
    .borderRadius(30)
    .clip(true)
    .border({ width: 1, color: theme.glassBorder })
    .shadow({ radius: 10, offsetY: 3, color: theme.isDark ? 'rgba(0,0,0,0.40)' : 'rgba(24,39,58,0.10)' })
    .margin({ bottom: Math.max(insetBottom - 4, 8) })
}
.width('100%').height('100%')
.backgroundColor(theme.bg)
.expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
```

每个 Tab 项：

```ts
Column({ space: 3 }) {
  Image(icon).width(22).height(22).colorFilter(tint(selected ? theme.navIconSelected : theme.navIcon))
  Text(title).fontSize(11)
    .fontWeight(selected ? FontWeight.Medium : FontWeight.Normal)
    .fontColor(selected ? theme.navIconSelected : theme.navIcon)
}
.width(72).height(48)
.justifyContent(FlexAlign.Center)
.backgroundColor(selected ? theme.navSelectedBg : Color.Transparent)
.borderRadius(24)
```

### D. 内容层：中途不留页尾 + 末尾垫一块空白

- 滚动容器（`List` / `Scroll`）的中途底部 padding **不能**写 `96 + insetBottom` 这类"给导航栏让位"的数值——那等于永久预留一条底栏，内容永远够不到胶囊和手势条底下。
- 列表内容要能正好铺满一屏（示例：一屏放 5 张卡 → 卡片高度 `120vp`、间距 `12vp`），这样滑动中途最后一张会自然压在胶囊与手势条下方。
- **只在每个可滚动页面（首页 / 发现 / 我的）的内容末尾放一块显式空白**，高度 = 胶囊底边距 + 胶囊高度 60 + 8vp（`AppConfig.bottomSpacer(insetBottom)`，常见设备约 92vp）。滚到底时胶囊正好盖在这块空白上，最后一项真实内容完整露在胶囊上方、点得到（v0.5.3 修订：这就是 iOS 26 的 `contentInset` 观感）。
- 二级页面（无导航胶囊）若有贴底的按钮，需要 `padding({ bottom: insetBottom + 10 })` 避让手势条。

## 硬性禁止（这些都是实测踩过的坑）

1. **不要用 `Image.fillColor()` 给图标染色**。它只改 SVG 的 `fill`，对描边图标（`fill="none"` + `stroke`）完全无效。必须用 ColorFilter：

```ts
export function tint(color: string): ColorFilter {
  // 解析 #RRGGBB -> r,g,b ∈ [0,1]
  return new ColorFilter([
    0, 0, 0, 0, r,
    0, 0, 0, 0, g,
    0, 0, 0, 0, b,
    0, 0, 0, 1, 0
  ])
}
```

2. **SVG 里不要出现 `stroke="currentColor"`**。ArkUI 的 SVG 解析器不认这个关键字，结果是**图标整块空白**。资源入库前把颜色固化为 `#000000`，运行时再染色。
3. **胶囊底边距不要写成 `insetBottom + N`**。`insetBottom` 本身就是手势区高度，叠加会出现一条"假底栏"。
4. **阴影半径别开大**（≤12）。半径 20+ 会在胶囊四周形成大片柔光，视觉上像"胶囊被一块区域包住"。
5. 滚动容器内容比视口矮时，ArkUI **默认垂直居中**，表现为顶部凭空多出一大块空白 → 给 `Scroll` 加 `.align(Alignment.Top)`。
6. 不要给胶囊加不透明背景色再叠模糊；加色必须半透明，否则看不到背后内容。

## 验收标准（逐条自检）

1. 浅色/深色下，胶囊四周与下方都能看到列表内容（不是纯色块）。
2. 列表滚动时，内容从胶囊**底下**穿过并逐渐隐入；胶囊外区域的内容**不被遮挡、不变色**。
3. 手势条（小白条）两侧和上下都是页面内容，没有独立底色区域。
4. 页面滚动到底时，最后一项完整露在胶囊上方（导航栏盖在末尾那块空白上），中途滑动时内容仍从胶囊底下穿过。
5. 页眉标题不与状态栏重叠。
6. 深色模式下所有图标为浅色，清晰可辨。

## 可选增强

- 胶囊随滚动方向收起/展开（类似 iOS 的 tab bar hide-on-scroll）。
- 点击 Tab 时给选中块加 `animateTo` 位移过渡。
- 玻璃上叠一层极淡的 1vp 顶部高光（`linearGradient`），增强"玻璃厚度"观感。
