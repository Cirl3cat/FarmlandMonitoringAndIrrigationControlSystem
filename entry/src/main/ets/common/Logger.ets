import { hilog } from '@kit.PerformanceAnalysisKit'

class LoggerImpl {
  private readonly domain: number = 0x0100
  private readonly tag: string = 'FarmMonitor'

  info(scope: string, message: string): void {
    hilog.info(this.domain, this.tag, '[%{public}s] %{public}s', scope, message)
  }

  warn(scope: string, message: string): void {
    hilog.warn(this.domain, this.tag, '[%{public}s] %{public}s', scope, message)
  }

  error(scope: string, message: string): void {
    hilog.error(this.domain, this.tag, '[%{public}s] %{public}s', scope, message)
  }
}

export const Logger: LoggerImpl = new LoggerImpl()
