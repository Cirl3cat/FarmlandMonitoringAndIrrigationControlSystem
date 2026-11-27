# 智能农田监测施肥灌溉一体化系统 · 北向 App

HarmonyOS（ArkTS）手机端看板：从华为云 IoTDA 读取设备影子，展示农田温湿度、光照与设备运行状态。

> 本仓库只有 **北向（App）**。南向固件（RK2206 / LiteOS-M）不在本仓库内，两者通过云端 MQTT 协议对接，契约见下文。

---

## 快速开始

1. 用 DevEco Studio 打开本目录，配置签名（`build-profile.json5` 的 `signingConfigs`）—— 模拟器可不签名直接装。
2. 把 `entry/src/main/ets/common/Secrets.example.ets` 复制成同目录的 `Secrets.ets`，填上自己的 IAM 账号口令（真实的 `Secrets.ets` 已在 `.gitignore` 里，不会进版本库）。
3. 运行（云端无上报时页面数值显示 `--`、状态显示「已停止」属于预期）。

命令行编译（无需打开 IDE）：

```powershell
$env:NODE_HOME='<DevEco Studio>\tools\node'
$env:DEVECO_SDK_HOME='<DevEco Studio>\sdk'
& '<DevEco Studio>\tools\hvigor\bin\hvigorw.bat' --mode module -p product=default assembleHap --no-daemon
```

产物：`entry/build/default/outputs/default/entry-default-unsigned.hap`

---

## 目录结构

```
entry/src/main/ets/
├── entryability/EntryAbility.ets   启动：初始化主题 → 状态栏配色 → 加载首页
├── common/
│   ├── AppConfig.ets               域名 / 项目 ID / 设备 ID / 轮询间隔（非敏感配置的唯一出处）
│   ├── Secrets.ets                 账号口令（唯一敏感文件，勿提交）
│   ├── Http.ets                    全项目唯一 HTTP 出口
│   ├── AppRouter.ets               路由 + 未实现功能的统一提示
│   └── Logger.ets                  hilog 封装
├── theme/
│   ├── AppTheme.ets                语义色板（浅色 / 深色两套）
│   ├── ThemeManager.ets            三态主题：浅色 / 深色 / 跟随系统 + 持久化
│   └── Acrylic.ets                 亚克力材质参数
├── model/DeviceShadow.ets          影子解析 + 单位归一 + ON/OFF 判定
├── service/
│   ├── IamAuthService.ets          IAM 认证，token 缓存到真实过期时间
│   └── ShadowService.ets           取影子（401 自动重登重试一次）
├── viewmodel/MonitorVM.ets         首页逻辑（不碰 UI、不碰定时器）
├── components/                     MetricCard / DeviceStatusRow / PageHeader / DiscoverCard
├── pages/                          Index（Tab 容器）/ MonitorPage / Discover / Profile / Settings / AI / ChinaAgri / CalendarPage / Detail（长文本详情）
└── utils/Lunar.ets                 农历 + 节气
```

分层原则：**页面只管渲染和生命周期，网络与解析在 service/model，纯计算在 utils。**

---

## 与南向的协议契约（改这里会断链）

```
上报  $oc/devices/{deviceId}/sys/properties/report
命令  $oc/devices/{deviceId}/sys/commands/#
应答  $oc/devices/{deviceId}/sys/commands/response/request_id={id}

service_id : "smartHome"
properties : illumination "396.67Lux" | temperature "31.48℃" | humidity "52.59%"
             motorStatus "ON|OFF"   | lightStatus "ON|OFF"  | autoStatus "ON|OFF"
```

- 温/湿/光是**带单位的字符串**，解析见 `DeviceShadow.measure()`（单位归一化，避免 UI 重复拼单位）。
- 状态是大写 `ON/OFF`，判定见 `DeviceShadow.isOn()`。
- 目前 App **只读**影子，不下发命令；控制通路在板子上（按键 / 语音 / 云命令）。

---

## 主题（浅色 / 深色 / 跟随系统）

- 三态入口：`我的 → 通用设置 → 主题外观`。
- 状态源是 `AppStorage('theme')`，所有组件用 `@StorageProp('theme')` 订阅，切换即时生效、无需重启。
- 选择持久化在 `preferences(app_settings/themeMode)`；`EntryAbility` 在首帧前读取，避免启动闪白。
- 同时调用 `ApplicationContext.setColorMode()`，让系统绘制的部分（弹窗、状态栏）保持一致。
- 新增颜色时改 `AppTheme.ets` 的两个色板即可，**不要在页面里写颜色字面量**。
- 主题选框本身已经表明当前状态，**下面不要再放一行「当前：跟随系统…」的灰字**（v0.5.5 已删）。

## 设置页：一行放不下的值

「关于 → 应用」「数据源 → 设备」这类长值在行内用省略号收敛，行尾多一个 `›`；**点整行**进 `pages/Detail`（`AppRouter.openInfo(ui, label, value)`）看全文，可长按选中或点「复制」。

是否截断由 `Settings.isOverflow()` 用 `getUIContext().getMeasureUtils().measureText()` 实测字宽判断（返回值是 px，除以 `densityPixels` 得到 vp，再和可用宽度比），**不靠字数猜**——所以折叠屏展开后放得下的行不会冒箭头，短值点了也不跳转。

## 亚克力导航栏

底部胶囊导航用系统材质 `BlurStyle.COMPONENT_THICK` + `backgroundBlurStyle`，真实采样下方滚动内容做模糊/饱和度提升，再叠加半透明加色与 0.5vp 描边。

注意：**手搓 `backdropBlur() + rgba` 不是亚克力**——它在纯色背景上完全看不出效果，这是旧实现"感觉没做出来"的原因。

## 背景图规范

`resources/base/media/banner_*.jpg`，**4:1 横向构图**（2400×600 或 2048×512），主体居中，四边留可裁切余量。

原因：卡片高度固定 110vp，宽度随屏幕变化——

| 设备 | 卡片宽高比 | 4:1 图的裁切方式 |
|---|---|---|
| 手机（360vp） | ≈3:1 | 横向居中裁掉两侧各 12.5% |
| 折叠屏展开（≈700vp） | ≈6:1 | 纵向居中裁掉上下各 16% |

主体居中 + 4:1 是这个区间里的安全中值。**不要把主体放在画面最右侧或最上方**，否则窄屏会切到。

## 图标与页眉规范（v0.5.2）

**图标一律用矢量（SVG）**，来源 [Tabler Icons](https://github.com/tabler/tabler-icons)（MIT）。位图只保留 `startIcon.png`（应用图标，系统要求）和 `banner_*.jpg`（照片类背景）。

两个必须注意的点：

1. **不要用 `stroke="currentColor"`**。ArkUI 的 SVG 解析器不认这个关键字，结果是**图标整块不显示**（不是变黑，是空白）。放进 `resources` 前要把颜色固化成 `#000000`，再运行时染色。
2. **不要用 `Image.fillColor()` 染色**。它只改 SVG 的 `fill`，而 Tabler 是描边图标（`fill="none"` + `stroke`），改了没用 —— 这正是旧版"深色模式图标发黑看不 
清"的根因。正确做法是 `colorFilter(new ColorFilter(4×5 矩阵))`，见 `common/Tint.ets`：把任意 RGB 映射到目标色、保留透明度。

**页眉统一**：所有页面（首页 / 发现 / 我的 / 设置 / 日历 / AI / 资讯）共用 `components/AppHeader.ets` —— 白底（深色为面板色）、底部 16 圆角、投影、品牌色 24 号标题 + 状态行/副标题 + 可选「关闭」。不要再自己写页头。

## 沉浸式与系统条

目标：**胶囊导航栏**和**手势小白条**周围看到的都是页面内容，没有任何一条底色栏；列表内容能从两者底下穿过去。

三件事缺一不可：

1. **窗口**：`EntryAbility` 里 `setWindowLayoutFullScreen(true)`，状态栏/导航栏颜色设为 `#00000000`。
2. **页面根节点**：必须加 `.expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])`。只做第 1 步的话，窗口虽然是全屏，但 ArkUI 会把根节点限制在安全区内 —— 这正是"小白条周围有一块白色区域"的原因（那块是窗口底色，不是系统栏）。
3. **中途不留页尾，末尾垫一块空白。** 列表的 `padding.bottom` 原来是 `96 + insetBottom`，等于永久预留一条"底栏"，内容永远够不到胶囊和手势条底下 —— 这个已经去掉，中途滑动时最后一张自然压在胶囊和小白条下面。真正的做法是**在每个可滚动页面（首页 / 发现 / 我的）的内容末尾放一块显式空白**：高度 = `AppConfig.bottomSpacer(insetBottom)` = 胶囊底边距 + 胶囊高度 60 + 8vp（这台设备约 92vp）。滚到底时胶囊正好盖在这块空白上，最后一项真实内容完整露在胶囊上方，点得到也看得清。这就是 iOS 26 液态玻璃导航栏那套 `contentInset` 的观感，只是写成了显式元素，比给 `List` 加 `padding.bottom` 更可控。

避让仍然要自己做：`getWindowAvoidArea()` 换算成 vp 写进 `AppStorage('insetTop' / 'insetBottom')`；`AppHeader` 用 `insetTop` 撑高（否则标题会压到状态栏上），悬浮胶囊用 `insetBottom` 抬到手势条上方。

两个容易翻车的细节：

- **胶囊底边距别写 `insetBottom + 10`**。`insetBottom` 本身就是手势区高度（这台设备 28vp），再叠 10 会空出一大条，看起来像"下面还有一条栏"。用 `max(insetBottom - 4, 8)`。
- **`.clip(true)` 会连背景模糊一起裁掉**，玻璃会退化成一层白纱。当前保留 `clip(true)` 是为了让材质严格止于圆角（不加会在四角糊出矩形）；如果以后要更强的模糊，得换别的遮罩方式。
- **沉浸式页面里的底部按钮要让开手势区**（日历「保存」踩过）。


三折叠展开后是 **1108vp 宽**，铺满会把卡片拉成 10:1、背景图只剩一条缝。规则：

1. **所有页面内容限宽 700vp 并居中**（`AppConfig.CONTENT_MAX_WIDTH`）。卡片宽高比因此稳定在 3:1（手机）~6.4:1（大屏）。
2. **`Scroll` 必须加 `.align(Alignment.Top)`**。内容比视口矮时 ArkUI 默认**垂直居中**，表现为"页面顶部莫名多出一大块空白"（实测多出 54vp，正好是 (视口-内容)/2）。这是本次排查中最隐蔽的一个坑。
3. **日历栅格限宽 420vp + 固定格高**。日历格用 `aspectRatio` 时，大屏上格子按宽度等比放大，6 行排不下会被裁掉两周。

验证方式：`hdc` 连模拟器 → `snapshot_display` 截图 → `uitest dumpLayout` 导出组件树看真实 bounds，别靠肉眼估。

---

## 相对旧版的改动

| 项 | 旧 | 新 |
|---|---|---|
| 分层 | DataPage 409 行内混网络+解析+UI | service / model / viewmodel / components 分层 |
| 凭证 | 散落在 2 个页面源码里 | 只在 `Secrets.ets` |
| token | 每次刷新重新登录 IAM | 缓存到真实过期时间，401 自动重登 |
| 状态判定 | 只认小写 `on`，云端给 `ON` → 永远灰 | `isOn()` 统一收口 |
| 单位 | UI 与云端各拼一次 → `25.50℃ °C` | 解析时归一，只显示一次 |
| 图片资源 | 5 张 2048px PNG，23.9 MiB | 4:1 JPEG，约 0.7 MiB（省 97%） |
| 导航栏 | rgba + backdropBlur 手搓 | 系统亚克力材质 |
| 主题 | 只有跟随系统，无开关 | 三态 + 设置页 + 持久化 |
| 死代码 | Home / 5 个空页面 / 9 个死链静默失败 | 已删除；未实现入口给明确提示 |
| 应用名 | `T_T` / `label` | 智慧农田 |

## 已知限制

- **已在 `Huawei_TripleFold` 模拟器（HarmonyOS 6.0.0(20)，3184×2232 @460dpi）上实机验证**：首页 / 发现 / 我的 / 设置 / 日历、浅色与深色、主题持久化、云端认证与影子读取均正常；未在真机上验证。
- 云端设备自 2026-04 后无数据上报，页面数值恒为 `--`、状态恒为"已停止"，属预期。
- 「产量估计」「土壤肥力速算」「农场管理」等入口为占位，点击提示"建设中"。
- 南向固件不在本仓库，`autoStatus` 目前恒为 `OFF`（板子侧自动模式未启用）。
- 未签名 HAP 在模拟器上可直接 `hdc install`；真机安装仍需在 DevEco 配置签名。

---

## 许可

[MIT](LICENSE) © 2026 Cirl3cat

图标来自 [Tabler Icons](https://github.com/tabler/tabler-icons)（MIT）；背景图为本项目自有素材。南向固件（RK2206）不在本仓库范围内。
