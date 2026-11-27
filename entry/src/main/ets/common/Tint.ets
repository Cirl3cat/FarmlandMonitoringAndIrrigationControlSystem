/**
 * 给矢量图标上色。
 *
 * 为什么不用 Image.fillColor：那只能改 SVG 里的 fill，
 * 而我们用的图标是 stroke 描边（Tabler / MIT），fillColor 对它无效 —— 这正是
 * 上一版"深色模式下图标还是黑的"的根本原因。
 *
 * ColorFilter 是 4×5 颜色矩阵，把任意 RGB 一律映射到目标色、保留原透明度，
 * 因此对任何单色图标都成立。
 */
export interface Rgb {
  r: number
  g: number
  b: number
}

export function tint(color: string): ColorFilter {
  const rgb: Rgb = parseHex(color)
  return new ColorFilter([
    0, 0, 0, 0, rgb.r,
    0, 0, 0, 0, rgb.g,
    0, 0, 0, 0, rgb.b,
    0, 0, 0, 1, 0
  ])
}

function parseHex(color: string): Rgb {
  let hex: string = color.trim()
  if (hex.startsWith('#')) {
    hex = hex.substring(1)
  }
  // #RGB / #RRGGBB / #AARRGGBB
  if (hex.length === 3) {
    hex = `${hex[0]}${hex[0]}${hex[1]}${hex[1]}${hex[2]}${hex[2]}`
  } else if (hex.length === 8) {
    hex = hex.substring(2)
  }
  if (hex.length !== 6) {
    return { r: 1, g: 1, b: 1 }
  }
  const value: number = Number.parseInt(hex, 16)
  if (Number.isNaN(value)) {
    return { r: 1, g: 1, b: 1 }
  }
  return {
    r: ((value >> 16) & 0xFF) / 255,
    g: ((value >> 8) & 0xFF) / 255,
    b: (value & 0xFF) / 255
  }
}
