import { AbilityConstant, Configuration, ConfigurationConstant, UIAbility, Want } from '@kit.AbilityKit'
import { display, window } from '@kit.ArkUI'
import { Logger } from '../common/Logger'
import { AppTheme } from '../theme/AppTheme'
import { ThemeManager } from '../theme/ThemeManager'

export default class EntryAbility extends UIAbility {
  private mainWindow: window.Window | undefined = undefined

  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    // 主题必须在首帧之前就定下来，否则会先闪一下浅色
    ThemeManager.init(this.context)
    ThemeManager.subscribe((theme: AppTheme) => this.applySystemBars(theme))
    Logger.info('EntryAbility', 'onCreate')
  }

  onConfigurationUpdate(newConfig: Configuration): void {
    ThemeManager.onSystemColorModeChange(newConfig.colorMode)
  }

  onWindowStageCreate(windowStage: window.WindowStage): void {
    this.mainWindow = windowStage.getMainWindowSync()

    // 沉浸式：内容一直铺到屏幕边缘，系统条透明浮在上面。
    // 这样底部不会出现那条白底，导航胶囊直接压在内容上（类似 iOS / Windows 任务栏）。
    this.mainWindow.setWindowLayoutFullScreen(true).catch((err: Error) => {
      Logger.warn('EntryAbility', `设置沉浸式失败: ${err.message}`)
    })

    this.applySystemBars(ThemeManager.current())

    windowStage.loadContent('pages/Index', (err) => {
      if (err.code) {
        Logger.error('EntryAbility', `加载首页失败: ${JSON.stringify(err)}`)
        return
      }
      Logger.info('EntryAbility', '首页已加载')
      // 冷启动时首帧还没接管窗口，onWindowStageCreate 里设的底色会被启动页覆盖，
      // 这里内容就绪后按当前主题再刷一次（否则深色主题下状态栏会是白的）
      this.applySystemBars(ThemeManager.current())
      this.publishInsets()
    })
  }

  /**
   * 把系统条高度换算成 vp 放进 AppStorage，供页眉和导航栏避让。
   * 沉浸式之后如果不做这件事，内容会被状态栏和手势条压住。
   */
  private publishInsets(): void {
    if (this.mainWindow === undefined) {
      return
    }
    try {
      const systemArea: window.AvoidArea =
        this.mainWindow.getWindowAvoidArea(window.AvoidAreaType.TYPE_SYSTEM)
      const indicatorArea: window.AvoidArea =
        this.mainWindow.getWindowAvoidArea(window.AvoidAreaType.TYPE_NAVIGATION_INDICATOR)
      const density: number = display.getDefaultDisplaySync().densityPixels

      let top: number = Math.round(systemArea.topRect.height / density)
      if (top <= 0) {
        top = 36
      }
      let bottom: number = Math.round(indicatorArea.bottomRect.height / density)
      if (bottom <= 0) {
        bottom = 8
      }

      AppStorage.setOrCreate('insetTop', top)
      AppStorage.setOrCreate('insetBottom', bottom)
      Logger.info('EntryAbility', `insets top=${top}vp bottom=${bottom}vp`)
    } catch (err) {
      Logger.warn('EntryAbility', `读取避让区失败，使用默认值: ${JSON.stringify(err)}`)
      AppStorage.setOrCreate('insetTop', 36)
      AppStorage.setOrCreate('insetBottom', 8)
    }
  }

  /**
   * 状态栏跟随主题：深色主题用浅色字，反之亦然。
   * 沉浸式布局下两个系统条都设成透明，颜色由页面自己负责。
   */
  private applySystemBars(theme: AppTheme): void {
    if (this.mainWindow === undefined) {
      return
    }
    const windowClass = this.mainWindow
    try {
      windowClass.setWindowSystemBarProperties({
        statusBarColor: '#00000000',
        statusBarContentColor: theme.isDark ? '#FFFFFF' : '#000000',
        navigationBarColor: '#00000000',
        navigationBarContentColor: theme.isDark ? '#FFFFFF' : '#000000'
      })
      windowClass.setWindowBackgroundColor(theme.bg)
    } catch (err) {
      Logger.warn('EntryAbility', `设置系统栏颜色失败: ${JSON.stringify(err)}`)
    }
  }
}
