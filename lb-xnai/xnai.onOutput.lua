local triggerId = ''

local function setTriggerId(tid)
  triggerId = tid
  if type(prelude) ~= 'nil' then
    prelude.import(triggerId, 'toon.decode')
    return
  end
  local source = getLoreBooks(triggerId, 'lightboard-prelude')
  if not source or #source == 0 then
    error('Failed to load lightboard-prelude.')
  end
  load(source[1].content, '@prelude', 't')()

  prelude.import(triggerId, 'toon.decode')
end

---@param tid string
---@param output string
---@param fullChatContent string
---@param index number
function onOutput(tid, output, fullChatContent, index)
  setTriggerId(tid)

  if not string.find(output, '<lb%-xnai') then
    return nil
  end

  if not string.find(output, '</lb%-xnai>') then
    output = output .. '\n</lb-xnai>'
  end

  local nodes = prelude.queryNodes('lb-xnai', output)

  ---@type XNAIGen
  local gen = prelude.import(triggerId, 'lb-xnai.gen')

  local node = nodes[#nodes]
  local success, xnaiData = pcall(prelude.toon.decode, node.content)

  if success then
    ---@type XNAIResponse
    local response = xnaiData
    ---@type XNAIStackItem[]
    local xnaiState = getState(triggerId, 'lb-xnai-stack') or {}
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
      }
    }

    local shouldGenerateNow = getGlobalVar(triggerId, 'toggle_lb-xnai.generation') == '0'

    ---@type table<string, string>
    local inlays = {}

    if shouldGenerateNow then
      if response.keyvis then
        local ok, inlay = pcall(gen.generate, triggerId, response.keyvis)
        if ok and inlay then
          inlays['-1'] = inlay
        end
      end
    end

    for _, scene in ipairs(response.scenes or {}) do
      local slot = tostring(scene.slot)
      stackItem.data.scenes[slot] = scene
      if shouldGenerateNow then
        local ok, inlay = pcall(gen.generate, triggerId, scene)
        if ok and inlay then
          inlays[slot] = inlay
        end
      end
    end

    table.insert(xnaiState, stackItem)

    local maxSaves = tonumber(getGlobalVar(triggerId, 'toggle_lb-xnai.maxSaves')) or 3
    while #xnaiState > maxSaves do
      table.remove(xnaiState, 1)
    end

    local slotted = gen.insertSlots(fullChatContent)

    for _, scene in ipairs(response.scenes or {}) do
      local slot = tostring(scene.slot)
      if inlays[slot] then
        slotted = slotted:gsub(table.concat({ '%[Slot%s+', slot, '%]' }),
          table.concat({ '<lb-xnai scene="', slot, '">', inlays[slot], '</lb-xnai>' }))
      else
        slotted = slotted:gsub(table.concat({ '%[Slot%s+', slot, '%]' }),
          table.concat({ '<lb-xnai scene="', slot, '" />' }))
      end
    end

    -- remove unreplaced [Slot #] tags
    slotted = slotted:gsub('\n%[Slot%s+%d+%]\n', '')
    setState(triggerId, 'lb-xnai-stack', xnaiState)

    if inlays['-1'] then
      return slotted, table.concat({ '<lb-xnai kv>', inlays['-1'], '</lb-xnai>' })
    end

    return slotted, '<lb-xnai kv />'
  end

  return nil, '<lb-lazy id="lb-xnai" />'
end

return onOutput
