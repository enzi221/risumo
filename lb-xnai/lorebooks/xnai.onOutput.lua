local function info(tid, ...)
  prelude.info(tid, 'lb-xnai.onOutput', ...)
end

local function verbose(tid, ...)
  prelude.verbose(tid, 'lb-xnai.onOutput', ...)
end

---@param text string
---@param slot string
---@param replacement string
---@param gen XNAIGen
---@return string
---@return boolean replaced
---@return number availableSlots
local function replaceSceneNode(tid, text, slot, replacement, gen)
  local nodes = prelude.queryNodes('lb-xnai', text, { scene = slot })
  if #nodes > 0 then
    local node = nodes[1]
    return table.concat({
      text:sub(1, node.rangeStart - 1),
      replacement,
      text:sub(node.rangeEnd + 1),
    }), true, 0
  end

  local _, slotted, restoreNodes = gen.buildContextSlotMap(tid, text)
  local _, availableSlots = slotted:gsub('%[Slot%s+%d+%]', '')
  local replacementCount
  slotted, replacementCount = slotted:gsub('%[Slot%s+' .. slot .. '%]', function()
    return replacement
  end, 1)
  slotted = slotted:gsub('%[Slot%s+%d+%]\n\n', '')
  return restoreNodes(slotted), replacementCount > 0, availableSlots
end

---@param tid string
---@param response XNAIResponse
---@param fullChatContent string
---@param index number
---@param gen XNAIGen
---@return string?, string?
local function applyInteraction(tid, response, fullChatContent, index, gen)
  local scene = response.scenes and response.scenes[1]
  if not scene then
    verbose(tid, 'Interaction ignored because no scene was returned.')
    return nil, '<lb-lazy id="lb-xnai" />'
  end

  local slot = tostring(scene.slot)
  info(tid, 'Applying interaction. chatIndex=' .. tostring(index) .. ', slot=' .. tostring(slot))
  scene.slot = tonumber(slot)
  local xnaiState = getState(tid, 'lb-xnai-stack') or {}
  if type(xnaiState) ~= 'table' then
    return nil, '<lb-lazy id="lb-xnai" />'
  end

  local stackItem = nil
  for _, item in ipairs(xnaiState) do
    if item.chatIndex == index then
      stackItem = item
      break
    end
  end
  if not stackItem then
    return nil, '<lb-lazy id="lb-xnai" />'
  end

  local _, replaceable, availableSlots = replaceSceneNode(tid, fullChatContent, slot, '', gen)
  if not replaceable then
    error('Interaction scene insertion unavailable. slot=' .. tostring(slot) ..
      ', availableSlots=' .. tostring(availableSlots))
  end

  local operationID = stackItem.operationID or tid
  stackItem.data.scenes[slot] = scene
  gen.persistStateAndHistory(tid, xnaiState)

  local inlay = nil
  if getGlobalVar(tid, 'toggle_lb-xnai.generation') == '0' then
    local success, generated = pcall(gen.generate, tid, scene)
    if success then
      inlay = generated
    else
      info(tid, 'Interaction image generation failed. error=' .. tostring(generated))
    end
  end

  local replacement
  if inlay then
    replacement = table.concat({
      '<lb-xnai id="scene-', slot, '" operation="', operationID, '" scene="', slot, '">',
      inlay,
      '</lb-xnai>',
    })
  else
    replacement = table.concat({
      '<lb-xnai id="scene-', slot, '" operation="', operationID, '" scene="', slot, '" />',
    })
  end

  local replacedText, replaced, availableSlots = replaceSceneNode(tid, fullChatContent, slot, replacement, gen)
  if not replaced then
    info(tid, 'Interaction scene insertion failed. slot=' .. tostring(slot) ..
      ', availableSlots=' .. tostring(availableSlots))
  end
  return replacedText, nil
end

---@param tid string
---@param output string
---@param fullChatContent string
---@param index number
local function main(tid, output, fullChatContent, index)
  local forcedInsertion = getGlobalVar(tid, 'toggle_lb-xnai.forcedinsertion') == '1'
  verbose(tid, 'Processing output. chatIndex=' .. tostring(index) .. ', forcedInsertion=' .. tostring(forcedInsertion))
  if forcedInsertion then
    output = output:gsub('%%', '')
    output = output:gsub('wfsn', 'nsfw')
  end

  if not string.find(output, '<lb%-xnai') then
    return nil
  end

  if not string.find(output, '</lb%-xnai>') then
    output = output .. '\n</lb-xnai>'
  end

  local nodes = prelude.queryNodes('lb-xnai', output)
  verbose(tid, 'Output nodes found. count=' .. tostring(#nodes))

  ---@type XNAIGen
  local gen = prelude.import(tid, 'lb-xnai.gen')

  local node = nodes[#nodes]
  local cleanedContent = gen.cleanDescriptionBlocks(node.content)
  local success, xnaiData = pcall(prelude.toon.decode, cleanedContent)

  if success then
    ---@type XNAIResponse
    local response = xnaiData
    info(tid, 'Output decoded. keyvis=' .. tostring(response.keyvis ~= nil) ..
      ', scenes=' .. tostring(#(response.scenes or {})))
    if response.interaction == true then
      return applyInteraction(tid, response, fullChatContent, index, gen)
    end

    local _, slotted, restoreNodes = gen.buildContextSlotMap(tid, fullChatContent)
    local _, availableSlots = slotted:gsub('%[Slot%s+%d+%]', '')
    verbose(tid, 'Slot map built. availableSlots=' .. tostring(availableSlots))
    local slotErrors = gen.validateSceneSlots(tid, response.scenes, slotted)
    if #slotErrors > 0 then
      error('Scene insertion unavailable. ' .. table.concat(slotErrors, '\n'))
    end

    ---@type XNAIStackItem[]
    local xnaiState = getState(tid, 'lb-xnai-stack') or {}
    if type(xnaiState) ~= 'table' then
      xnaiState = {}
    else
      -- prevent duplicate chat index happening caused by rerolls
      for i = #xnaiState, 1, -1 do
        if xnaiState[i].chatIndex == index then
          table.remove(xnaiState, i)
          break
        end
      end
    end

    ---@type XNAIStackItem
    local stackItem = {
      chatIndex = index,
      data = {
        keyvis = response.keyvis,
        scenes = {},
      },
      operationID = tid,
    }

    local shouldGenerateNow = getGlobalVar(tid, 'toggle_lb-xnai.generation') == '0'
    verbose(tid, 'Automatic image generation=' .. tostring(shouldGenerateNow))

    ---@type table<string, string>
    local inlays = {}

    if shouldGenerateNow then
      if response.keyvis then
        local ok, inlay = pcall(gen.generate, tid, response.keyvis)
        if ok and inlay then
          inlays['-1'] = inlay
        elseif not ok then
          info(tid, 'Key visual generation failed. error=' .. tostring(inlay))
        end
      end
    end

    for _, scene in ipairs(response.scenes or {}) do
      local slot = tostring(scene.slot)
      stackItem.data.scenes[slot] = scene
      if shouldGenerateNow then
        local ok, inlay = pcall(gen.generate, tid, scene)
        if ok and inlay then
          inlays[slot] = inlay
        elseif not ok then
          info(tid, 'Scene generation failed. slot=' .. slot .. ', error=' .. tostring(inlay))
        end
      end
    end

    table.insert(xnaiState, stackItem)
    xnaiState = select(1, gen.persistStateAndHistory(tid, xnaiState))

    for _, scene in ipairs(response.scenes or {}) do
      local slot = tostring(scene.slot)
      local replacement
      if inlays[slot] then
        replacement = '<lb-xnai id="scene-' .. slot .. '" operation="' .. tid .. '" scene="' .. slot .. '">' ..
            inlays[slot] .. '</lb-xnai>'
      else
        replacement = '<lb-xnai id="scene-' .. slot .. '" operation="' .. tid .. '" scene="' .. slot .. '" />'
      end

      local replacementCount
      slotted, replacementCount = slotted:gsub('%[Slot%s+' .. slot .. '%]', function()
        return replacement
      end, 1)
      if replacementCount == 0 then
        info(tid, 'Scene insertion failed. slot=' .. slot .. ', availableSlots=' .. tostring(availableSlots))
      else
        verbose(tid, 'Scene inserted. slot=' .. slot)
      end
    end

    -- remove unreplaced [Slot #] tags
    slotted = slotted:gsub('%[Slot%s+%d+%]\n\n', '')
    slotted = restoreNodes(slotted)

    local finalOutput
    if inlays['-1'] then
      finalOutput = slotted .. '\n\n<lb-xnai id="keyvis" kv operation="' .. tid .. '">' ..
          inlays['-1'] .. '</lb-xnai>'
    else
      finalOutput = slotted .. '\n\n<lb-xnai id="keyvis" kv operation="' .. tid .. '" />'
    end

    verbose(tid, 'Output composition completed. length=' .. tostring(#finalOutput))
    return finalOutput, '<lb-lazy id="lb-xnai" />'
  end

  verbose(tid, 'Output decoding failed. error=' .. tostring(xnaiData))

  return nil, '<lb-lazy id="lb-xnai" />'
end

return main
