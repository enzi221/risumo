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

---Strips all XML nodes from text, returning stripped text and a restore function.
---@param text string
---@return string stripped
---@return fun(s: string): string restore
local function stripXMLNodes(text)
  local saved = {}
  local sections = {}
  local position = 1

  while true do
    local tagStart = text:find("<", position)
    if not tagStart then break end

    local tagEnd = text:find(">", tagStart)
    if not tagEnd then
      position = tagStart + 1
    else
      local openTagContent = text:sub(tagStart + 1, tagEnd - 1)
      local foundTagName = openTagContent:match("^([%w%-%_]+)")

      if not foundTagName then
        position = tagEnd + 1
      else
        local isSelfClosing = openTagContent:match("/%s*$")

        if isSelfClosing then
          local idx = #saved + 1
          saved[idx] = text:sub(tagStart, tagEnd)
          sections[#sections + 1] = { start = tagStart, finish = tagEnd, idx = idx }
          position = tagEnd + 1
        else
          local closePattern = "</" .. prelude.escMatch(foundTagName) .. ">"
          local closeStart, closeEnd = text:find(closePattern, tagEnd)

          if not closeStart then
            position = tagEnd + 1
          else
            local idx = #saved + 1
            saved[idx] = text:sub(tagStart, closeEnd)
            sections[#sections + 1] = { start = tagStart, finish = closeEnd, idx = idx }
            position = closeEnd + 1
          end
        end
      end
    end
  end

  if #sections == 0 then
    return text, function(s) return s end
  end

  local parts = {}
  local lastPos = 1

  for _, section in ipairs(sections) do
    parts[#parts + 1] = text:sub(lastPos, section.start - 1)
    parts[#parts + 1] = '\0XMLR_' .. section.idx .. '\0'
    lastPos = section.finish + 1
  end

  parts[#parts + 1] = text:sub(lastPos)

  local stripped = table.concat(parts)

  local function restore(s)
    return (s:gsub('\0XMLR_(%d+)\0', function(i)
      return saved[tonumber(i)]
    end))
  end

  return stripped, restore
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

    local stripped, restoreNodes = stripXMLNodes(fullChatContent)
    local slotted = gen.insertSlots(stripped)

    for _, scene in ipairs(response.scenes or {}) do
      local slot = tostring(scene.slot)
      if inlays[slot] then
        slotted = slotted:gsub('%[Slot%s+' .. slot .. '%]',
          '<lb-xnai scene="' .. slot .. '">' .. inlays[slot] .. '</lb-xnai>')
      else
        slotted = slotted:gsub('%[Slot%s+' .. slot .. '%]',
          '<lb-xnai scene="' .. slot .. '" />')
      end
    end

    -- remove unreplaced [Slot #] tags
    slotted = slotted:gsub('\n%[Slot%s+%d+%]\n', '')
    slotted = restoreNodes(slotted)
    setState(triggerId, 'lb-xnai-stack', xnaiState)

    if inlays['-1'] then
      return slotted .. '\n\n<lb-xnai kv>' .. inlays['-1'] .. '</lb-xnai>', '<lb-lazy id="lb-xnai" />'
    end

    return slotted .. '\n\n<lb-xnai kv />', '<lb-lazy id="lb-xnai" />'
  end

  return nil, '<lb-lazy id="lb-xnai" />'
end

return onOutput
