local C = require('./constants')
local lbdata = require('./lbdata')
local manifest = require('./manifest')

local M = {}

local COMMAND_PREFIX = '/라보'

local HELP = [[<span class="lb-command-heading">🔦라이트보드</span><br>
/라보 다시
  마지막 응답에 라이트보드 모듈을 다시 추가합니다. 기존 응답이 있으면 삭제됩니다.<br>
/라보 청소
  태그 청소 도구를 엽니다.]]

--- Wraps command output for display and request filtering.
--- @param content string
--- @return string
local function wrapCommand(content)
  return '<lb-command>\n' .. content .. '\n</lb-command>'
end

--- Parses a Lightboard chat command.
--- @param message string?
--- @return 'clean'|'help'|'rerun'|'unknown'|nil command, string? argument
function M.parse(message)
  if type(message) ~= 'string' then
    return nil, nil
  end

  local suffix = ('\n' .. message):match('\n' .. COMMAND_PREFIX .. '([^\r\n]*)')
  if suffix == nil then
    return nil, nil
  end

  local argument = suffix:match('^%s*(.-)%s*$') or ''
  if argument == '' or argument == '?' then
    return 'help', argument
  end
  if argument == '다시' then
    return 'rerun', argument
  end
  if argument == '청소' then
    return 'clean', argument
  end

  return 'unknown', argument
end

--- Returns the Lightboard command help content and active module list.
--- @param triggerId string
--- @return string
local function helpContent(triggerId)
  local manifests = manifest.list(triggerId)
  local activeModules = {}

  for _, man in ipairs(manifests) do
    if man.friendlyName then
      activeModules[#activeModules + 1] = '  ' .. man.friendlyName .. ' (ID: ' .. man.identifier .. ')'
    else
      activeModules[#activeModules + 1] = '  ' .. man.identifier
    end
  end

  if #activeModules == 0 then
    activeModules[1] = '  없음'
  end

  return HELP .. '<br><br>활성 모듈<br>' .. table.concat(activeModules, '<br>')
end

--- Returns the Lightboard command help block.
--- @param triggerId string
--- @return string
function M.help(triggerId)
  return wrapCommand(helpContent(triggerId))
end

--- Returns an unknown-command response followed by command help.
--- @param triggerId string
--- @param argument string
--- @return string
function M.unknown(triggerId, argument)
  return wrapCommand("'" .. argument .. "' 명령어를 찾을 수 없습니다.\n\n" .. helpContent(triggerId))
end

--- Removes LBDATA from the latest character chat and resolves the output target.
--- @param triggerId string
--- @return number? targetIndex, string? targetContent
local function resolveRerunTarget(triggerId)
  local fullChat = getFullChat(triggerId)

  for i = #fullChat, 1, -1 do
    local chat = fullChat[i]
    if chat and chat.role == 'char' then
      local stripped, removed = lbdata.stripLBDATA(chat.data)
      if removed then
        if stripped == '' then
          removeChat(triggerId, i - 1)
          for previousIndex = i - 1, 1, -1 do
            local previousChat = fullChat[previousIndex]
            if previousChat and previousChat.role == 'char' then
              return previousIndex - 1, previousChat.data
            end
          end
        else
          setChat(triggerId, i - 1, stripped)
          return i - 1, stripped
        end
      end
      return i - 1, chat.data
    end
  end

  return nil, nil
end

--- Inserts lazy module markers at the configured output position.
--- @param triggerId string
--- @return boolean inserted
local function insertLazyModules(triggerId)
  local manifests = manifest.list(triggerId)
  if #manifests == 0 then
    return false
  end

  local targetIndex, targetContent = resolveRerunTarget(triggerId)
  if targetIndex == nil or targetContent == nil then
    return false
  end

  local activeModules = {}
  for _, man in ipairs(manifests) do
    activeModules[#activeModules + 1] = string.format('<lb-lazy id="%s" />', man.identifier)
  end

  lbdata.insertLBDATA(triggerId, targetIndex, targetContent, table.concat(activeModules, '\n\n'))

  return true
end

--- Handles a Lightboard chat command.
--- @param triggerId string
--- @param message string?
--- @return boolean handled
function M.handle(triggerId, message)
  local command, argument = M.parse(message)
  print('handle', command, argument)
  if not command then
    return false
  end

  stopChat(triggerId)
  removeChat(triggerId, -1)

  if command == 'help' then
    addChat(triggerId, 'char', M.help(triggerId))
    return true
  end
  if command == 'clean' then
    addChat(triggerId, 'char', '%%lb-cleaner%%')
    return true
  end
  if command == 'unknown' then
    addChat(triggerId, 'char', M.unknown(triggerId, argument or ''))
    return true
  end

  if getGlobalVar(triggerId, C.CONFIG.ACTIVE) == '0' then
    addChat(triggerId, 'char', wrapCommand('[Lightboard] 다시 생성하기 전에 백엔드 전원을 켜주세요.'))
    return true
  end

  if not insertLazyModules(triggerId) then
    addChat(triggerId, 'char', wrapCommand('[Lightboard] 켜진 모듈이 없거나 채팅을 찾을 수 없습니다.'))
  end

  return true
end

return M
