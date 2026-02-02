---@param triggerId string
---@param chatIndex number
---@param slot string?
local function regenerate(triggerId, chatIndex, slot)
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

  local forKeyvis = slot == '-1'

  if not stackItem or (slot ~= nil and (forKeyvis and not stackItem.data.keyvis) and not stackItem.data.scenes[slot]) then
    alertNormal(triggerId, '이미지 생성 데이터가 사라졌어요. 오래된 이미지의 데이터는 유지하지 않습니다. 저장 개수 토글을 늘리세요.')
    return
  end

  ---@type table<string, XNAIDescriptor>
  local descriptors = {}
  local count = 0
  if slot and slot ~= '' then
    local desc = forKeyvis and stackItem.data.keyvis or stackItem.data.scenes[slot]
    if desc then
      count = count + 1
      descriptors[slot] = desc
    end
  else
    if stackItem.data.keyvis then
      count = count + 1
      descriptors['-1'] = stackItem.data.keyvis
    end
    for sceneSlot, desc in pairs(stackItem.data.scenes or {}) do
      count = count + 1
      descriptors[tostring(sceneSlot)] = desc
    end
  end

  if count == 0 then
    return
  end

  local message = [[---
[LBDATA START]
<lb-rerolling><div class="lb-pending lb-rerolling"><span class="lb-pending-note">이미지 생성 중, 채팅을 보내거나 다른 작업을 하지 마세요...</span></div></lb-rerolling>
[LBDATA END]
---]]
  addChat(triggerId, 'user', message)

  ---@type table<string, string>
  local inlays = {}

  ---@type XNAIGen
  local gen = prelude.import(triggerId, 'lb-xnai.gen')
  for sceneSlot, desc in pairs(descriptors) do
    local success, data = pcall(gen.generate, triggerId, desc)
    if success then
      inlays[sceneSlot] = data
    else
      alertNormal(triggerId, '이미지 생성 중 오류가 발생했습니다.\n' .. tostring(data))
      removeChat(triggerId, -1)
      return
    end
  end

  local out = getChat(triggerId, chatIndex).data
  local allTargetNodes = prelude.queryNodes('lb-xnai', out)

  -- reverse order to not mess up ranges
  for i = #allTargetNodes, 1, -1 do
    local node = allTargetNodes[i]
    local isKeyvis = node.attributes.kv == 'true'
    local targetNodeSlot = isKeyvis and '-1' or node.attributes.scene

    if inlays[targetNodeSlot] then
      local attribute = isKeyvis and 'kv' or table.concat({ 'scene="', targetNodeSlot, '"' })

      out = table.concat({
        out:sub(1, node.rangeStart - 1),
        table.concat({ '<lb-xnai ', attribute, '>', inlays[targetNodeSlot], '</lb-xnai>' }),
        out:sub(node.rangeEnd + 1),
      })
    end
  end

  setChat(triggerId, chatIndex, out)
  removeChat(triggerId, -1)
end

---@class XNAIRegenHandler
---@field regenerate fun(triggerId: string, chatIndex: number, slot: string?): nil

return {
  regenerate = regenerate,
}
