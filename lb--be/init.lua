---@diagnostic disable: lowercase-global

local manifest = require('./manifest')
local sideeffect = require('./sideeffect')
local lbdata = require('./lbdata')
local pipeline = require('./pipeline')
local C = require('./constants')

local triggerId = ''

local function setTriggerId(tid)
  triggerId = tid
  if type(prelude) ~= "nil" then return end
  local source = getLoreBooks(triggerId, 'lightboard-prelude')
  if not source or #source == 0 then
    error('Failed to load lightboard-prelude.')
  end
  load(source[1].content, '@prelude', 't')()
end

--- Inserts content at position.
--- @param text string
--- @param position number
--- @param newContent string
--- @return string
local function insertAtPosition(text, position, newContent)
  return text:sub(1, position - 1) .. newContent .. '\n' .. text:sub(position)
end

local removeNode = lbdata.removeNode

--- Finds the last chat index with `char` role within a range.
--- @param fullChat Chat[]
--- @param startOffset number (e.g., -1, -2, ...)
--- @param range number (how many logs to search back)
--- @return number? index, Chat? chat
local function findLastCharChat(fullChat, startOffset, range)
  local searchStart = #fullChat + startOffset
  local searchEnd = math.max(searchStart - (range or 5), 1)

  for i = searchStart, searchEnd, -1 do
    if fullChat[i] and fullChat[i].role == 'char' then
      return i, fullChat[i]
    end
  end
  return nil, nil
end

local runPipelineAsync = pipeline.runPipelineAsync

--- @param manifests Manifest[]
local main = async(function(manifests)
  local fullChat = getFullChat(triggerId)

  -- Separate normal and sideEffect manifests
  local normalManifests = {}
  local sideEffectManifests = {}

  for _, man in ipairs(manifests) do
    if man.sideEffect then
      table.insert(sideEffectManifests, man)
    else
      table.insert(normalManifests, man)
    end
  end

  -- Phase 1: Run normal manifests in parallel and assemble LBDATA
  local allProcessedResults = {}
  local maxConcurrent = math.min(5, math.max(1, tonumber(getGlobalVar(triggerId, C.CONFIG.CONCURRENT)) or 1))

  for i = 1, #normalManifests, maxConcurrent do
    --- @type Promise<string>[]
    local currentChunkPromises = {}
    local chunkEndIndex = math.min(i + maxConcurrent - 1, #normalManifests)

    for j = i, chunkEndIndex do
      local man = normalManifests[j]
      table.insert(currentChunkPromises, runPipelineAsync(triggerId, man, fullChat, {
        type = 'generation',
        lazy = man.lazy
      }))
    end

    print('[LightBoard Backend][VERBOSE] Waiting for chunks...')

    --- @type string[]
    local chunkResults = Promise.all(currentChunkPromises):await()
    if chunkResults then
      for _, chunkResult in ipairs(chunkResults) do
        if type(chunkResult) == "string" and chunkResult ~= "" then
          table.insert(allProcessedResults, chunkResult)
        end
      end
    end
  end

  -- Get the latest full chat again in case other scripts modified it
  local fullChatNewest = getFullChat(triggerId)
  local lastCharChatIdx = findLastCharChat(fullChatNewest, 0, 5)
  local lastCharChat = lastCharChatIdx and fullChatNewest[lastCharChatIdx].data or ''

  if #allProcessedResults > 0 then
    local contents = table.concat(allProcessedResults, '\n\n')
    local updated = lbdata.replaceLBDATA(lastCharChat, contents)

    if updated then
      setChat(triggerId, lastCharChatIdx ~= nil and (lastCharChatIdx - 1) or -1, updated)
      lastCharChat = updated
    else
      -- Fallback: if a placeholder block wasn't found (unexpected), keep old behavior.
      local header = '---\n[LBDATA START]'
      local footer = '\n\n[LBDATA END]\n---'
      local assembled = header .. '\n' .. contents .. footer

      -- 0: append, 1: prepend, 2: separated
      local position = getGlobalVar(triggerId, C.CONFIG.POSITION) or '0'
      if position == '2' then
        addChat(triggerId, 'char', assembled)
      else
        local finalMessage = position == '1' and assembled .. '\n\n' .. lastCharChat or
            lastCharChat .. '\n\n' .. assembled
        setChat(triggerId, lastCharChatIdx ~= nil and (lastCharChatIdx - 1) or -1, finalMessage)
        lastCharChat = finalMessage
      end
    end
  else
    print("[LightBoard] All normal manifests processed. No new content to add.")
  end

  local success, message = pcall(sideeffect.runSideEffects, triggerId, {
    sideEffectManifests = sideEffectManifests,
    fullChat = fullChat,
    maxConcurrent = maxConcurrent,
  })
  if not success then
    error('[LightBoard Backend] SideEffect Error: ' .. tostring(message))
  end
end)

onOutput = async(function(tid)
  setTriggerId(tid)

  if getGlobalVar(tid, C.CONFIG.ACTIVE) == '0' then
    return
  end

  local manifests = manifest.list(triggerId)
  if #manifests == 0 then
    return
  end

  local fullChat = getFullChat(tid)
  local position = getGlobalVar(tid, C.CONFIG.POSITION) or '0'
  if position == '0' then
    setChat(tid, -1, fullChat[#fullChat].data .. '\n\n---\n[LBDATA START]\n[LBDATA END]\n---')
  elseif position == '1' then
    setChat(tid, -1, '---\n[LBDATA START]\n[LBDATA END]\n---\n\n' .. fullChat[#fullChat].data)
  else
    addChat(tid, 'char', '---\n[LBDATA START]\n[LBDATA END]\n---')
  end

  local success, result = pcall(function()
    local mainPromise = main(manifests)
    return mainPromise:await()
  end)

  if not success then
    print('[LightBoard Backend] Backend Error: ' .. tostring(result))
    alertError(tid, '[LightBoard] 백엔드 오류. 개발자에게 문의해주세요.\n' .. tostring(result))
  end
end)

---@param identifier string module identifier
---@param blockID string? for rerolling specific block
local function reroll(identifier, blockID)
  local active = prelude.getFlagToggle(triggerId, 'lightboard.active')
  if not active then
    error('리롤 전에 백엔드를 활성화해주세요.')
    return
  end

  local man = manifest.get(triggerId, identifier)
  if not man then
    error('이 모듈을 찾을 수 없습니다. 프론트엔드의 모드 토글이 설정돼있나요?')
    return
  end

  local fullChat = getFullChat(triggerId)
  local resolved = lbdata.resolveTargets(fullChat)

  if not resolved.targetIdx then
    error('리롤 불가 - 대상 채팅을 찾을 수 없습니다.')
    return
  end

  local lbdataJsIdx = resolved.lbdataIdx
  local targetJsIdx = resolved.targetIdx

  ---@cast lbdataJsIdx number
  ---@cast targetJsIdx number

  -- to Lua 1-based
  local lbdataIdx = lbdataJsIdx + 1
  local targetIdx = targetJsIdx + 1
  local isSeparated = lbdataIdx ~= targetIdx

  local originalLbdataContent = resolved.lbdataContent or ''
  local originalTargetContent = resolved.targetContent or ''

  local cleanedLbdata, lazyPos = removeNode(originalLbdataContent, 'lb-lazy', { id = identifier })

  local cleanedTarget = isSeparated and originalTargetContent or cleanedLbdata
  local prevPos = nil
  while true do
    local removed, pos = removeNode(cleanedTarget, identifier, blockID and { id = blockID } or nil)
    if removed == cleanedTarget then break end
    cleanedTarget = removed
    if not prevPos then prevPos = pos end
  end

  if not isSeparated then
    cleanedLbdata = cleanedTarget
  end

  setChat(triggerId, lbdataJsIdx, cleanedLbdata)
  if isSeparated then
    setChat(triggerId, targetJsIdx, cleanedTarget)
  end

  -- TODO: Move out of reroll
  local message = [[---
[LBDATA START]
<lb-rerolling><div class="lb-pending lb-rerolling"><span class="lb-pending-note">%s 재생성 중, 채팅을 보내거나 다른 모듈을 재생성하지 마세요...</span></div></lb-rerolling>
[LBDATA END]
---]]
  addChat(triggerId, 'user', message:format(identifier))

  local targetPosition = nil
  if not isSeparated then
    if prevPos and lazyPos then
      if prevPos < lazyPos then
        local removed = originalLbdataContent:sub(prevPos, prevPos + (cleanedTarget:len() - cleanedLbdata:len()))
        targetPosition = lazyPos - removed:len()
      else
        targetPosition = lazyPos
      end
    elseif lazyPos then
      targetPosition = lazyPos
    elseif prevPos then
      targetPosition = prevPos
    end
  else
    targetPosition = prevPos
  end

  -- force rerender
  setChat(triggerId, targetJsIdx, cleanedTarget)

  if man.rerollBehavior == "remove-prev" then
    fullChat[targetIdx].data = cleanedTarget
  end

  local contextSlice = { table.unpack(fullChat, 1, targetIdx) }

  local success, result = pcall(function()
    return runPipelineAsync(triggerId, man, contextSlice, { type = 'reroll', lazy = false }):await()
  end)

  if not success or not result then
    setChat(triggerId, targetJsIdx, originalTargetContent)
    if isSeparated then
      setChat(triggerId, lbdataJsIdx, originalLbdataContent)
    end
    alertError(triggerId, '[LightBoard] 리롤 실패. ' .. identifier .. ' 개발자에게 문의하세요.\n' .. tostring(result))
    return
  end

  local finalChat

  if man.sideEffect then
    sideeffect.handleSideEffectResult(triggerId, {
      man = man,
      action = 'reroll',
      result = result,
      identifier = identifier,
      blockID = blockID,
      onError = function(msg) alertError(triggerId, msg) end,
    })
  else
    if targetPosition then
      finalChat = insertAtPosition(cleanedTarget, targetPosition, result)
    else
      finalChat = lbdata.fallbackInsert(cleanedTarget, result)
    end

    setChat(triggerId, targetJsIdx,
      man.onMutation and man.onMutation(triggerId, 'reroll', finalChat) or finalChat)
  end
end

--- @class InteractionMod
--- @field action string
--- @field blockID string?
--- @field immediate boolean
--- @field preserve boolean

--- @param action string
--- @return InteractionMod
local function parseInteractionModifiers(action)
  local blockID = nil
  local cleanAction = action
  local immediate = false
  local preserve = false

  local hashPos = action:find("#", 1, true)
  if hashPos then
    local modifiers = action:sub(1, hashPos - 1)
    cleanAction = action:sub(hashPos + 1)

    local modifierParts = prelude.split(modifiers, ";")
    for _, part in ipairs(modifierParts) do
      local trimmed = prelude.trim(part)
      if trimmed == "preserve" then
        preserve = true
      elseif trimmed == "immediate" then
        immediate = true
      elseif trimmed:match("^id=") then
        blockID = trimmed:match("^id=(.+)$")
      end
    end
  end

  return {
    action = cleanAction,
    blockID = blockID,
    preserve = preserve,
    immediate = immediate,
  }
end

---@param fullChat Chat[]
---@param identifier string
---@param action string
---@param direction string
local function interact(fullChat, identifier, action, direction)
  local active = prelude.getFlagToggle(triggerId, 'lightboard.active')
  if not active then
    error('리롤 전에 백엔드를 활성화해주세요.')
    return
  end

  local man = manifest.get(triggerId, identifier)
  if not man then
    error('이 모듈을 찾을 수 없습니다. 프론트엔드의 모드 토글이 설정돼있나요?')
    return
  end

  -- #fullChat = direction, #fullChat-1 = identifier+action, #fullChat-2 = last char chat to modify)
  local idx, targetChat = findLastCharChat(fullChat, -1, 5)

  if not idx or not targetChat then
    error('상호작용 불가 - 마지막 5개 채팅 중 캐릭터 채팅이 없습니다.')
    return
  end

  local originalContent = targetChat.data
  local modifiers = parseInteractionModifiers(action)

  local interactionGuideline = prelude.getPriorityLoreBook(triggerId, man.identifier .. ".lb.interaction")
  if not interactionGuideline or interactionGuideline.content == "" then
    error(identifier .. '에 상호작용 지침이 없습니다. 개발자에게 문의하세요.')
  end

  local extraPrompt = string.format([[# Interaction Mode

Note: User has requested interaction with last data block (<%s>). DISREGARD "NO REPEAT" DIRECTIVE. Keep the data intact.

User direction:
```
%s
```

Action: `%s`

%s]], man.identifier, direction, modifiers.action, interactionGuideline.content)

  local contextSlice = { table.unpack(fullChat, 1, idx) }
  local success, result = pcall(function()
    return runPipelineAsync(triggerId, man, contextSlice, {
      type = 'interaction',
      extras = extraPrompt
    }):await()
  end)

  -- Lua to JS index offset
  local jsIndex = idx - 1

  if not success then
    setChat(triggerId, jsIndex, originalContent)
    alertError(triggerId, "[LightBoard] 상호작용 실패. " .. identifier .. " 개발자에게 문의하세요.\n" .. tostring(result))
    return
  end

  if not result or result == '' or result == null then
    setChat(triggerId, jsIndex, originalContent)
    alertError(triggerId, "[LightBoard] 상호작용 불가. 모델 응답이 비어있거나 null입니다. 검열됐을 수 있습니다.")
    return
  end

  local finalChat

  if man.sideEffect then
    sideeffect.handleSideEffectResult(triggerId, {
      man = man,
      action = 'interaction',
      result = result,
      identifier = identifier,
      blockID = modifiers.blockID,
      onError = function(msg) alertError(triggerId, msg) end,
    })
    return
  elseif modifiers.preserve then
    -- Find last matching node and insert after it
    local existingNodes = prelude.queryNodes(identifier, originalContent)
    local targetNode = nil

    if modifiers.blockID and #existingNodes > 0 then
      for _, node in ipairs(existingNodes) do
        if node.attributes.id == modifiers.blockID then
          targetNode = node
          break
        end
      end
    elseif #existingNodes > 0 then
      targetNode = existingNodes[#existingNodes]
    end

    if targetNode then
      finalChat = originalContent:sub(1, targetNode.rangeEnd) ..
          '\n' .. result .. originalContent:sub(targetNode.rangeEnd + 1)
    else
      finalChat = lbdata.fallbackInsert(originalContent, result)
    end
  else
    -- Remove node and insert at its position
    local baseContent, targetPosition = removeNode(originalContent, identifier,
      modifiers.blockID and { id = modifiers.blockID } or nil)

    if targetPosition then
      finalChat = insertAtPosition(baseContent, targetPosition, result)
    else
      finalChat = lbdata.fallbackInsert(baseContent, result)
    end
  end

  if man.onMutation then
    finalChat = man.onMutation(triggerId, 'interaction', finalChat)
  end

  setChat(triggerId, jsIndex, finalChat)
end

onButtonClick = async(function(tid, code)
  setTriggerId(tid)

  local prefix = "lb%-reroll__"
  local _, rerollPrefixEnd = string.find(code, prefix)

  if rerollPrefixEnd then
    local fullIdentifier = code:sub(rerollPrefixEnd + 1)
    if fullIdentifier == "" then
      return
    end

    local hashPos = fullIdentifier:find("#", 1, true)
    local identifier, blockID
    if hashPos then
      identifier = fullIdentifier:sub(1, hashPos - 1)
      blockID = fullIdentifier:sub(hashPos + 1)
      if blockID == "" then
        blockID = nil
      end
    else
      identifier = fullIdentifier
      blockID = nil
    end

    local success, result = pcall(reroll, identifier, blockID)
    if not success then
      alertError(tid, "[LightBoard] 리롤 실패 (" .. identifier .. ").\n" .. tostring(result))
      return
    end

    removeChat(tid, -1)
    return
  end

  prefix = "lb%-interaction__"
  local _, interactionPrefixEnd = string.find(code, prefix)

  if interactionPrefixEnd then
    local body = code:sub(interactionPrefixEnd + 1)
    if body == "" then
      return
    end

    local firstSeparator = body:find("__", 1, true)
    if not firstSeparator then
      return
    end

    local identifier = body:sub(1, firstSeparator - 1)
    local action = body:sub(firstSeparator + 2)

    if identifier == "" or action == "" then
      return
    end

    local mode = getGlobalVar(tid, C.CONFIG.ACTIVE) or "0"
    if mode == "0" then
      alertNormal(tid, '[LightBoard] 상호작용 전에 백엔드를 활성화해주세요.')
      return
    end

    local modifiers = parseInteractionModifiers(action)

    print('[LightBoard Backend][VERBOSE] Interaction ' .. action .. ' of ' .. identifier .. ' initiated.')

    if modifiers.immediate then
      local message = [[---
[LBDATA START]
<lb-rerolling><div class="lb-pending lb-rerolling"><span class="lb-pending-note">%s 상호작용 중, 채팅을 보내거나 다른 작업을 하지 마세요...</span></div></lb-rerolling>
[LBDATA END]
---]]

      addChat(tid, 'user', message:format(identifier))

      local fullChat = getFullChat(tid)
      -- #fullChat = pending message, #fullChat-1 = last char chat to modify
      local success, result = pcall(interact, fullChat, identifier, action, "", -2)
      if not success then
        alertError(tid, "[LightBoard] 상호작용 실패 (" .. identifier .. ").\n" .. tostring(result))
        return
      end

      removeChat(tid, -1)
    else
      local message = [[---
[LBDATA START]
<lb-interaction-identifier>%s</lb-interaction-identifier>
<lb-interaction-action>%s</lb-interaction-action>
[LBDATA END]
---]]
      addChat(tid, 'user', message:format(identifier, action))
    end
  end
end)

--- Extracts interaction identifier and action from a chat message.
--- @param chatData string
--- @return string?, string?
local function extractInteraction(chatData)
  local identifierNode = prelude.extractNodes('lb-interaction-identifier', chatData)[1]
  local actionNode = prelude.extractNodes('lb-interaction-action', chatData)[1]

  local identifier = identifierNode and identifierNode.content
  local action = actionNode and actionNode.content

  if identifier and identifier ~= "" and action and action ~= "" then
    return identifier, action
  end
  return nil, nil
end

onStart = async(function(tid)
  local mode = getGlobalVar(tid, C.CONFIG.ACTIVE) or "0"
  if mode == "0" then
    return
  end

  setTriggerId(tid)

  local fullChat = getFullChat(tid)
  local lastChat = fullChat[#fullChat]
  local secondLastChat = fullChat[#fullChat - 1]

  -- Try: last chat is action (no direction)
  local identifier, action = extractInteraction(lastChat.data)
  if identifier then
    stopChat(tid)
    local success, result = pcall(interact, fullChat, identifier, action, '(User provided no direction.)')
    if success then
      removeChat(tid, -1)
    else
      alertError(tid, "[LightBoard] 상호작용 " .. identifier .. " 실패. 개발자에게 문의하세요.\n" .. tostring(result))
    end
    return
  end

  -- Try: second last is action, last is direction
  if not secondLastChat or secondLastChat.role ~= 'user' then
    return
  end

  identifier, action = extractInteraction(secondLastChat.data)
  if not identifier then
    return
  end

  local direction = lastChat.data
  if not direction or direction == "" then
    direction = '(User provided no direction.)'
  end

  stopChat(tid)

  local success, result = pcall(interact, fullChat, identifier, action, direction)
  if success then
    removeChat(tid, -2)
    removeChat(tid, -1)
  else
    alertError(tid, "[LightBoard] 상호작용 " .. identifier .. " 실패. 개발자에게 문의하세요.\n" .. tostring(result))
  end
end)

-- Extract LBDATA blocks, send as system messages
listenEdit(
  "editRequest",
  function(tid, data)
    if getGlobalVar(tid, C.CONFIG.SEND_AS_CHAR) == '1' then
      return data
    end

    setTriggerId(tid)

    for i = #data, 1, -1 do
      local msg = data[i]
      if msg.role == 'assistant' then
        local content = msg.content
        local pattern = "%-%-%-\n" .. C.LBDATA.PATTERN_START .. "(.-)" .. C.LBDATA.PATTERN_END .. "\n%-%-%-"

        local s, e, inner = string.find(content, pattern)

        if s then
          -- Remove the entire block from the original message
          msg.content = content:sub(1, s - 1) .. content:sub(e + 1)

          if inner then
            local trimmed = prelude.trim(inner)
            if trimmed and trimmed ~= "" then
              -- Insert new system message after the current message
              table.insert(data, i + 1,
                { role = "system", content = C.LBDATA.START .. '\n' .. trimmed .. '\n' .. C.LBDATA.END })
            end
          end
        end
      end
    end

    return data
  end
)

dangerouslyCleanseWholeChat = async(function(tid)
  setTriggerId(tid)

  local cleanseTarget = prelude.trim(alertInput(tid,
      '삭제할 태그의 이름만 입력하세요.\n<lightboard-module-alpha> => lightboard-module-alpha\n태그 이름은 편집 버튼을 눌러서 확인하세요.\n\n아무것도 입력하지 않으면 취소합니다.')
    :await())
  if not cleanseTarget or cleanseTarget == '' then
    return
  end

  local confirm = alertConfirm(tid,
    '주의: 되돌릴 수 없습니다. 최소한의 처리만 하므로 부작용이 있을 수도 있습니다.\n정말 <' .. cleanseTarget .. '> 태그를 모두 삭제하시겠습니까?'):await()
  if not confirm then
    return
  end

  confirm = alertConfirm(tid,
    '경고: 지금이라도 백업하세요. 오류가 발생해서 텍스트가 엉망이 되어도 되돌릴 수 없습니다.\n정말 <' .. cleanseTarget .. '> 태그를 모두 삭제하시겠습니까?'):await()
  if not confirm then
    return
  end

  local fullChat = getFullChat(tid)
  local cleansedChat = {}

  -- -1 = cleaner button
  for i = 1, #fullChat do
    local chat = fullChat[i]
    if chat.role == 'char' then
      local originalContent = chat.data
      local modifiedContent = originalContent

      while true do
        local newContent, _ = removeNode(modifiedContent, cleanseTarget)
        if newContent == modifiedContent then
          break
        end
        modifiedContent = newContent
      end
      chat.data = modifiedContent
    end
    table.insert(cleansedChat, chat)
  end

  setFullChat(tid, cleansedChat)
  reloadDisplay(tid)

  alertNormal(tid, '⌛ 정리 완료.')
end)
