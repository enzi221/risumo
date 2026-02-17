local fullChatCache = nil
local targetIndexCache = nil

---@param tid string
---@param input string
---@param meta { index: number, type: 'generation'|'interaction'|'reroll' }
local function main(tid, input, meta)
  if not fullChatCache then
    fullChatCache = getFullChat(tid)
  end

  ---@type XNAIGen
  local gen = prelude.import(tid, 'lb-xnai.gen')

  local lazy = getGlobalVar(tid, 'toggle_lb-xnai.lazy') or '0'
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

return main
