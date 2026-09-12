local function fail(message)
  error('InvalidOutput: ' .. message, 0)
end

local function loadValue(triggerId, name)
  local book = prelude.getPriorityLoreBook(triggerId, name)
  if not book or prelude.trim(book.content or '') == '' then
    return nil
  end
  local chunk, reason = load(book.content, '@' .. name, 't')
  if not chunk then
    error(reason)
  end
  return chunk()
end

local function openblocks(triggerId)
  local result = {}
  if getGlobalVar(triggerId, 'toggle_lb-minitalk.openblock') ~= '1' then
    return result
  end
  for _, book in ipairs(getLoreBooks(triggerId, 'lb-minitalk.openblock') or {}) do
    local identifier, description = prelude.trim(book.content or ''):match('^identifier=([%w_-]+)%s*\n(.+)$')
    if identifier and not result[identifier] then
      local success, extension = pcall(loadValue, triggerId, 'lb-minitalk.openblock.' .. identifier)
      if success and type(extension) == 'table'
          and type(extension.render) == 'function' and type(extension.validate) == 'function' then
        result[identifier] = {
          description = description,
          render = extension.render,
          validate = extension.validate,
        }
      end
    end
  end
  return result
end

local function conIdentifier(content)
  if type(content) == 'string' and content:match('^[%w._/%-]+$') then
    return content
  end
  return nil
end

local function object(value, fields)
  if type(value) ~= 'table' then
    fail('Expected an object.')
  end
  for key in pairs(value) do
    if not fields[key] then
      fail('Unexpected field: ' .. tostring(key))
    end
  end
  for key, expected in pairs(fields) do
    if type(value[key]) ~= expected then
      fail(key .. ' must be a ' .. expected .. '.')
    end
  end
end

local function array(value)
  if type(value) ~= 'table' then
    fail('Expected an array.')
  end
  local count = 0
  for key in pairs(value) do
    if type(key) ~= 'number' or key < 1 or key % 1 ~= 0 then
      fail('Expected an array.')
    end
    count = count + 1
  end
  if count ~= #value then
    fail('Array must not contain gaps.')
  end
end

local function validateSource(content)
  local seen = {}
  local section
  local rows = 0
  local expected = 0
  local columns = 0
  local function finish()
    if section and rows ~= expected then
      fail(section .. ' array length does not match its rows.')
    end
  end
  for rawLine in (content .. '\n'):gmatch('(.-)\n') do
    local line = rawLine:gsub('\r$', ''):gsub('⇥', '  ')
    if prelude.trim(line) ~= '' then
      if line:sub(1, 1) ~= ' ' then
        finish()
        section = nil
        local key = line:match('^([%w]+)')
        if not key or seen[key] then
          fail('Invalid or repeated room field.')
        end
        seen[key] = true
        if key == 'keyFigures' or key == 'messages' or key == 'participants' then
          local count, fields = line:match('^[%w]+%[(%d+)|%](.-):%s*$')
          local wanted
          if key == 'keyFigures' then
            wanted = '{keyFigure|nickname|note}'
          elseif key == 'messages' then
            wanted = '{sender|type|time|content}'
          else
            wanted = '{id|name}'
          end
          if not count or (fields ~= wanted and not (count == '0' and fields == '')) then
            fail('Invalid ' .. key .. ' table header.')
          end
          section = key
          expected = tonumber(count)
          rows = 0
          if key == 'keyFigures' then
            columns = 3
          elseif key == 'messages' then
            columns = 4
          else
            columns = 2
          end
        elseif (key ~= 'name' and key ~= 'pov') or not line:match('^[%w]+:%s*%S') then
          fail('Unexpected room field.')
        end
      else
        if not section or not line:match('^  %S') or line:match('^  %- ') then
          fail('Table rows require exactly two spaces and no list marker.')
        end
        local quoted = false
        local escaped = false
        local count = 1
        for index = 3, #line do
          local character = line:sub(index, index)
          if escaped then
            escaped = false
          elseif character == '\\' and quoted then
            escaped = true
          elseif character == '"' then
            quoted = not quoted
          elseif character == '|' and not quoted then
            count = count + 1
          end
        end
        if quoted or escaped or count ~= columns then
          fail('Invalid quoting or column count in ' .. section .. '.')
        end
        rows = rows + 1
      end
    end
  end
  finish()
end

local function validateKeyFigures(entries)
  array(entries)
  for _, entry in ipairs(entries) do
    object(entry, { keyFigure = 'string', nickname = 'string', note = 'string' })
    if prelude.trim(entry.keyFigure) == '' or prelude.trim(entry.nickname) == '' then
      fail('Each key figure needs nonempty keyFigure and nickname strings plus a note string.')
    end
  end
  return entries
end

local function validateData(triggerId, data, generation)
  object(data, {
    keyFigures = 'table',
    messages = 'table',
    name = 'string',
    participants = 'table',
    pov = 'string',
  })
  validateKeyFigures(data.keyFigures)
  array(data.messages)
  array(data.participants)
  if prelude.trim(data.name) == '' or #data.participants < 2 or #data.participants > 10 then
    fail('A room needs a name and two to ten participants.')
  end
  local participants = {}
  for _, participant in ipairs(data.participants) do
    object(participant, { id = 'string', name = 'string' })
    if not participant.id:match('^[%w_-]+$') or prelude.trim(participant.name) == ''
        or participants[participant.id] then
      fail('Participants need unique safe IDs and nonempty names.')
    end
    participants[participant.id] = participant.name
  end
  if not participants[data.pov] then
    fail('pov must reference a participant.')
  end
  if generation then
    local room = getGlobalVar(triggerId, 'toggle_lb-minitalk.room')
    if (room == '1' and #data.participants ~= 2) or (room == '2' and #data.participants < 3) then
      fail('Participant count does not match the room setting.')
    end
  end
  local extensions = openblocks(triggerId)
  for _, message in ipairs(data.messages) do
    object(message, { content = 'string', sender = 'string', time = 'string', type = 'string' })
    if message.type == 'pause' then
      if message.sender ~= '-' or message.time ~= '-' or prelude.trim(message.content) == '' then
        fail('A pause needs - in sender and time plus nonempty content.')
      end
    elseif message.type == 'skip' then
      if message.sender ~= '-' or message.time ~= '-' or message.content ~= '-' then
        fail('A skip needs - in sender, time, and content.')
      end
    elseif message.type == 'invited' or message.type == 'exit' then
      if message.sender ~= '-' or prelude.trim(message.time) == '' or not participants[message.content] then
        fail('A membership event needs - in sender, a time, and a participant ID in content.')
      end
    elseif not participants[message.sender] or prelude.trim(message.time) == '' or message.content == '' then
      fail('Messages need a known sender, time, and nonempty content.')
    end
    if message.type == 'pause' or message.type == 'skip' then
    elseif message.type == 'invited' or message.type == 'exit' then
    elseif message.type == 'text' then
    elseif message.type == 'con' then
      if not conIdentifier(message.content) then
        fail('A con message needs exactly one safe MiniCon identifier.')
      end
    else
      local identifier = message.type:match('^openblock:([%w_-]+)$')
      if not identifier then
        fail('Unknown message type: ' .. message.type)
      end
      local extension = extensions[identifier]
      if generation and not extension then
        fail('OpenBlock is disabled or unavailable: ' .. identifier)
      end
      if extension then
        local valid, reason = pcall(extension.validate, triggerId, message.content)
        if not valid or reason == false then
          fail('Invalid OpenBlock ' .. identifier .. ': ' .. tostring(reason))
        end
      end
    end
  end
  return data, extensions
end

local function decode(triggerId, content, generation)
  validateSource(content)
  prelude.import(triggerId, 'toon.decode')
  local success, data = pcall(prelude.toon.decode, content)
  if not success then
    fail('Invalid TOON: ' .. tostring(data))
  end
  if data.keyFigures == nil then
    local preserved = getChatVar(triggerId, 'lb-minitalk.keyfigures')
    if type(preserved) == 'string' and prelude.trim(preserved) ~= '' and preserved ~= 'null' then
      local decoded, entries = pcall(prelude.toon.decode, preserved)
      data.keyFigures = decoded and type(entries) == 'table' and entries or {}
    else
      data.keyFigures = {}
    end
  end
  return validateData(triggerId, data, generation)
end

local function encode(triggerId, data)
  prelude.import(triggerId, 'toon.encode')
  local messages = {}
  for _, message in ipairs(data.messages) do
    table.insert(messages, setmetatable({
      content = message.content,
      sender = message.sender,
      time = message.time,
      type = message.type,
    }, { __toonKeyOrder = { 'sender', 'type', 'time', 'content' } }))
  end
  local participants = {}
  for _, participant in ipairs(data.participants) do
    table.insert(participants, setmetatable({
      id = participant.id,
      name = participant.name,
    }, { __toonKeyOrder = { 'id', 'name' } }))
  end
  local room = {
    messages = #messages > 0 and messages or nil,
    name = data.name,
    participants = participants,
    pov = data.pov,
  }
  local prefix = ''
  if #messages == 0 then
    prefix = prefix .. 'messages[0|]:\n'
  end
  return '<lb-minitalk>\n' .. prefix .. prelude.toon.encode(room, { delimiter = '|' }) .. '\n</lb-minitalk>'
end

local function validatePatch(patch)
  if type(patch) ~= 'table' then
    error('InvalidOutput: <lb-minitalk-patch> must contain a JSON array.')
  end

  local operationCount = 0
  for key in pairs(patch) do
    if type(key) ~= 'number' or key < 1 or key % 1 ~= 0 then
      error('InvalidOutput: <lb-minitalk-patch> must contain a JSON array.')
    end
    operationCount = operationCount + 1
  end

  if operationCount ~= #patch then
    error('InvalidOutput: JSON Patch array must not contain gaps.')
  end

  for _, operation in ipairs(patch) do
    if type(operation) ~= 'table' then
      error('InvalidOutput: Each JSON Patch operation must be an object.')
    end
    if operation.op ~= 'add' and operation.op ~= 'remove' and operation.op ~= 'replace' then
      error('InvalidOutput: JSON Patch op must be add, remove, or replace.')
    end
    if type(operation.path) ~= 'string' then
      error('InvalidOutput: Each JSON Patch operation requires a string path.')
    end
    if operation.path ~= '' and operation.path:sub(1, 1) ~= '/' then
      error('InvalidOutput: JSON Patch paths must be empty or begin with /.')
    end
    if operation.path:find('~[^01]') or operation.path:sub(-1) == '~' then
      error('InvalidOutput: JSON Patch path contains an invalid escape.')
    end
    if operation.op == 'remove' and operation.path == '' then
      error('InvalidOutput: Removing the room root is not supported.')
    end
    if operation.op ~= 'remove' and rawget(operation, 'value') == nil then
      error('InvalidOutput: JSON Patch add and replace operations require value.')
    end
  end
end

local function patch(output)
  local nodes = prelude.queryNodes('lb-minitalk-patch', output)
  if #nodes == 0 then
    return nil
  end
  local node = nodes[#nodes]
  local success, operations = pcall(json.decode, prelude.trim(node.content))
  if not success then
    fail('Invalid JSON Patch: ' .. tostring(operations))
  end
  validatePatch(operations)
  return operations, node
end

local function extract(output)
  local nodes = prelude.queryNodes('lb-minitalk', output)
  if #nodes == 0 then
    fail('Missing a complete <lb-minitalk> element.')
  end
  return nodes[#nodes]
end

local function preserveKeyFigures(triggerId, entries)
  if #entries == 0 then
    return
  end

  prelude.import(triggerId, 'toon.decode')
  prelude.import(triggerId, 'toon.encode')
  local preserved = getChatVar(triggerId, 'lb-minitalk.keyfigures')
  local keyFigures = {}
  local indices = {}
  local function merge(entry)
    local index = indices[entry.keyFigure]
    if index then
      keyFigures[index] = entry
    else
      table.insert(keyFigures, entry)
      indices[entry.keyFigure] = #keyFigures
    end
  end
  if type(preserved) == 'string' and prelude.trim(preserved) ~= '' and preserved ~= 'null' then
    local success, decoded = pcall(prelude.toon.decode, preserved)
    if success and type(decoded) == 'table' then
      for _, entry in ipairs(decoded) do
        merge(entry)
      end
    end
  end

  for _, entry in ipairs(entries) do
    merge(entry)
  end

  local content = prelude.toon.encode(keyFigures, { delimiter = '|' })
  if preserved ~= content then
    setChatVar(triggerId, 'lb-minitalk.keyfigures', content)
  end
end

return {
  conIdentifier = conIdentifier,
  decode = decode,
  encode = encode,
  extract = extract,
  loadValue = loadValue,
  openblocks = openblocks,
  patch = patch,
  preserveKeyFigures = preserveKeyFigures,
  validateData = validateData,
}
