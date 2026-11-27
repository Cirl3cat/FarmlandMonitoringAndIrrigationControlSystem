/**
 * 语义色板。组件只引用语义名（bg / surface / textPrimary ...），
 * 不再到处硬编码 #F5F7FA、#1D2129 这类字面量。
 */
export interface AppTheme {
  /** 是否深色（用于需要区分明暗的逻辑，例如图标色调、遮罩透明度） */
  isDark: boolean

  /** 页面底色 */
  bg: string
  /** 卡片 / 面板底色 */
  surface: string
  /** 次级面板（分段控件底、输入框底） */
  surfaceAlt: string
  /** 强调色（主按钮、链接） */
  primary: string
  /** 品牌色（标题里的嫩绿） */
  brand: string
  /** 正文主色 */
  textPrimary: string
  /** 正文次色 */
  textSecondary: string
  /** 辅助说明色 */
  textTertiary: string
  /** 成功 */
  success: string
  /** 失败 / 告警 */
  danger: string
  /** 浅填充（标签底） */
  fill: string
  /** 成功态标签底 */
  successSurface: string
  /** 分割线 */
  divider: string
  /** 亚克力容器的加色（半透明，叠在模糊材质之上） */
  glassTint: string
  /** 亚克力容器的描边高光 */
  glassBorder: string
  /** 图片上的压暗遮罩（保证白字可读） */
  imageScrim: string
  /** 图片上的文字（始终为白） */
  onImage: string
  /** 通用图标色（深色模式下必须够亮，否则看不清） */
  icon: string
  /** 导航栏未选中图标 */
  navIcon: string
  /** 导航栏选中图标 */
  navIconSelected: string
  /** 导航栏选中底（iOS 风格柔和高亮） */
  navSelectedBg: string
}

export const LightTheme: AppTheme = {
  isDark: false,
  bg: '#F5F7FA',
  surface: '#FFFFFF',
  surfaceAlt: '#F2F3F5',
  primary: '#1677FF',
  brand: '#A8C82E',
  textPrimary: '#1D2129',
  textSecondary: '#4E5969',
  textTertiary: '#86909C',
  success: '#00B42A',
  danger: '#F53F3F',
  fill: '#F2F3F5',
  successSurface: '#E8FFEA',
  divider: '#EDEFF2',
  glassTint: 'rgba(252,253,255,0.45)',
  glassBorder: 'rgba(255,255,255,0.85)',
  imageScrim: 'rgba(0,0,0,0.10)',
  onImage: '#FFFFFF',
  icon: '#4E5969',
  navIcon: '#8A9099',
  navIconSelected: '#1677FF',
  navSelectedBg: 'rgba(22,119,255,0.10)'
}

export const DarkTheme: AppTheme = {
  isDark: true,
  bg: '#0E1013',
  surface: '#191C20',
  surfaceAlt: '#24282E',
  primary: '#4C9AFF',
  brand: '#CFE953',
  textPrimary: '#F2F3F5',
  textSecondary: '#C9CDD4',
  textTertiary: '#8A9099',
  success: '#34C759',
  danger: '#FF6B6B',
  fill: '#2B3038',
  successSurface: '#14301C',
  divider: '#2A2E34',
  glassTint: 'rgba(38,42,48,0.55)',
  glassBorder: 'rgba(255,255,255,0.16)',
  imageScrim: 'rgba(0,0,0,0.32)',
  onImage: '#FFFFFF',
  icon: '#E6E8EB',
  navIcon: '#8A9099',
  navIconSelected: '#5AA0FF',
  navSelectedBg: 'rgba(90,160,255,0.22)'
}
