assert(loadfile('/tmp/lb-xnai-prelude.lua'))()
local gen = assert(loadfile('lb-xnai/lorebooks/xnai.gen.lua'))()
local lbdata = assert(loadfile('/tmp/lb-xnai-lbdata.lua'))()
local checks = 0
local function check(condition, label)
  assert(condition, label)
  checks = checks + 1
end
local function slots(text)
  local values = {}
  for slot in text:gmatch('%[Slot (%d+)%]') do
    values[#values + 1] = slot
  end
  return table.concat(values, ',')
end

local cases = {
  '',
  'single line',
  'A\nB\nC\nD\nE',
  '<lb-xnai>\n' .. string.rep('hidden\n', 46) .. '</lb-xnai>\nA\nB\nC\nD\nE',
  'A\n<lb-xnai>\nhidden\n</lb-xnai>\nB\nC',
  'A\nB\n<lb-xnai>\nhidden\n</lb-xnai>',
  '<lb-xnai />\n<other />\nA\nB\n<tail />',
  'A<other>\nhidden\n</other>B\nC',
  'A\n<other>\nhidden\n</other>\n<another />\nB',
  'A\n\n<other keepalive>\nhidden\n</other>\n\nB',
  'A\r\n<other>\r\nhidden\r\n</other>\r\nB',
  'A\n<other>[Slot 47]\n</other>\nB',
  '  \n<other>\nhidden\n</other>\n  ',
  'A\n<unfinished\nB',
  'A\n<other><child>\nhidden\n</child></other>\nB',
  'A<lb-xnai>image</lb-xnai>B\nC',
  'A<lb-xnai />B<lb-xnai />C\nD',
}

for index, text in ipairs(cases) do
  local input, output, restore = gen.buildSlotMap(text)
  check(slots(input) == slots(output), 'Matching slot IDs: ' .. index)
  check(restore((output:gsub('%[Slot %d+%]\n\n', ''))) == text, 'Original preserved: ' .. index)
  local cleaned = prelude.removeAllNodes(text, { 'lb-xnai', 'output' })
  local cleanedInput = gen.buildSlotMap(cleaned)
  check(slots(cleanedInput) == slots(input), 'Backend cleanup preserves IDs: ' .. index)
  local rerollInput = gen.buildSlotMap(lbdata.removeNode(text, 'lb-xnai'))
  check(slots(rerollInput) == slots(input), 'Reroll cleanup preserves IDs: ' .. index)
end

local input = gen.buildSlotMap(cases[4])
check(slots(input) == '0,1,2,3', 'Multiline existing illustration does not consume slots')

local response
local generated = 0
local persisted = 0
local globalVars = {}
getGlobalVar = function(_, key)
  return globalVars[key] or '0'
end
getState = function()
  return nil
end
prelude.info = function() end
prelude.verbose = function() end
prelude.toon = { decode = function() return response end }
prelude.import = function() return gen end
gen.generate = function()
  generated = generated + 1
  return '{{inlay::test}}'
end
gen.persistStateAndHistory = function(_, state)
  persisted = persisted + 1
  return state
end
local onOutput = assert(loadfile('lb-xnai/lorebooks/xnai.onOutput.lua'))()
response = { scenes = { { slot = 0 }, { slot = 1 }, { slot = 2 }, { slot = 3 } } }
local output = onOutput('test', '<lb-xnai>data</lb-xnai>', cases[4], 22)
check(generated == 4, 'Four images generated')
for slot = 0, 3 do
  check(output:find('scene="' .. slot .. '"', 1, true) ~= nil, 'Scene inserted: ' .. slot)
end
check(not output:find('[Slot', 1, true), 'No unused slots remain')
check(output:find('<lb-xnai>\n' .. string.rep('hidden\n', 46) .. '</lb-xnai>', 1, true) ~= nil,
  'Existing XML preserved')
response = { scenes = { { slot = 47 }, { slot = 48 }, { slot = 49 }, { slot = 50 } } }
local success = pcall(onOutput, 'test', '<lb-xnai>data</lb-xnai>', cases[4], 22)
check(not success, 'Unavailable slots fail before generation')
check(generated == 4 and persisted == 1, 'Failed insertion neither generates nor persists')

for _, mode in ipairs({ 'generation', 'reroll' }) do
  getFullChat = function()
    return { { data = cases[4] .. '\n---\n[LBDATA START]\n[LBDATA END]\n---', role = 'char' } }
  end
  local onInput = assert(loadfile('lb-xnai/lorebooks/xnai.onInput.lua'))()
  local actual = onInput('test', cases[4], { index = 1, type = mode })
  check(slots(actual) == '0,1,2,3', 'onInput slot IDs: ' .. mode)
end
local preservedInput = [[<response kind="story">
narrative
</response>

---
[LBDATA START]
<lb-lazy id="lb-news" />
<lb-lazy id="lb-xnai" />
[LBDATA END]
---]]
globalVars['toggle_lightboard.preserveXML'] = '1'
getFullChat = function()
  return { { data = preservedInput, role = 'char' } }
end
local preservedOnInput = assert(loadfile('lb-xnai/lorebooks/xnai.onInput.lua'))()
local preservedActual = preservedOnInput('preserve-test', preservedInput, { index = 1, type = 'generation' })
check(preservedActual:find('<response kind="story">', 1, true) ~= nil, 'onInput preserves arbitrary XML')
check(preservedActual:find('<lb-lazy id="lb-news" />', 1, true) ~= nil, 'onInput preserves lazy XML')
local preservedResponse = prelude.queryNodes('response', preservedActual)[1]
check(preservedResponse and slots(preservedResponse.content) ~= '', 'onInput inserts slots inside arbitrary XML')
local preservedLBDATA = preservedActual:match('%[LBDATA START%](.-)%[LBDATA END%]') or ''
check(slots(preservedLBDATA) == '', 'onInput does not insert slots inside LBDATA')
local _, preservedOutputSlots = gen.buildContextSlotMap('preserve-test', preservedInput)
check(slots(preservedActual) == slots(preservedOutputSlots), 'onInput and onOutput use matching slot maps')
globalVars['toggle_lightboard.preserveXML'] = nil
local onValidate = assert(loadfile('lb-xnai/lorebooks/xnai.onValidate.lua'))()
local function descriptor(slot)
  return { camera = 'close-up', cast = 'solo', characters = {}, scene = 'room', slot = slot }
end
local function validate(slotsToUse, tid)
  response = { scenes = {} }
  for _, slot in ipairs(slotsToUse) do
    response.scenes[#response.scenes + 1] = descriptor(slot)
  end
  return pcall(onValidate, tid or 'test', '<lb-xnai>data</lb-xnai>')
end
check(validate({ 0, 1, 2, 3 }), 'Validation accepts provided slots')
for _, slot in ipairs({ 47, -1, 0.5, '0' }) do
  local ok, reason = validate({ slot })
  check(not ok and tostring(reason):find('InvalidOutput:', 1, true) ~= nil,
    'Validation rejects unavailable slot: ' .. tostring(slot))
end
check(not validate({ 0 }, 'another-request'), 'Request slot context is isolated')
check(validate({}), 'No scenes require no slots')
check(not validate({ 0, 0 }), 'Duplicate scene slots fail validation')
check(validate({ 0.0 }), 'Integral float slot is accepted')
local floatOutput = onOutput('test', '<lb-xnai>data</lb-xnai>', 'A\nB', 22)
check(floatOutput:find('scene="0"', 1, true) ~= nil, 'Integral float slot is normalized for insertion')
local beforeGeneration = generated
local beforePersistence = persisted
response = { scenes = { descriptor(3) } }
check(not pcall(onOutput, 'test', '<lb-xnai>data</lb-xnai>', 'A\nB', 22),
  'Output rechecks slots against current text')
check(generated == beforeGeneration and persisted == beforePersistence,
  'Changed text causes no image generation or persistence')

local target = { chatIndex = 22, slot = '47' }
getState = function(_, key)
  if key == 'lb-xnai-interaction-target' then
    return target
  end
  return { { chatIndex = 22, data = { scenes = {} }, operationID = 'previous' } }
end
getChat = function()
  return { data = 'A\n<lb-xnai scene="47">image</lb-xnai>\nB' }
end
response = { interaction = true, scenes = { descriptor(47) } }
check(pcall(onValidate, 'test', '<lb-xnai>data</lb-xnai>'), 'Existing interaction node remains eligible')
getChat = function()
  return { data = 'A\nB' }
end
check(not pcall(onValidate, 'test', '<lb-xnai>data</lb-xnai>'), 'Missing interaction location fails validation')
check(not pcall(onOutput, 'test', '<lb-xnai>data</lb-xnai>', 'A\nB', 22),
  'Missing interaction location fails before generation')
check(generated == beforeGeneration and persisted == beforePersistence,
  'Invalid interaction causes no image generation or persistence')
getChat = function()
  return { data = 'A\n<lb-xnai scene="47">image</lb-xnai>\nB' }
end
setState = function() end
local interactionOutput = onOutput('test', '<lb-xnai>data</lb-xnai>', getChat().data, 22)
check(interactionOutput:find('scene="47">{{inlay::test}}', 1, true) ~= nil,
  'Existing interaction location is replaced')
check(generated == beforeGeneration + 1, 'Valid interaction generates one image')

for index, text in ipairs(cases) do
  local visible, mapped, restore = gen.buildSlotMap(text)
  for slot in visible:gmatch('%[Slot (%d+)%]') do
    local marked = mapped:gsub('%[Slot ' .. slot .. '%]', '<inserted />', 1)
    marked = restore((marked:gsub('%[Slot %d+%]\n\n', '')))
    local node = prelude.queryNodes('inserted', marked)[1]
    check(node ~= nil, 'Insertion remains outside saved XML: ' .. index .. '/' .. slot)
  end
end
print('Passed ' .. checks .. ' checks')
