local support = dofile('lb-stage/tests/support.lua')
local readFile = support.readFile
local queryNodes = prelude.queryNodes
local toon = prelude.toon
local validate = dofile('lb-stage/lorebooks/stage.onValidate.lua')
local encodeOutput = dofile('lb-stage/lorebooks/stage.onOutput.lua')
local callbacks = {}
function listenEdit(event, callback)
  callbacks[event] = callback
end
dofile('lb-stage/triggers/stage.lua')

local example = assert(readFile('lb-stage/lorebooks/lb.md'):match('```\n(.-)\n```'))
example = example:gsub('<lb%-stage[^\n]*>', '<lb-stage>'):gsub('⇥', '  ')
local decoded = toon.decode(queryNodes('lb-stage', example)[1].content)
assert(type(decoded.drive) == 'table')
assert(decoded.drive.belief_gap == 'none')
assert(decoded.drive.desire:find('chef', 1, true))
validate(nil, example)

local function requestFor(output)
  return callbacks.editRequest('test', {
    { content = '<lb-stage-reserve />', role = 'system' },
    { content = 'Story\n' .. encodeOutput(nil, output), role = 'assistant' },
  })
end

local request = requestFor(example)
assert(request[1].content:find('#### Phase Drive', 1, true))
assert(request[1].content:find(decoded.drive.desire, 1, true))
assert(request[1].content:find(decoded.drive.attempt, 1, true))
assert(not request[1].content:find('belief_gap:', 1, true))
assert(not request[2].content:find('<lb-stage>', 1, true))

assert(decoded.divergence == nil)
local legacy = example:gsub('drive:\n.-comment:', 'divergence: medium\ncomment:')
validate(nil, legacy)
local legacyRequest = requestFor(legacy)
assert(legacyRequest[1].content:find('#### Episodes', 1, true))
assert(not legacyRequest[1].content:find('#### Phase Drive', 1, true))

for _, drive in ipairs({ 'none', '7' }) do
  local malformed = example:gsub('drive:\n.-comment:', 'drive: ' .. drive .. '\ncomment:')
  assert(not pcall(validate, nil, malformed))
  assert(not pcall(encodeOutput, nil, malformed))
end

local empty = callbacks.editRequest('test', {
  { content = '<lb-stage-reserve />', role = 'system' },
})
assert(empty[1].content == '(None defined yet)')

local older = encodeOutput(nil, example)
local newer = encodeOutput(nil, example:gsub('The chef wants', 'The successor wants'))
local latest = callbacks.editRequest('test', {
  { content = '<lb-stage-reserve />', role = 'system' },
  { content = older, role = 'assistant' },
  { content = newer, role = 'assistant' },
})
assert(latest[1].content:find('The successor wants', 1, true))
assert(not latest[1].content:find('The chef wants', 1, true))
assert(not pcall(validate, nil, example:gsub('drive:', 'unknown:')))
print('Stage drive: decoding, validation, storage round-trip, injection, legacy, malformed, empty, and latest-state checks passed')
