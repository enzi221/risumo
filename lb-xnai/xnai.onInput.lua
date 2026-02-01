local triggerId = ''

local function setTriggerId(tid)
  triggerId = tid
  local source = getLoreBooks(triggerId, 'lightboard-prelude')
  if not source or #source == 0 then
    error('Failed to load lightboard-prelude.')
  end
  load(source[1].content, '@prelude', 't')()
end

local fullChatCache = nil
local targetIndexCache = nil

---@param tid string
---@param input string
---@param meta { index: number, type: 'generation'|'interaction'|'reroll' }
function onInput(tid, input, meta)
  setTriggerId(tid)

  if not fullChatCache then
    fullChatCache = getFullChat(triggerId)
  end

  ---@type XNAIGen
  local gen = prelude.import(triggerId, 'lb-xnai.gen')

  local lazy = getGlobalVar(triggerId, 'toggle_lb-xnai.lazy') or '0'
  if lazy == '0' and meta.type == 'generation' then
    local fullChatLength = #fullChatCache
    if meta.index == fullChatLength then
      input = gen.insertSlots(input)
    end
  else
    if not targetIndexCache then
      targetIndexCache = gen.locateTargetChat(fullChatCache)
    end
    if meta.index == targetIndexCache + 1 --[[JS to Lua index]] then
      input = gen.insertSlots(input)
    end
  end

  return prelude.removeAllNodes(input)
end

return onInput
