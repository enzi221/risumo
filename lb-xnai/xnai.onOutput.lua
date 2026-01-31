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

function onOutput(tid, output)
  setTriggerId(tid)

  if not string.find(output, '<lb%-xnai') then
    return nil
  end

  if not string.find(output, '</lb%-xnai>') then
    output = output .. '\n</lb-xnai>'
  end

  local nodes = prelude.queryNodes('lb-xnai', output)
  if #nodes == 0 then
    return prelude.removeAllNodes(output, { 'lb-xnai' })
  end

  ---@type XNAIGen
  local gen = prelude.import(triggerId, 'lb-xnai.gen')
  local fullChat = getFullChat(triggerId)
  local targetIndex = gen.locateTargetChat(fullChat)

  if targetIndex then
    local node = nodes[#nodes]
    local success, xnaiData = pcall(prelude.toon.decode, node.content)

    if success then
      ---@type XNAIState
      local xnaiState = getState(triggerId, 'lb-xnai-data') or {}
      local stack = xnaiState.stack or {}

      local newList = {}
      for _, item in ipairs(stack) do
        if item.chatIndex < targetIndex then
          table.insert(newList, item)
        end
      end

      if getGlobalVar(triggerId, 'toggle_lb-xnai.generation') == '0' then
        ---@type { generate: fun (triggerId: string, desc: XNAIDescriptor): string? }
        local gen = prelude.import(triggerId, 'lb-xnai.gen')

        if xnaiData.keyvis then
          local ok, inlay = pcall(gen.generate, triggerId, xnaiData.keyvis)
          if ok then
            xnaiData.keyvis.inlay = inlay
          end
        end

        for _, desc in ipairs(xnaiData.scenes or {}) do
          local ok, inlay = pcall(gen.generate, triggerId, desc)
          if ok then
            desc.inlay = inlay
          end
        end
      end

      table.insert(newList, {
        xnai = xnaiData,
        chatIndex = targetIndex,
      })

      local maxSaves = tonumber(getGlobalVar(triggerId, 'toggle_lb-xnai.maxSaves')) or 5
      while #newList > maxSaves do
        table.remove(newList, 1)
      end

      xnaiState.stack = newList

      setState(triggerId, 'lb-xnai-data', {
        pinned = xnaiState.pinned or {},
        stack = newList,
      })
      reloadChat(triggerId, targetIndex)
    end
  end

  return '<lb-xnai of="' .. targetIndex .. '">\n' .. nodes[#nodes].content .. '\n</lb-xnai>'
end

return onOutput
