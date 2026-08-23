---@class XNAIPromptSet
---@field description string?
---@field name string?
---@field negative string?
---@field positive string

local COMIC_NEGATIVE_PROMPT = 'framed, outside border'
local COMIC_PROMPT =
'A one-page manga with few panels of varied sizes. A natural manga page layout with clear panel borders, varied panel sizes, and expressive visual storytelling. Use strong manga impact lines around characters.'

---@param text string
---@return string
local function cleanDescriptionBlocks(text)
  local normalized = text:gsub('\r\n', '\n'):gsub('\r', '\n')
  local lines = {}

  for line in (normalized .. '\n'):gmatch('(.-)\n') do
    table.insert(lines, line)
  end

  local cleaned = {}
  local lineIndex = 1

  while lineIndex <= #lines do
    local line = lines[lineIndex]
    local indent = line:match('^([ \t]*)') or ''
    local descriptionBlock = line:match('^[ \t]*description:[ \t]*[>|][+-]?[ \t]*$') ~= nil

    if descriptionBlock then
      local parts = {}
      local nextIndex = lineIndex + 1

      while nextIndex <= #lines do
        local nextLine = lines[nextIndex]
        local nextIndent = nextLine:match('^([ \t]*)') or ''

        if nextLine:match('^[ \t]*$') then
          nextIndex = nextIndex + 1
        elseif #nextIndent > #indent then
          table.insert(parts, nextLine:match('^[ \t]*(.-)[ \t]*$') or '')
          nextIndex = nextIndex + 1
        else
          break
        end
      end

      table.insert(cleaned, indent .. 'description: ' .. table.concat(parts, ' '))
      lineIndex = nextIndex
    else
      table.insert(cleaned, line)
      lineIndex = lineIndex + 1
    end
  end

  return table.concat(cleaned, '\n')
end

---@param value any
---@return string
local function trimText(value)
  if type(value) ~= 'string' then
    return ''
  end
  return prelude.trim(value)
end

---@param character XNAIPromptSet
---@return XNAIPromptSet
local function compileCharacter(character)
  local description = trimText(character.description)
  local positive = trimText(character.positive)

  if description ~= '' then
    positive = positive ~= '' and positive .. '. ' .. description or description
  end

  return {
    name = character.name,
    negative = character.negative,
    positive = positive,
  }
end

---@param values any[]
---@return string
local function joinNonempty(values)
  local parts = {}

  for _, value in ipairs(values) do
    local text = trimText(value)
    if text ~= '' then
      table.insert(parts, text)
    end
  end

  return table.concat(parts, ', ')
end

---@param panel XNAIPanel
---@param panelIndex number
---@return XNAIPromptSet
local function compilePanel(panel, panelIndex)
  local negativeParts = {}
  local positiveParts = {}

  for _, character in ipairs(panel.characters or {}) do
    local compiled = compileCharacter(character)
    local negative = trimText(compiled.negative)

    if negative ~= '' then
      table.insert(negativeParts, negative)
    end
    if compiled.positive ~= '' then
      table.insert(positiveParts, compiled.positive)
    end
  end

  local panelSetup = joinNonempty({ panel.cast or '', panel.camera or '', panel.scene or '' })
  local positive = 'Panel ' .. tostring(panelIndex) .. ': ' .. panelSetup
  if #positiveParts > 0 then
    positive = positive .. '.\n' .. table.concat(positiveParts, '\n')
  end

  return {
    negative = table.concat(negativeParts, ', '),
    positive = positive,
  }
end

---@param desc XNAIDescriptor
---@return { characters: XNAIPromptSet[], comic: boolean, description: string, setup: string }
local function compileDescriptor(desc)
  local characters = {}
  local comic = type(desc.panels) == 'table' and #desc.panels > 0

  if comic then
    local setup = COMIC_PROMPT

    if trimText(desc.cast) ~= '' then
      setup = setup .. '\n\n' .. trimText(desc.cast)
    end

    for panelIndex, panel in ipairs(desc.panels) do
      table.insert(characters, compilePanel(panel, panelIndex))
    end

    return {
      characters = characters,
      comic = true,
      description = '',
      setup = setup,
    }
  end

  for _, character in ipairs(desc.characters or {}) do
    table.insert(characters, compileCharacter(character))
  end

  return {
    characters = characters,
    comic = false,
    description = '',
    setup = joinNonempty({ desc.cast or '', desc.camera or '', desc.scene or '' }),
  }
end

---@param desc XNAIDescriptor
---@return XNAIPromptSet
local function buildRawPrompt(desc)
  local compiled = compileDescriptor(desc)
  local positiveParts = {}
  local charsPositive = {}
  local charsNegative = {}

  if compiled.setup ~= '' then
    table.insert(positiveParts, compiled.setup)
  end
  if compiled.description ~= '' then
    table.insert(positiveParts, compiled.description)
  end

  for _, character in ipairs(compiled.characters) do
    table.insert(charsNegative, character.negative or '')
    table.insert(charsPositive, character.positive or '')
  end
  if #charsPositive > 0 then
    table.insert(positiveParts, table.concat(charsPositive, ' |\n'))
  end

  local negative = table.concat(charsNegative, ' |\n')
  if compiled.comic then
    negative = negative ~= '' and COMIC_NEGATIVE_PROMPT .. ' |\n' .. negative or COMIC_NEGATIVE_PROMPT
  end

  return {
    negative = negative,
    positive = table.concat(positiveParts, '\n\n'),
  }
end

---@param triggerId string
---@param desc XNAIDescriptor
---@return ImagePromptSet?
local function buildPresetPrompt(triggerId, desc)
  local compiled = compileDescriptor(desc)
  local preset = getGlobalVar(triggerId, 'toggle_lb-xnai.preset')
  if not preset or preset == '' or preset == 'null' then
    preset = '1'
  end

  local comfy = getGlobalVar(triggerId, 'toggle_lb-xnai.compat.comfy') == '1'
  local positiveNote = getGlobalVar(triggerId, 'toggle_lb-xnai.positive') or ''
  if positiveNote == null then
    positiveNote = ''
  end
  local negativeNote = getGlobalVar(triggerId, 'toggle_lb-xnai.negative') or ''
  if negativeNote == null then
    negativeNote = ''
  end
  if compiled.comic then
    negativeNote = negativeNote ~= '' and negativeNote .. ', ' .. COMIC_NEGATIVE_PROMPT or COMIC_NEGATIVE_PROMPT
  end

  ---@type LightBoardImage
  local image = prelude.import(triggerId, 'lightboard.image')
  return image.applyImagePreset(triggerId, compiled, {
    characterDivider = comfy and getGlobalVar(triggerId, 'toggle_lb-xnai.compat.charDivider') == '1' and '\n\n' or ' | ',
    characterPromptSeparated = not compiled.comic and
        getGlobalVar(triggerId, 'toggle_lb-xnai.compat.charPrompt') == '1',
    comfy = comfy,
    inlineSeparator = compiled.comic and '\n\n' or ', ',
    negativeNote = negativeNote,
    positiveNote = positiveNote,
    presetBookName = '프리셋 ' .. tostring(preset),
    sectionSeparator = compiled.comic and '\n\n' or ',\n\n',
    weightMode = getGlobalVar(triggerId, 'toggle_lb-xnai.compat.weight') == '1' and 'convert' or 'strip',
  })
end

---@param triggerId string
---@param desc XNAIDescriptor
---@return string?
local function generate(triggerId, desc)
  local prompts = buildPresetPrompt(triggerId, desc)
  if not prompts then
    return error('이미지 프롬프트를 생성할 수 없습니다. 삽화 모듈 프리셋이 있나요?')
  end

  ---@type LightBoardImage
  local image = prelude.import(triggerId, 'lightboard.image')
  return image.generateImageFromPrompts(triggerId, prompts, {
    emptyPositive = '삽화 모듈 프리셋에 긍정 프롬프트가 없습니다.',
    requestFailed = 'API 호출 실패. 삽화 모듈의 저수준 접근을 꺼버렸나요?',
  })
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
  trimmed = trimmed:gsub('\n\n+', function()
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
    if type(desc) ~= 'table' then
      return
    end

    for _, character in ipairs(desc.characters or {}) do
      collect(character, meta)
    end

    for _, panel in ipairs(desc.panels or {}) do
      collectDescriptor(panel, meta)
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
  local maxSaves = math.max(1, math.floor(tonumber(getGlobalVar(triggerId, 'toggle_lb-xnai.maxSaves')) or 3))

  while #safeState > maxSaves do
    table.remove(safeState, 1)
  end

  local history = buildCharacterHistory(safeState)
  setState(triggerId, 'lb-xnai-stack', safeState)
  setChatVar(triggerId, 'lb-xnai-history', history)

  return safeState, history
end

---@class XNAIGen
---@field buildRawPrompt fun (desc: XNAIDescriptor): XNAIPromptSet
---@field cleanDescriptionBlocks fun (text: string): string
---@field generate fun (triggerId: string, desc: XNAIDescriptor): string?
---@field insertSlots fun (text: string): string
---@field locateTargetChat fun (fullChat: Chat[]): number?
---@field persistStateAndHistory fun (triggerId: string, xnaiState: XNAIStackItem[]): XNAIStackItem[], string

return {
  buildRawPrompt = buildRawPrompt,
  cleanDescriptionBlocks = cleanDescriptionBlocks,
  generate = generate,
  insertSlots = insertSlots,
  locateTargetChat = locateTargetChat,
  persistStateAndHistory = persistStateAndHistory,
}
