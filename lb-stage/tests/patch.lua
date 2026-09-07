local support = dofile('lb-stage/tests/support.lua')
local validate = dofile('lb-stage/lorebooks/stage.onValidate.lua')
local encodeOutput = dofile('lb-stage/lorebooks/stage.onOutput.lua')
local decodeInput = dofile('lb-stage/lorebooks/stage.onInput.lua')
local onInstructions = dofile('lb-stage/lorebooks/stage.onInstructions.lua')
local fixtures = {}
local chats = {}
local recentCalls = 0
local sampling = '0'

function getGlobalVar()
  return sampling
end

json = {
  decode = function(raw)
    return assert(fixtures[raw], 'Invalid JSON')
  end,
}

function getChatLength()
  return #chats
end

function getRecentChats(_, count)
  assert(count == #chats)
  recentCalls = recentCalls + 1
  return chats
end

local function patch(raw, operations)
  fixtures[raw] = operations
  return '<lb-stage-patch>' .. raw .. '</lb-stage-patch>'
end

local function decodeStored(stored)
  local input = decodeInput('test', stored)
  local nodes = prelude.queryNodes('lb-stage', input)
  return prelude.toon.decode(nodes[#nodes].content)
end

local function rejects(output)
  for _, callback in ipairs({ validate, encodeOutput }) do
    local success, message = pcall(callback, 'test', output)
    assert(not success, 'Invalid output accepted')
    assert(tostring(message):find('InvalidOutput:', 1, true), tostring(message))
  end
end

local example = assert(support.readFile('lb-stage/lorebooks/lb.md'):match('```\n(.-)\n```'))
example = example:gsub('<lb%-stage[^\n]*>', '<lb-stage>'):gsub('⇥', '  ')
local older = encodeOutput('test', example)
local newer = encodeOutput('test', example:gsub('The chef wants', 'The successor wants'))
assert(recentCalls == 0)
local original = decodeStored(newer)
local update = patch('[{"op":"replace","path":"/drive/attempt","value":"A new attempt"},{"op":"replace","path":"/comment","value":"Ongoing E2 for 3 turns."}]', {
  { op = 'replace', path = '/drive/attempt', value = 'A new attempt' },
  { op = 'replace', path = '/comment', value = 'Ongoing E2 for 3 turns.' },
})
rejects(update)
chats = {
  { data = older, role = 'char' },
  { data = newer, role = 'char' },
  { data = 'Latest story without stage data', role = 'char' },
}
validate('test', update)
local stored = encodeOutput('test', update)
assert(not stored:find('<lb-stage-patch>', 1, true))
local updated = decodeStored(stored)
assert(updated.drive.attempt == 'A new attempt')
assert(updated.comment == 'Ongoing E2 for 3 turns.')
assert(updated.drive.desire == original.drive.desire)
assert(updated.history == original.history)
assert(updated.phase.content == original.phase.content)
assert(updated.objective.content == original.objective.content)
assert(chats[2].data == newer)

local advance = patch('[{"op":"replace","path":"/episodes/1/state","value":"done"}]', {
  { op = 'replace', path = '/episodes/1/state', value = 'done' },
})
assert(decodeStored(encodeOutput('test', advance)).episodes[2].state == 'done')
assert(decodeStored(newer).episodes[2].state == 'ongoing')

local append = patch('[{"op":"add","path":"/episodes/-","value":{"content":"Next situation","stage":"rise","state":"pending","title":"Next"}}]', {
  { op = 'add', path = '/episodes/-', value = {
    content = 'Next situation', stage = 'rise', state = 'pending', title = 'Next',
  } },
})
validate('test', append)
assert(#decodeStored(encodeOutput('test', append)).episodes == #original.episodes + 1)
assert(#decodeStored(encodeOutput('test', append)).episodes == #original.episodes + 1)

local remove = patch('[{"op":"remove","path":"/episodes/0"}]', {
  { op = 'remove', path = '/episodes/0' },
})
local removed = decodeStored(encodeOutput('test', remove))
assert(#removed.episodes == #original.episodes - 1)
assert(removed.episodes[1].title == original.episodes[2].title)

local unchanged = decodeStored(encodeOutput('test', patch('[]', {})))
assert(unchanged.drive.attempt == original.drive.attempt)
assert(unchanged.comment == original.comment)
rejects('<lb-stage-patch>{}</lb-stage-patch>')
rejects('<lb-stage-patch>[broken]</lb-stage-patch>')
rejects(update .. example)
rejects(update .. update)
rejects(patch('[{"op":"replace","path":"/episodes/99/state","value":"done"}]', {
  { op = 'replace', path = '/episodes/99/state', value = 'done' },
}))
rejects(patch('[{"op":"remove","path":"/objective"}]', {
  { op = 'remove', path = '/objective' },
}))
rejects(patch('[{"op":"add","path":"/unknown","value":"x"}]', {
  { op = 'add', path = '/unknown', value = 'x' },
}))
rejects(patch('[{"op":"replace","path":"/episodes/1/state","value":"invalid"}]', {
  { op = 'replace', path = '/episodes/1/state', value = 'invalid' },
}))
rejects(patch('[{"op":"replace","path":"/episodes/0/state","value":"ongoing"}]', {
  { op = 'replace', path = '/episodes/0/state', value = 'ongoing' },
}))
assert(chats[2].data == newer)

chats = { { data = older .. newer, role = 'char' } }
assert(decodeStored(encodeOutput('test', update)).drive.desire == original.drive.desire)
local decodedNodes = prelude.queryNodes('lb-stage', decodeInput('test', older .. newer))
assert(prelude.toon.decode(decodedNodes[1].content).drive.desire:find('The chef wants', 1, true))
assert(prelude.toon.decode(decodedNodes[2].content).drive.desire == original.drive.desire)

chats = { { data = newer, role = 'char' }, { data = '<lb-stage>broken</lb-stage>', role = 'char' } }
rejects(update)
chats = {}
assert(decodeStored(encodeOutput('test', example)).phase.title == original.phase.title)
assert(decodeStored(encodeOutput('test', example .. example:gsub('Renewal of the Heart', 'New objective'))).objective.title == 'New objective')

local format = support.readFile('lb-stage/lorebooks/lb.format.md')
for _, requestType in ipairs({ 'reroll', 'interaction' }) do
  local instructions = onInstructions('test', { format = format, guideline = 'Rules' }, { type = requestType })
  assert(not instructions.format:find('<lb-stage-patch>', 1, true))
  assert(instructions.format:find('<lb-stage', 1, true) == 1)
  assert(instructions.guideline:find('instead of a patch', 1, true))
end
local normal = onInstructions('test', { format = format, guideline = 'Rules' }, { type = 'generation' })
assert(normal.format == format and normal.guideline == 'Rules')
sampling = '1'
local sampled = onInstructions('test', { format = format, guideline = 'Rules' }, { type = 'generation' })
assert(not sampled.format:find('<lb-stage-patch>', 1, true))
assert(sampled.guideline == 'Rules')
sampling = '0'

local callbacks = {}
function listenEdit(event, callback)
  callbacks[event] = callback
end
dofile('lb-stage/triggers/stage.lua')
local request = callbacks.editRequest('test', {
  { content = '<lb-stage-reserve />', role = 'system' },
  { content = stored, role = 'assistant' },
})
assert(request[1].content:find('A new attempt', 1, true))
assert(request[1].content:find(original.drive.desire, 1, true))
assert(not request[2].content:find('<lb-stage>', 1, true))
print('Stage patch: latest-state merge, storage, injection, add/remove/replace, no-op, retries, validation, missing/corrupt base, sampling, and regeneration routing passed (host JSON decoder mocked)')
