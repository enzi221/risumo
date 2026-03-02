--! Copyright (c) 2026 amonamona
--! CC BY-NC-SA 4.0 https://creativecommons.org/licenses/by-nc-sa/4.0/
--! LightBoard XNAI

--- TODO: Move to Prelude
--- Strips a node block and returns its position.
--- @param text string
--- @param tagName string
--- @param attrs table<string, string>?
--- @return string modifiedText, number? removedPosition, number? removedLength
local function removeNode(text, tagName, attrs)
  if not text then return '', nil end

  local nodes = prelude.queryNodes(tagName, text)
  if #nodes == 0 then return text, nil end

  local targetNode = nil
  if attrs then
    for _, node in ipairs(nodes) do
      local matchAttrs = true
      for k, v in pairs(attrs) do
        if node.attributes[k] ~= v then
          matchAttrs = false
          break
        end
      end
      if matchAttrs then
        targetNode = node
        break
      end
    end
  else
    targetNode = nodes[1]
  end

  if not targetNode then return text, nil end

  local prefix = text:sub(1, targetNode.rangeStart - 1):gsub("\n?$", "")
  local suffix = text:sub(targetNode.rangeEnd + 1):gsub("^\n?", "")

  local result = prefix .. '\n' .. suffix
  return result, #prefix + 2, #text - #result
end

--- TODO: Move to Prelude
--- @param text string
--- @param tagName string
--- @param attrs table<string, string>?
--- @return string strippedText, number? firstRemovedPos
local function stripAllNodes(text, tagName, attrs)
  local firstPos = nil
  while true do
    local removed, pos = removeNode(text, tagName, attrs)
    if removed == text then break end
    text = removed
    if not firstPos then firstPos = pos end
  end
  return text, firstPos
end

---@param triggerId string
local function clearHistory(triggerId)
  local confirmMsg = '정말 캐릭터 태그 기록을 삭제할까요? 되돌릴 수 없습니다.'
  local confirmed = alertConfirm(triggerId, confirmMsg):await()
  if confirmed then
    setChatVar(triggerId, 'lb-xnai-history', '')
  end
end

local function clearOldScenes(triggerId)
  local confirmMsg = '정말 오래된 이미지들을 채팅에서 정리할까요? 되돌릴 수 없습니다.\n\n정리된 이미지들은 인레이 탐색기에서 계속 볼 수 있습니다.'
  local confirmed = alertConfirm(triggerId, confirmMsg):await()
  if not confirmed then
    return
  end

  confirmed = alertConfirm(triggerId, '경고: 지금이라도 백업하세요. 오류가 발생해서 텍스트가 엉망이 되어도 되돌릴 수 없습니다. 정말 정리할까요?'):await()
  if not confirmed then
    return
  end

  local fullChat = getFullChat(triggerId)
  local cleansedChat = {}

  for i = 1, #fullChat do
    local chat = fullChat[i]
    if i < #fullChat - 5 and chat.role == 'char' then
      chat.data = stripAllNodes(chat.data, 'lb-xnai')
    end
    table.insert(cleansedChat, chat)
  end

  setFullChat(triggerId, cleansedChat)
  reloadDisplay(triggerId)

  alertNormal(triggerId, '⌛ 정리 완료.')
end

---@class XNAICleanHandler
---@field clearHistory fun(triggerId: string): nil
---@field clearOldScenes fun(triggerId: string): nil

return {
  clearHistory = clearHistory,
  clearOldScenes = clearOldScenes,
}
