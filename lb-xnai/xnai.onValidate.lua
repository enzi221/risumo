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

function onValidate(triggerId, output)
  setTriggerId(triggerId)

  local node = prelude.queryNodes('lb-xnai', output)
  if #node == 0 then
    return
  end

  local success, content = pcall(prelude.toon.decode, node[#node].content)
  if not success then
    error('InvalidOutput: Invalid TOON format. ' .. tostring(content))
  end

  --- @type XNAIResponse
  local response = content
  local errors = {}

  for index, desc in ipairs(response.scenes or {}) do
    local errIndex = index - 1

    if not desc.camera or type(desc.camera) ~= 'string' or desc.camera == '' then
      table.insert(errors, 'Scene ' .. errIndex .. ' has no camera field. Parsed type: ' .. type(desc.camera))
    end
    if not desc.characters or type(desc.characters) ~= 'table' or #desc.characters == 0 then
      table.insert(errors,
        'Scene ' .. errIndex .. ' has no character or is not a valid array. Parsed type: ' .. type(desc.characters))
    end
    for cIndex, character in ipairs(desc.characters) do
      local charErrIndex = cIndex - 1
      if type(character) ~= 'table' then
        table.insert(errors,
          'Scene ' .. errIndex .. ', character ' .. charErrIndex .. ' is not a valid object. Parsed type: ' .. type(character))
      end
      if type(character.positive) ~= 'string' or character.positive == '' then
        table.insert(errors,
          'Scene ' ..
          errIndex .. ', character ' .. charErrIndex .. ' (positive) is empty or not a valid string. Parsed type: ' .. type(character.positive))
      end
      if character.negative and type(character.negative) ~= 'string' then
        table.insert(errors,
          'Scene ' ..
          errIndex .. ', character ' .. charErrIndex .. ' (negative) is not a valid string. Parsed type: ' .. type(character.negative))
      end
    end
    if not desc.scene or type(desc.scene) ~= 'string' or desc.scene == '' then
      table.insert(errors, 'Scene ' .. errIndex .. ' has no scene field. Parsed type: ' .. type(desc.scene))
    end
    if not desc.slot or type(desc.slot) ~= 'number' then
      table.insert(errors, 'Scene ' .. errIndex .. ' has invalid slot field. Parsed type: ' .. type(desc.slot))
    end
  end

  if not response.keyvis then
    table.insert(errors, 'Keyvis data is missing.')
  else
    if not response.keyvis.camera or type(response.keyvis.camera) ~= 'string' or response.keyvis.camera == '' then
      table.insert(errors, 'Keyvis has no camera field. Parsed type: ' .. type(response.keyvis.camera))
    end
    if not response.keyvis.scene or type(response.keyvis.scene) ~= 'string' or response.keyvis.scene == '' then
      table.insert(errors, 'Keyvis has no scene field. Parsed type: ' .. type(response.keyvis.scene))
    end

    for cIndex, character in ipairs(response.keyvis) do
      local charErrIndex = cIndex - 1
      if type(character) ~= 'table' then
        table.insert(errors,
          'Keyvis character ' .. charErrIndex .. ' is not a valid object. Parsed type: ' .. type(character))
      end
      if type(character.positive) ~= 'string' or character.positive == '' then
        table.insert(errors,
          'Keyvis character ' .. charErrIndex .. ' (positive) is empty or not a valid string. Parsed type: ' .. type(character.positive))
      end
      if character.negative and type(character.negative) ~= 'string' then
        table.insert(errors,
          'Keyvis character ' .. charErrIndex .. ' (negative) is not a valid string. Parsed type: ' .. type(character.negative))
      end
    end
  end

  if #errors > 0 then
    error('InvalidOutput: Malformed data. Aggregated errors:\n\n' .. table.concat(errors, '\n'))
  end
end

return onValidate
