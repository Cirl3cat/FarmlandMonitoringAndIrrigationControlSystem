import { common, ConfigurationConstant } from '@kit.AbilityKit'
import { preferences } from '@kit.ArkData'
import { AppTheme, DarkTheme, LightTheme } from './AppTheme'
import { Logger } from '../common/Logger'

/** 三态主题 */
export enum ThemeMode {
  SYSTEM = 'system',
  LIGHT = 'light',
  DARK = 'dark'
}

/** 主题变更监听（EntryAbility 用它同步状态栏颜色） */
export type ThemeListener = (theme: AppTheme) => void

/**
 * 主题中心：全项目唯一的状态源。
 *
 * - `AppStorage('theme')` 供 UI 响应式订阅（@StorageProp）。
 * - 用户选择持久化在 preferences（app_settings/themeMode）。
 * - 同时调用 ApplicationContext.setColorMode，让系统绘制的部分（弹窗、状态栏）保持一致。
 */
export class ThemeManager {
  static readonly STORAGE_KEY: string = 'theme'

  private static readonly PREF_NAME: string = 'app_settings'
  private static readonly PREF_MODE_KEY: string = 'themeMode'

  private static appContext: common.ApplicationContext | undefined = undefined
  private static systemDark: boolean = false
  private static mode: ThemeMode = ThemeMode.SYSTEM
  private static listeners: ThemeListener[] = []

  /** 启动时调用一次（EntryAbility.onCreate） */
  static init(context: common.UIAbilityContext): void {
    ThemeManager.appContext = context.getApplicationContext()
    ThemeManager.systemDark =
      context.config.colorMode === ConfigurationConstant.ColorMode.COLOR_MODE_DARK

    let saved: string = ThemeMode.SYSTEM
    try {
      const pref = preferences.getPreferencesSync(context, { name: ThemeManager.PREF_NAME })
      const stored = pref.getSync(ThemeManager.PREF_MODE_KEY, ThemeMode.SYSTEM)
      if (typeof stored === 'string') {
        saved = stored
      }
    } catch (err) {
      Logger.warn('ThemeManager', `读取主题设置失败，回退跟随系统: ${JSON.stringify(err)}`)
    }

    ThemeManager.mode = ThemeManager.parseMode(saved)
    ThemeManager.publish()
  }

  /** 当前选择（浅色 / 深色 / 跟随系统） */
  static currentMode(): ThemeMode {
    return ThemeManager.mode
  }

  /** 当前生效的色板 */
  static current(): AppTheme {
    return ThemeManager.resolve(ThemeManager.mode, ThemeManager.systemDark)
  }

  /** 系统深浅色变化（EntryAbility.onConfigurationUpdate 调用）；colorMode 可能为 undefined */
  static onSystemColorModeChange(colorMode: ConfigurationConstant.ColorMode | undefined): void {
    if (colorMode === undefined) {
      return
    }
    const dark = colorMode === ConfigurationConstant.ColorMode.COLOR_MODE_DARK
    if (dark === ThemeManager.systemDark) {
      return
    }
    ThemeManager.systemDark = dark
    if (ThemeManager.mode === ThemeMode.SYSTEM) {
      ThemeManager.publish()
    }
  }

  /** 用户切换主题：立即生效并持久化 */
  static setMode(context: common.UIAbilityContext, mode: ThemeMode): void {
    if (ThemeManager.mode === mode) {
      return
    }
    ThemeManager.mode = mode
    ThemeManager.applySystemColorMode(context, mode)
    ThemeManager.publish()
    ThemeManager.persist(context, mode)
  }

  static subscribe(listener: ThemeListener): void {
    ThemeManager.listeners.push(listener)
  }

  private static publish(): void {
    const theme = ThemeManager.current()
    AppStorage.setOrCreate(ThemeManager.STORAGE_KEY, theme)
    ThemeManager.listeners.forEach((listener: ThemeListener) => listener(theme))
  }

  private static resolve(mode: ThemeMode, systemDark: boolean): AppTheme {
    if (mode === ThemeMode.DARK) {
      return DarkTheme
    }
    if (mode === ThemeMode.LIGHT) {
      return LightTheme
    }
    return systemDark ? DarkTheme : LightTheme
  }

  private static parseMode(value: string): ThemeMode {
    if (value === ThemeMode.DARK) {
      return ThemeMode.DARK
    }
    if (value === ThemeMode.LIGHT) {
      return ThemeMode.LIGHT
    }
    return ThemeMode.SYSTEM
  }

  private static applySystemColorMode(context: common.UIAbilityContext, mode: ThemeMode): void {
    let colorMode: ConfigurationConstant.ColorMode =
      ConfigurationConstant.ColorMode.COLOR_MODE_NOT_SET
    if (mode === ThemeMode.DARK) {
      colorMode = ConfigurationConstant.ColorMode.COLOR_MODE_DARK
    } else if (mode === ThemeMode.LIGHT) {
      colorMode = ConfigurationConstant.ColorMode.COLOR_MODE_LIGHT
    }
    try {
      context.getApplicationContext().setColorMode(colorMode)
    } catch (err) {
      Logger.warn('ThemeManager', `setColorMode 失败: ${JSON.stringify(err)}`)
    }
  }

  private static persist(context: common.UIAbilityContext, mode: ThemeMode): void {
    try {
      const pref = preferences.getPreferencesSync(context, { name: ThemeManager.PREF_NAME })
      pref.putSync(ThemeManager.PREF_MODE_KEY, mode)
      pref.flush().catch((err: Error) => {
        Logger.warn('ThemeManager', `主题写入磁盘失败: ${err.message}`)
      })
    } catch (err) {
      Logger.warn('ThemeManager', `保存主题设置失败: ${JSON.stringify(err)}`)
    }
  }
}
