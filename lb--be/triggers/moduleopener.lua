local C = require('./constants')
local lbdata = require('./lbdata')
local manifest = require('./manifest')

local M = {}

local BUTTON_PREFIX = 'lb-add-lazy__'
local RECENT_CHAT_LIMIT = 5

--- @param content string
--- @param identifier string
--- @return boolean
local function containsModule(content, identifier)
  if #prelude.queryNodes(identifier, content) > 0 then
    return true
  end

  return #prelude.queryNodes('lb-lazy', content, { id = identifier }) > 0
end

--- @param content string
--- @param manifests Manifest[]
--- @return Manifest[]
local function findMissingManifests(content, manifests)
  local missing = {}

  for _, man in ipairs(manifests) do
    if not containsModule(content, man.identifier) then
      missing[#missing + 1] = man
    end
  end

  return missing
end

--- @param chatIndex number
--- @param missing Manifest[]
--- @return string
local function renderMenu(chatIndex, missing)
  local menuID = 'lb-module-adder-menu-' .. tostring(chatIndex):gsub('%-', 'n')
  local items = {}

  for _, man in ipairs(missing) do
    local inactive = man.mode == '0'
    items[#items + 1] = h.button {
      disabled = inactive and true or nil,
      popovertarget = menuID,
      risu_btn = not inactive and BUTTON_PREFIX .. chatIndex .. '__' .. man.identifier or nil,
      title = inactive and '꺼짐' or nil,
      type = 'button',
      h.span { man.friendlyName or man.identifier },
      h.small { man.identifier },
    }
  end

  if #items == 0 then
    items[1] = h.span['lb-module-adder-empty'] { '누락 모듈 없음' }
  end

  return tostring(h.div['lb-module-opener-root lb-module-adder-root'] {
    data_id = 'lightboard',
    h.button['lb-module-opener lb-module-adder'] {
      data_lazy = 'true',
      popovertarget = menuID,
      title = '누락 모듈 추가',
      type = 'button',
      '+',
    },
    h.dialog['lb-module-adder-menu'] {
      id = menuID,
      popover = '',
      table.unpack(items),
    },
  })
end

--- @param triggerId string
--- @param data string
--- @param meta { index: number }?
--- @return string
function M.render(triggerId, data, meta)
  if not data or data == '' or not meta or meta.index == nil then
    return data
  end

  local position = meta.index - getChatLength(triggerId)
  if position < -RECENT_CHAT_LIMIT then
    return data
  end

  local fullChat = getFullChat(triggerId)
  local sourceChat = fullChat[meta.index + 1]
  local source = sourceChat and sourceChat.data or ''
  if not source:find(C.LBDATA.PATTERN_START) then
    return data
  end

  local blockStart = nil
  local searchFrom = 1
  while true do
    local startAt, endAt = data:find(C.LBDATA.PATTERN_START, searchFrom)
    if not startAt then
      break
    end
    blockStart = endAt
    searchFrom = endAt + 1
  end

  if not blockStart then
    return data
  end

  local missing = findMissingManifests(source, manifest.listConfigured(triggerId))
  local menu = renderMenu(meta.index, missing)
  return data:sub(1, blockStart) .. '\n' .. menu .. data:sub(blockStart + 1)
end

--- @param triggerId string
--- @param code string
--- @return boolean handled
function M.handleButton(triggerId, code)
  local pattern = '^' .. prelude.escMatch(BUTTON_PREFIX) .. '(%-?%d+)__(.+)$'
  local chatIndexText, identifier = code:match(pattern)
  if not chatIndexText or not identifier then
    return false
  end

  local chatIndex = tonumber(chatIndexText)
  local fullChat = getFullChat(triggerId)
  local chat = chatIndex and fullChat[chatIndex + 1] or nil
  local man = manifest.get(triggerId, identifier)

  if not chat or not chat.data or not chat.data:find(C.LBDATA.PATTERN_START) then
    alertError(triggerId, '[Lightboard] 모듈을 추가할 LBDATA를 찾을 수 없습니다.')
    return true
  end

  if not man then
    alertError(triggerId, '[Lightboard] 활성 모듈을 찾을 수 없습니다. 모드 토글을 확인하세요.')
    return true
  end

  if containsModule(chat.data, identifier) then
    return true
  end

  local lazy = string.format('<lb-lazy id="%s" />', identifier)
  setChat(triggerId, chatIndex, lbdata.appendLBDATA(chat.data, lazy))
  return true
end

return M
