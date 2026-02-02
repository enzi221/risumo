--! Copyright (c) 2026 amonamona
--! CC BY-NC-SA 4.0 https://creativecommons.org/licenses/by-nc-sa/4.0/
--! LightBoard XNAI

---@param triggerId string
---@param chatIndex number
---@param slot string
local function deleteScene(triggerId, chatIndex, slot)
  local confirmMsg = '정말 이 씬을 지우시겠습니까?'
  local confirmed = alertConfirm(triggerId, confirmMsg):await()
  if not confirmed then
    return
  end

  ---@type XNAIStackItem[]
  local fullState = getState(triggerId, 'lb-xnai-stack') or {}

  ---@type XNAIStackItem?
  local stackItem = nil
  for _, item in ipairs(fullState) do
    if item.chatIndex == chatIndex then
      stackItem = item
      break
    end
  end

  if stackItem and stackItem.data.scenes[slot] then
    stackItem.data.scenes[slot] = nil
  end

  setState(triggerId, 'lb-xnai-stack', fullState)

  local targetChat = getChat(triggerId, chatIndex)
  local targetNode = prelude.queryNodes('lb-xnai', targetChat.data, { scene = slot })

  if #targetNode > 0 then
    setChat(triggerId, chatIndex, table.concat({
      targetChat.data:sub(1, targetNode[1].rangeStart - 1),
      targetChat.data:sub(targetNode[1].rangeEnd + 1),
    }))
    return
  end
end

---@class XNAIDeleteHandler
---@field deleteScene fun(triggerId: string, chatIndex: number, slot: string): nil

return {
  deleteScene = deleteScene,
}
