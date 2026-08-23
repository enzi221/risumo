local M = {}

M.CONFIG = {
  ACTIVE = 'toggle_lightboard.active',
  POSITION = 'toggle_lightboard.position',
  CONCURRENT = 'toggle_lightboard.concurrent',
  MAX_RETRIES = 'toggle_lightboard.maxRetries',
  RETRY_MODE = 'toggle_lightboard.retryMode',
}

M.LBDATA = {
  START = '[LBDATA START]',
  END = '[LBDATA END]',
  PATTERN_START = '%[LBDATA START%]',
  PATTERN_END = '%[LBDATA END%]',
}

return M
