/**
 * 亚克力（Acrylic）材质统一参数。
 *
 * 关键点：这不是「半透明背景色」，而是系统材质（COMPONENT_THICK）——
 * 它会真实采样背后的内容做模糊 + 饱和度提升，再叠加我们的加色。
 * 之前用 rgba + backdropBlur 手搓，效果不真（尤其在纯色背景上完全看不出来）。
 */
export function acrylicStyle(): BlurStyle {
  return BlurStyle.COMPONENT_THICK
}

export function acrylicOptions(): BackgroundBlurStyleOptions {
  const options: BackgroundBlurStyleOptions = {
    colorMode: ThemeColorMode.SYSTEM,
    adaptiveColor: AdaptiveColor.AVERAGE,
    scale: 1.0
  }
  return options
}

/** 轻量材质（小控件用，例如设置页的分段控件） */
export function acrylicThinStyle(): BlurStyle {
  return BlurStyle.COMPONENT_REGULAR
}
