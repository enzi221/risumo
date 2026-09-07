local function fail(message)
  error('InvalidOutput: ' .. message, 0)
end

local function requireStrings(value, fields, label)
  if type(value) ~= 'table' or value == null then
    fail(label .. ' must be an object.')
  end
  for _, field in ipairs(fields) do
    if type(value[field]) ~= 'string' then
      fail(label .. '.' .. field .. ' must be a string.')
    end
  end
end

local function validateState(data)
  requireStrings(data, { 'comment', 'history' }, 'stage')
  local knownKeys = {
    comment = true,
    divergence = true,
    drive = true,
    episodes = true,
    history = true,
    objective = true,
    phase = true,
  }
  for key in pairs(data) do
    if not knownKeys[key] then
      fail('Unknown stage key "' .. tostring(key) .. '".')
    end
  end
  requireStrings(data.objective, { 'title', 'content', 'completion' }, 'objective')
  requireStrings(data.phase, { 'title', 'content', 'stage' }, 'phase')
  if not ({ cooldown = true, epilogue = true, main = true })[data.phase.stage] then
    fail('Invalid phase stage.')
  end
  if type(data.episodes) ~= 'table' or data.episodes == null then
    fail('episodes must be an array.')
  end
  local count = 0
  for key in pairs(data.episodes) do
    if type(key) ~= 'number' or key < 1 or key % 1 ~= 0 then
      fail('episodes must be an array.')
    end
    count = count + 1
  end
  if count ~= #data.episodes then
    fail('episodes must not contain gaps.')
  end
  local ongoing = 0
  for _, episode in ipairs(data.episodes) do
    requireStrings(episode, { 'content', 'stage', 'state', 'title' }, 'episode')
    if not ({ climax = true, conclusion = true, fall = true, introduction = true, rise = true })[episode.stage] then
      fail('Invalid episode stage.')
    end
    if not ({ done = true, ongoing = true, pending = true, skipped = true })[episode.state] then
      fail('Invalid episode state.')
    end
    if episode.state == 'ongoing' then
      ongoing = ongoing + 1
    end
  end
  if ongoing > 1 then
    fail('Only one episode may be ongoing.')
  end
  if data.drive ~= nil then
    requireStrings(data.drive, { 'attempt', 'belief_gap', 'desire', 'resistance' }, 'drive')
  end
  return data
end

local function previousState(triggerId)
  local chats = getRecentChats(triggerId, getChatLength(triggerId))
  local decodeInput = prelude.import(triggerId, 'lb-stage.lb.onInput')
  for index = #chats, 1, -1 do
    local nodes = prelude.queryNodes('lb-stage', chats[index].data)
    if #nodes > 0 then
      local decoded = decodeInput(triggerId, '<lb-stage>' .. nodes[#nodes].content .. '</lb-stage>')
      local node = prelude.queryNodes('lb-stage', decoded)[1]
      return prelude.toon.decode(node.content)
    end
  end
  fail('No previous stage exists. Return a complete <lb-stage> in TOON.')
end

local function resolve(triggerId, output)
  prelude.import(triggerId, 'toon.decode')
  local fullNodes = prelude.queryNodes('lb-stage', output)
  local patchNodes = prelude.queryNodes('lb-stage-patch', output)
  if #patchNodes > 0 then
    if #patchNodes ~= 1 or #fullNodes > 0 then
      fail('Return one patch or complete stage output, not both.')
    end
    local raw = prelude.trim(patchNodes[1].content)
    if raw:sub(1, 1) ~= '[' or raw:sub(-1) ~= ']' then
      fail('The patch must be a JSON array.')
    end
    local patch = json.decode(raw)
    local data = prelude.applyJSONPatch(previousState(triggerId), patch)
    return validateState(data)
  end
  if #fullNodes == 0 then
    fail('Missing <lb-stage> or <lb-stage-patch> node.')
  end
  return validateState(prelude.toon.decode(fullNodes[#fullNodes].content))
end

return function(triggerId, output)
  local success, result = pcall(resolve, triggerId, output)
  if not success then
    local message = tostring(result)
    if message:find('^InvalidOutput:') then
      error(message, 0)
    end
    fail(message)
  end
  return result
end
