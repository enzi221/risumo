---@class XNAIPromptSet
---@field name string?
---@field position string?
---@field positive string
---@field negative string?

---@param value any
---@return string
local function trimText(value)
  if type(value) ~= 'string' then
    return ''
  end
  return prelude.trim(value)
end

---@param desc XNAIDescriptor
---@return XNAIPromptSet?
local function buildPresetPrompt(triggerId, desc)
  local preset = getGlobalVar(triggerId, 'toggle_lb-xnai.preset')
  if not preset or preset == '' or preset == 'null' then
    preset = '1'
  end

  local presetBook = prelude.getPriorityLoreBook(triggerId, '프리셋 ' .. tostring(preset))
  if not presetBook or not presetBook.content or presetBook.content == '' then
    presetBook = prelude.getPriorityLoreBook(triggerId, '프리셋 1')
  end

  if not presetBook or not presetBook.content or presetBook.content == '' then
    return nil
  end

  local content = prelude.trim(presetBook.content)
  local positive = content:match('%[Positive%]%s*([%s%S]-)%s*%[Negative%]')
  local negative = content:match('%[Negative%]%s*([%s%S]-)%s*$')

  positive = positive and prelude.trim(positive) or ''
  negative = negative and prelude.trim(negative) or ''

  local setup = {}
  if desc.camera and desc.camera ~= '' then
    table.insert(setup, desc.camera)
  end
  if desc.scene and desc.scene ~= '' then
    table.insert(setup, desc.scene)
  end

  local setupPrompt = #setup > 0 and table.concat(setup, ', ') or ''

  local chars = {}
  if desc.characters then
    for _, character in ipairs(desc.characters) do
      if character and character ~= '' then
        table.insert(chars, character)
      end
    end
  end

  local positiveNote = getGlobalVar(triggerId, 'toggle_lb-xnai.positive') or ''
  if positiveNote ~= '' and positiveNote ~= null then
    positive = table.concat({ positive, positiveNote }, ', ')
  end
  local negativeNote = getGlobalVar(triggerId, 'toggle_lb-xnai.negative') or ''
  if negativeNote ~= '' and negativeNote ~= null then
    negative = table.concat({ negative, negativeNote }, ', ')
  end

  local charDivider = getGlobalVar(triggerId, 'toggle_lb-xnai.compat.charDivider')
  local charPrompt = getGlobalVar(triggerId, 'toggle_lb-xnai.compat.charPrompt')
  local promptBody = setupPrompt

  if #chars > 0 then
    local charP = {}
    local charN = { negative }

    if promptBody ~= '' then
      table.insert(charP, promptBody)
    end

    for _, char in ipairs(chars) do
      local charPositive = char.positive

      if charPrompt == '1' then
        local rawPositive = trimText(charPositive)
        local subject = 'character'
        local remainder = rawPositive

        if rawPositive:match('^girl,%s*') then
          subject = 'girl'
          remainder = prelude.trim(rawPositive:gsub('^girl,%s*', '', 1))
        elseif rawPositive:match('^boy,%s*') then
          subject = 'boy'
          remainder = prelude.trim(rawPositive:gsub('^boy,%s*', '', 1))
        elseif rawPositive:match('^character,%s*') then
          remainder = prelude.trim(rawPositive:gsub('^character,%s*', '', 1))
        end

        local head = 'the ' .. subject
        local position = trimText(char.position)
        if position ~= '' then
          head = head .. ' ' .. position
        end

        if remainder ~= '' then
          charPositive = head .. ' is ' .. remainder
        else
          charPositive = head
        end
      end

      table.insert(charP, charPositive)
      table.insert(charN, char.negative)
    end

    if charDivider == '0' then
      promptBody = table.concat(charP, ' | ')
      negative = table.concat(charN, ' | ')
    else
      promptBody = table.concat(charP, '\n\n')
      negative = table.concat(charN, '\n\n')
    end
  end

  if positive ~= '' then
    if positive:find('{prompt}', 1, true) then
      positive = positive:gsub('{prompt}', promptBody)
    elseif promptBody ~= '' then
      positive = table.concat({ positive, promptBody }, ', ')
    end
  else
    positive = promptBody
  end

  local comfy = getGlobalVar(triggerId, 'toggle_lb-xnai.compat.comfy')
  return {
    positive = comfy == '0' and positive:gsub('%(', '\\('):gsub('%)', '\\)') or positive,
    negative = negative,
  }
end

---@param triggerId string
---@param desc XNAIDescriptor
---@return string?
local function generate(triggerId, desc)
  local prompts = buildPresetPrompt(triggerId, desc)
  if not prompts then
    return error('이미지 프롬프트를 생성할 수 없습니다. 삽화 모듈 프리셋이 있나요?')
  end

  if prompts.positive == '' then
    return error('삽화 모듈 프리셋에 긍정 프롬프트가 없습니다.')
  end

  local inlay = generateImage(triggerId, prompts.positive, prompts.negative or ''):await()
  if not inlay or inlay == '' then
    return error('API 호출 실패. 삽화 모듈의 저수준 접근을 꺼버렸나요?')
  end

  return inlay
end

---@param fullChat Chat[]
---@return number?
local function locateTargetChat(fullChat)
  local targetIndex = nil

  for i = #fullChat, 1, -1 do
    local chat = fullChat[i]
    if prelude.trim(chat.data) ~= '' and chat.role == 'char' then
      local stripped, count = chat.data:gsub('%-%-%-\n%[LBDATA START%].-LBDATA END%]\n%-%-%-', '')

      if count > 0 then
        targetIndex = i - 1 -- Lua 1-based -> JS 0-based
        stripped, _ = prelude.trim(stripped)

        if stripped == '' then
          targetIndex = targetIndex - 1 -- Skip this one; LBDATA-only, content located above
        end

        break
      end
    end
  end

  return targetIndex
end

---@param text string
---@return string
local function insertSlots(text)
  local slotIndex = 0
  local trimmed = text:match('^%s*(.-)%s*$') or text
  trimmed = trimmed:match('^%s*(.-)%s*$'):gsub('\n\n+', function()
    local out = '\n\n[Slot ' .. slotIndex .. ']\n\n'
    slotIndex = slotIndex + 1
    return out
  end)
  return trimmed
end

---@param slotA string
---@param slotB string
---@return boolean
local function sortSlots(slotA, slotB)
  local numA = tonumber(slotA)
  local numB = tonumber(slotB)

  if numA and numB then
    return numA < numB
  end

  return tostring(slotA) < tostring(slotB)
end

---@param xnaiState XNAIStackItem[]
---@return string
local function buildCharacterHistory(xnaiState)
  local historyMap = {}
  local orderedKeys = {}

  ---@param character XNAIPromptSet
  ---@param meta { chatIndex: number, source: 'keyvis'|'scene', slot?: string }
  local function collect(character, meta)
    if type(character) ~= 'table' then
      return
    end

    local name = trimText(character.name)
    local positive = trimText(character.positive)
    local negative = trimText(character.negative)

    if name == '' then
      return
    end

    local record = historyMap[name]

    if not record then
      record = {
        name = name,
        outputs = {},
        chatIndexMap = {},
      }

      historyMap[name] = record
      table.insert(orderedKeys, name)
    end

    local outputItem = {
      chatIndex = meta.chatIndex,
      source = meta.source,
      positive = positive,
    }
    if meta.slot ~= nil then
      outputItem.slot = meta.slot
    end
    outputItem.name = name
    if negative ~= '' then
      outputItem.negative = negative
    end

    local chatKey = tostring(meta.chatIndex)
    local existingIndex = record.chatIndexMap[chatKey]
    if existingIndex then
      local existingOutput = record.outputs[existingIndex]
      local existingLen = #(existingOutput.positive or '')
      local newLen = #(outputItem.positive or '')

      if newLen > existingLen then
        record.outputs[existingIndex] = outputItem
      end
      return
    end

    table.insert(record.outputs, outputItem)
    record.chatIndexMap[chatKey] = #record.outputs
  end

  ---@param desc XNAIDescriptor?
  ---@param meta { chatIndex: number, source: 'keyvis'|'scene', slot?: string }
  local function collectDescriptor(desc, meta)
    if type(desc) ~= 'table' or type(desc.characters) ~= 'table' then
      return
    end

    for _, character in ipairs(desc.characters) do
      collect(character, meta)
    end
  end

  for _, stackItem in ipairs(xnaiState or {}) do
    if type(stackItem) == 'table' and type(stackItem.data) == 'table' then
      if stackItem.data.keyvis then
        collectDescriptor(stackItem.data.keyvis, {
          chatIndex = stackItem.chatIndex,
          source = 'keyvis',
          slot = '-1',
        })
      end

      local sceneSlots = {}
      for slot, _ in pairs(stackItem.data.scenes or {}) do
        table.insert(sceneSlots, slot)
      end
      table.sort(sceneSlots, sortSlots)

      for _, slot in ipairs(sceneSlots) do
        collectDescriptor(stackItem.data.scenes[slot], {
          chatIndex = stackItem.chatIndex,
          source = 'scene',
          slot = slot,
        })
      end
    end
  end

  local history = {}
  for _, key in ipairs(orderedKeys) do
    local record = historyMap[key]
    table.insert(history, '### ' .. record.name .. '')

    for _, output in ipairs(record.outputs) do
      table.insert(history, '')
      table.insert(history, '[Log #' .. tostring(output.chatIndex) .. ']')
      table.insert(history, output.positive or '')
    end

    table.insert(history, '')
  end

  return prelude.trim(table.concat(history, '\n'))
end

---@param triggerId string
---@param xnaiState XNAIStackItem[]
---@return XNAIStackItem[], string
local function persistStateAndHistory(triggerId, xnaiState)
  local safeState = type(xnaiState) == 'table' and xnaiState or {}
  local maxSaves = tonumber(getGlobalVar(triggerId, 'toggle_lb-xnai.maxSaves')) or 3

  while #safeState > maxSaves do
    table.remove(safeState, 1)
  end

  local history = buildCharacterHistory(safeState)
  setState(triggerId, 'lb-xnai-stack', safeState)
  setChatVar(triggerId, 'lb-xnai-history', history)

  return safeState, history
end

---@class XNAIGen
---@field generate fun (triggerId: string, desc: XNAIDescriptor): string?
---@field insertSlots fun (text: string): string
---@field locateTargetChat fun (fullChat: Chat[]): number?
---@field persistStateAndHistory fun (triggerId: string, xnaiState: XNAIStackItem[]): XNAIStackItem[], string

return {
  generate = generate,
  insertSlots = insertSlots,
  locateTargetChat = locateTargetChat,
  persistStateAndHistory = persistStateAndHistory,
}
