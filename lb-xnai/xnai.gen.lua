---@param desc XNAIDescriptor
local function buildPresetPrompt(triggerId, desc)
  local lead = {}
  if desc.camera and desc.camera ~= '' then
    table.insert(lead, desc.camera)
  end
  if desc.scene and desc.scene ~= '' then
    table.insert(lead, desc.scene)
  end

  local leadText = #lead > 0 and table.concat(lead, ', ') or ''

  local chars = {}
  if desc.characters then
    for _, character in ipairs(desc.characters) do
      if character and character ~= '' then
        table.insert(chars, character)
      end
    end
  end

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

  if positive ~= '' then
    if positive:find('{prompt}', 1, true) then
      positive = positive:gsub('{prompt}', leadText)
    elseif leadText ~= '' then
      positive = table.concat({ leadText, positive }, ', ')
    end
  else
    positive = leadText
  end

  local positiveNote = getGlobalVar(triggerId, 'toggle_lb-xnai.positive') or ''
  if positiveNote ~= '' and positiveNote ~= null then
    positive = table.concat({ positive, positiveNote }, ', ')
  end
  local negativeNote = getGlobalVar(triggerId, 'toggle_lb-xnai.negative') or ''
  if negativeNote ~= '' and negativeNote ~= null then
    negative = table.concat({ negative, negativeNote }, ', ')
  end

  if #chars > 0 then
    local charP = { positive }
    local charN = { negative }

    for _, char in ipairs(chars) do
      table.insert(charP, char.positive)
      table.insert(charN, char.negative)
    end

    positive = table.concat(charP, ' | ')
    negative = table.concat(charN, ' | ')
  end

  return {
    positive = positive:gsub('%(', '\\('):gsub('%)', '\\)'),
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
    return error('API 호출 실패.')
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

---@class XNAIGen
---@field generate fun (triggerId: string, desc: XNAIDescriptor): string?
---@field insertSlots fun (text: string): string
---@field locateTargetChat fun (fullChat: Chat[]): number?

return {
  generate = generate,
  insertSlots = insertSlots,
  locateTargetChat = locateTargetChat,
}
