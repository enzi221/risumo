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

  local lazy = getGlobalVar(triggerId, 'toggle_lb-xnai.lazy') or '0'
  if lazy == '0' and meta.type == 'generation' then
    local fullChatLength = #fullChatCache
    if meta.index == fullChatLength then
      local slotIndex = 0
      input = input:gsub('\n\n', function()
        local out = '\n\n[Slot ' .. slotIndex .. ']\n\n'
        slotIndex = slotIndex + 1
        return out
      end)
    end
  else
    if not targetIndexCache then
      ---@type XNAIGen
      local gen = prelude.import(triggerId, 'lb-xnai.gen')
      targetIndexCache = gen.locateTargetChat(fullChatCache)
    end
    if meta.index == targetIndexCache then
      local slotIndex = 0
      input = input:gsub('\n\n', '\n\n[Slot ' .. slotIndex .. ']\n\n')
    end
  end

  local node = prelude.queryNodes('lb-xnai', input)[1]
  if not node then
    return input
  end

  input = input:sub(1, node.rangeStart - 1) .. input:sub(node.rangeEnd + 1)
  return input
end

return onInput
