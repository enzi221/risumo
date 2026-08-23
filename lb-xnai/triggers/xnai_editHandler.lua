---@param triggerId string
---@param chatIndex number
---@param slot string
local function edit(triggerId, chatIndex, slot)
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

  local targetDesc = forKeyvis and stackItem.data.keyvis or stackItem.data.scenes[slot]
  if type(targetDesc.panels) == 'table' then
    alertNormal(triggerId, '멀티패널 씬은 패널별 구조를 사용하므로 직접 프롬프트 편집을 지원하지 않습니다.')
    return
  end

  local charD = {}
  local charP = {}
  local charN = {}
  for i, charDesc in ipairs(targetDesc.characters or {}) do
    table.insert(charD, charDesc.description or '')
    table.insert(charP, charDesc.positive or '')
    table.insert(charN, charDesc.negative or '')
  end

  addChat(triggerId, 'user', table.concat({
    '<lb-xnai-editing chatIndex="', tostring(chatIndex), '" slot="', slot, '">',
    '[Cast]\n',
    targetDesc.cast or '',
    '\n[Camera]\n',
    targetDesc.camera or '',
    '\n[Scene]\n',
    targetDesc.scene or '',
    '\n[CharP]\n',
    table.concat(charP, ' | '),
    '\n[CharD]\n',
    table.concat(charD, ' | '),
    '\n[CharN]\n',
    table.concat(charN, ' | '),
    '</lb-xnai-editing>',
  }))
end

---@class XNAIEditHandler
---@field edit fun(triggerId: string, chatIndex: number, slot: string): nil

return {
  edit = edit,
}
