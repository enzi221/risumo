---@param text string
---@param operationID string?
---@return Node[]
local function getOperationNodes(text, operationID)
  if operationID then
    return prelude.queryNodes('lb-xnai', text, { operation = operationID })
  end

  return prelude.queryNodes('lb-xnai', text)
end

---@param triggerId string
---@param preferredIndex number
---@param operationID string?
---@return number?, Chat?, Node[]
local function locateOperationChat(triggerId, preferredIndex, operationID)
  local fullChat = getFullChat(triggerId)
  local preferredChat = fullChat[preferredIndex + 1]
  if preferredChat and type(preferredChat.data) == 'string' then
    local nodes = getOperationNodes(preferredChat.data, operationID)
    if #nodes > 0 then
      return preferredIndex, preferredChat, nodes
    end
  end

  if not operationID then
    return nil, nil, {}
  end

  for i = #fullChat, 1, -1 do
    local chat = fullChat[i]
    if type(chat.data) == 'string' then
      local nodes = getOperationNodes(chat.data, operationID)
      if #nodes > 0 then
        return i - 1, chat, nodes
      end
    end
  end

  return nil, nil, {}
end

---@param triggerId string
---@param operationID string
---@return boolean
local function removePending(triggerId, operationID)
  local fullChat = getFullChat(triggerId)
  for i = #fullChat, 1, -1 do
    local chat = fullChat[i]
    if type(chat.data) == 'string' then
      local nodes = prelude.queryNodes('lb-rerolling', chat.data, { operation = operationID })
      if #nodes > 0 then
        removeChat(triggerId, i - 1)
        return true
      end
    end
  end

  return false
end

---@param operationID string
---@return string
local function createPendingMessage(operationID)
  return table.concat({
    '---\n',
    '[LBDATA START]\n',
    '<lb-rerolling operation="', operationID, '">',
    '<div class="lb-pending lb-rerolling">',
    '<span class="lb-pending-note">이미지 생성 중, 채팅을 보내거나 다른 작업을 하지 마세요...</span>',
    '</div>',
    '</lb-rerolling>\n',
    '[LBDATA END]\n',
    '---',
  })
end

---@param triggerId string
---@param chatIndex number
---@param operationID string?
---@param slot string?
local function regenerate(triggerId, chatIndex, operationID, slot)
  prelude.info(triggerId, 'lb-xnai.regenerate',
    'Regeneration started. chatIndex=' .. tostring(chatIndex) ..
    ', operation=' .. tostring(operationID) .. ', slot=' .. tostring(slot))

  ---@type XNAIStackItem[]
  local fullState = getState(triggerId, 'lb-xnai-stack') or {}

  ---@type XNAIStackItem?
  local stackItem = nil
  for _, item in ipairs(fullState) do
    if (operationID and item.operationID == operationID) or (not operationID and item.chatIndex == chatIndex) then
      stackItem = item
      break
    end
  end

  local forKeyvis = slot == '-1'
  local selectedDescriptor = nil
  if stackItem and slot and slot ~= '' then
    selectedDescriptor = forKeyvis and stackItem.data.keyvis or stackItem.data.scenes[slot]
  end

  if not stackItem or (slot ~= nil and slot ~= '' and not selectedDescriptor) then
    alertNormal(triggerId, '이미지 생성 데이터가 사라졌어요. 오래된 이미지의 데이터는 유지하지 않습니다. 저장 개수 토글을 늘리세요.')
    return
  end

  ---@type table<string, XNAIDescriptor>
  local descriptors = {}
  local requestedCount = 0
  if selectedDescriptor then
    requestedCount = 1
    descriptors[slot] = selectedDescriptor
  else
    if stackItem.data.keyvis then
      requestedCount = requestedCount + 1
      descriptors['-1'] = stackItem.data.keyvis
    end
    for sceneSlot, desc in pairs(stackItem.data.scenes or {}) do
      requestedCount = requestedCount + 1
      descriptors[tostring(sceneSlot)] = desc
    end
  end

  if requestedCount == 0 then
    return
  end

  addChat(triggerId, 'user', createPendingMessage(triggerId))

  local success, result = pcall(function()
    ---@type table<string, string>
    local inlays = {}
    local generatedCount = 0

    ---@type XNAIGen
    local gen = prelude.import(triggerId, 'lb-xnai.gen')
    for sceneSlot, desc in pairs(descriptors) do
      inlays[sceneSlot] = gen.generate(triggerId, desc)
      generatedCount = generatedCount + 1
    end

    prelude.verbose(triggerId, 'lb-xnai.regenerate',
      'Images generated. count=' .. tostring(generatedCount))

    local resolvedIndex, targetChat, targetNodes = locateOperationChat(triggerId, chatIndex, operationID)
    if not resolvedIndex or not targetChat then
      error('이미지 생성 중 대상 채팅이 이동했거나 사라졌습니다.')
    end

    prelude.verbose(triggerId, 'lb-xnai.regenerate',
      'Target reacquired. chatIndex=' .. tostring(resolvedIndex) .. ', nodes=' .. tostring(#targetNodes))

    local out = targetChat.data
    local replacedCount = 0

    for i = #targetNodes, 1, -1 do
      local node = targetNodes[i]
      local keyvis = node.attributes.kv == 'true'
      local targetNodeSlot = keyvis and '-1' or node.attributes.scene
      local inlay = inlays[targetNodeSlot]

      if inlay then
        local openTag = node.openTag:gsub('%s*/%s*>$', '>')
        out = table.concat({
          out:sub(1, node.rangeStart - 1),
          openTag,
          inlay,
          '</lb-xnai>',
          out:sub(node.rangeEnd + 1),
        })
        replacedCount = replacedCount + 1
      end
    end

    if replacedCount ~= generatedCount then
      error('생성된 이미지와 삽입된 이미지 수가 다릅니다. generated=' .. tostring(generatedCount) ..
        ', replaced=' .. tostring(replacedCount))
    end

    setChat(triggerId, resolvedIndex, out)

    local writtenChat = getChat(triggerId, resolvedIndex)
    if not writtenChat or writtenChat.data ~= out then
      error('대상 채팅에 이미지 결과가 정상적으로 저장되지 않았습니다.')
    end

    reloadChat(triggerId, resolvedIndex)

    if stackItem.chatIndex ~= resolvedIndex then
      stackItem.chatIndex = resolvedIndex
      local stateUpdated, stateError = pcall(setState, triggerId, 'lb-xnai-stack', fullState)
      if not stateUpdated then
        prelude.info(triggerId, 'lb-xnai.regenerate',
          'State index update failed. error=' .. tostring(stateError))
      end
    end

    return {
      generatedCount = generatedCount,
      replacedCount = replacedCount,
      resolvedIndex = resolvedIndex,
    }
  end)

  if not removePending(triggerId, triggerId) then
    prelude.info(triggerId, 'lb-xnai.regenerate', 'Pending message was not found during cleanup.')
  end

  if not success then
    prelude.info(triggerId, 'lb-xnai.regenerate', 'Regeneration failed. error=' .. tostring(result))
    alertNormal(triggerId, '이미지 삽입 중 오류가 발생했습니다.\n' .. tostring(result))
    return
  end

  prelude.info(triggerId, 'lb-xnai.regenerate',
    'Regeneration committed. chatIndex=' .. tostring(result.resolvedIndex) ..
    ', generated=' .. tostring(result.generatedCount) .. ', replaced=' .. tostring(result.replacedCount))
end

---@class XNAIRegenHandler
---@field regenerate fun(triggerId: string, chatIndex: number, operationID: string?, slot: string?): nil

return {
  regenerate = regenerate,
}
