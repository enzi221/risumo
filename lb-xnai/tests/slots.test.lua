local test = require('test')
local describe = test.describe
local it = test.it

prelude = require('prelude')

local gen = require('lb-xnai/lorebooks/xnai.gen')
local lbdata = require('lbdata')
local function slots(text)
  local values = {}
  for slot in text:gmatch('<slot num="(%d+)"/>') do
    values[#values + 1] = slot
  end
  return table.concat(values, ',')
end

local sampleText = 'A\nB\nC\nD\nE'
local illustrationFixture = '<lb-xnai>\n' .. string.rep('hidden\n', 46) .. '</lb-xnai>\nA\nB\nC\nD\nE'
local xmlFixture = 'A\n<other>\nhidden\n</other>\nB\nC'
local fixtures = { sampleText, illustrationFixture, xmlFixture }

local response
local patchResponse
json = {
  decode = function()
    return patchResponse
  end,
  encode = function(value)
    return tostring(value)
  end,
}
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

local onInput = require('lb-xnai/lorebooks/xnai.onInput')
local onOutput = require('lb-xnai/lorebooks/xnai.onOutput')
local onValidate = require('lb-xnai/lorebooks/xnai.onValidate')

local function descriptor(slot)
  return { camera = 'close-up', cast = 'solo', characters = {}, scene = 'room', slot = slot }
end

describe('XNAI slot mapping', function()
  it('keeps slot IDs stable through backend cleanup and rerolls', function()
    for index, text in ipairs(fixtures) do
      local input, output, restore = gen.buildSlotMap(text)
      test.assertEquals(slots(input), slots(output), 'Matching slot IDs: ' .. index)
      test.assertEquals(restore((output:gsub('<slot num="%d+"/>\n\n', ''))), text, 'Original preserved: ' .. index)
      local cleaned = prelude.removeAllNodes(text, { 'lb-xnai', 'output' })
      local cleanedInput = gen.buildSlotMap(cleaned)
      test.assertEquals(slots(cleanedInput), slots(input), 'Backend cleanup preserves IDs: ' .. index)
      local rerollInput = gen.buildSlotMap(lbdata.removeNode(text, 'lb-xnai'))
      test.assertEquals(slots(rerollInput), slots(input), 'Reroll cleanup preserves IDs: ' .. index)
    end

    local input = gen.buildSlotMap(illustrationFixture)
    test.assertEquals(slots(input), '0,1,2,3', 'Multiline existing illustration does not consume slots')
  end)

  it('collapses excessive consecutive newlines when placing slots', function()
    local text = 'A\n\n\n\nB\n\n\n\n\n\n\n\nC'
    local input, output = gen.buildSlotMap(text)
    test.assertEquals(slots(input), '0,1', 'Input slot IDs')
    test.assertEquals(slots(output), '0,1', 'Output slot IDs')
    test.assertEquals(input, 'A\n\n<slot num="0"/>\n\nB\n\n<slot num="1"/>\n\nC', 'Input newlines collapsed')
    test.assertEquals(output, 'A\n\n<slot num="0"/>\n\nB\n\n<slot num="1"/>\n\nC', 'Output newlines collapsed')
  end)

  it('inserts available scenes without generating invalid ones', function()
    response = { scenes = { { slot = 0 }, { slot = 1 }, { slot = 2 }, { slot = 3 } } }
    local output = onOutput('test', '<lb-xnai>data</lb-xnai>', illustrationFixture, 22)
    test.assertEquals(generated, 4, 'Four images generated')
    for slot = 0, 3 do
      test.assertTrue(output:find('scene="' .. slot .. '"', 1, true) ~= nil, 'Scene inserted: ' .. slot)
    end
    test.assertTrue(not output:find('<slot num=', 1, true), 'No unused slots remain')
    test.assertTrue(output:find('<lb-xnai>\n' .. string.rep('hidden\n', 46) .. '</lb-xnai>', 1, true) ~= nil,
      'Existing XML preserved')
    response = { scenes = { { slot = 47 }, { slot = 48 }, { slot = 49 }, { slot = 50 } } }
    local success = pcall(onOutput, 'test', '<lb-xnai>data</lb-xnai>', illustrationFixture, 22)
    test.assertTrue(not success, 'Unavailable slots fail before generation')
    test.assertTrue(generated == 4 and persisted == 1, 'Failed insertion neither generates nor persists')
  end)

  it('maps input slots while preserving XML and LBDATA boundaries', function()
    for _, mode in ipairs({ 'generation', 'reroll' }) do
      getFullChat = function()
        return { { data = illustrationFixture .. '\n---\n[LBDATA START]\n[LBDATA END]\n---', role = 'char' } }
      end
      local actual = onInput('test', illustrationFixture, { index = 1, type = mode })
      test.assertEquals(slots(actual), '0,1,2,3', 'onInput slot IDs: ' .. mode)
    end
    local preservedInput = [[<response kind="story">
    narrative
    </response>

    <Thoughts>
    hidden reasoning
    across multiple lines
    </Thoughts>

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
    local preservedActual = onInput('preserve-test', preservedInput, { index = 1, type = 'generation' })
    test.assertTrue(preservedActual:find('<response kind="story">', 1, true) ~= nil, 'onInput preserves arbitrary XML')
    test.assertTrue(preservedActual:find('<lb-lazy id="lb-news" />', 1, true) ~= nil, 'onInput preserves lazy XML')
    test.assertTrue(preservedActual:find('<Thoughts>', 1, true) == nil, 'onInput removes Thoughts XML')
    local preservedResponse = prelude.queryNodes('response', preservedActual)[1]
    test.assertTrue(preservedResponse and slots(preservedResponse.content) ~= '', 'onInput inserts slots inside arbitrary XML')
    local preservedLBDATA = preservedActual:match('%[LBDATA START%](.-)%[LBDATA END%]') or ''
    test.assertEquals(slots(preservedLBDATA), '', 'onInput does not insert slots inside LBDATA')
    local _, preservedOutputSlots = gen.buildContextSlotMap('preserve-test', preservedInput)
    test.assertEquals(slots(preservedActual), slots(preservedOutputSlots), 'onInput and onOutput use matching slot maps')
    test.assertTrue(preservedOutputSlots:find('hidden reasoning', 1, true) == nil,
      'onOutput slot mapping excludes Thoughts content')
    globalVars['toggle_lightboard.preserveXML'] = nil
  end)

  it('restores Thoughts when composing scene insertions', function()
    globalVars['toggle_lightboard.preserveXML'] = '1'
    response = { scenes = { descriptor(0) } }
    local output = onOutput('thoughts-test', '<lb-xnai>data</lb-xnai>',
      'A\n<Thoughts>hidden\nreasoning</Thoughts>\nB', 22)
    test.assertTrue(output:find('<Thoughts>hidden\nreasoning</Thoughts>', 1, true) ~= nil,
      'Thoughts XML is restored')
    test.assertTrue(output:find('scene="0"', 1, true) ~= nil, 'Scene uses the cleaned slot map')
    globalVars['toggle_lightboard.preserveXML'] = nil
  end)

  it('validates selected scene slots against the current input', function()
    local function validate(slotsToUse, tid)
      response = { scenes = {} }
      for _, slot in ipairs(slotsToUse) do
        response.scenes[#response.scenes + 1] = descriptor(slot)
      end
      return pcall(onValidate, tid or 'test', '<lb-xnai>data</lb-xnai>')
    end

    test.assertTrue(validate({ 0, 1, 2, 3 }), 'Validation accepts provided slots')
    local ok, reason = validate({ 47 })
    test.assertTrue(not ok and tostring(reason):find('InvalidOutput:', 1, true) ~= nil,
      'Validation rejects unavailable slot')
    test.assertTrue(not validate({ 0 }, 'another-request'), 'Request slot context is isolated')
    test.assertTrue(validate({}), 'No scenes require no slots')
    test.assertTrue(not validate({ 0, 0 }), 'Duplicate scene slots fail validation')
    test.assertTrue(validate({ 0.0 }), 'Integral float slot is accepted')
    local floatOutput = onOutput('test', '<lb-xnai>data</lb-xnai>', 'A\nB', 22)
    test.assertTrue(floatOutput:find('scene="0"', 1, true) ~= nil, 'Integral float slot is normalized for insertion')
    local beforeGeneration = generated
    local beforePersistence = persisted
    response = { scenes = { descriptor(3) } }
    test.assertTrue(not pcall(onOutput, 'test', '<lb-xnai>data</lb-xnai>', 'A\nB', 22),
      'Output rechecks slots against current text')
    test.assertTrue(generated == beforeGeneration and persisted == beforePersistence,
      'Changed text causes no image generation or persistence')
  end)

  it('uses the interaction response slot instead of a stale target state', function()
    local beforeGeneration = generated
    local beforePersistence = persisted
    local target = { chatIndex = 22, slot = '47' }
    getState = function(_, key)
      if key == 'lb-xnai-interaction-target' then
        return target
      end
      return { { chatIndex = 22, data = { scenes = { ['47'] = descriptor(47) } }, operationID = 'previous' } }
    end
    local interactionText = 'A\n<lb-xnai scene="47">image</lb-xnai>\nB'
    gen.setInputSlots('test', interactionText)
    patchResponse = { { op = 'replace', path = '/scenes/0', value = descriptor(47) } }
    test.assertTrue(pcall(onValidate, 'test', '<lb-xnai-patch>data</lb-xnai-patch>'), 'Existing interaction node remains eligible')
    patchResponse = { { op = 'replace', path = '/scenes/99', value = descriptor(47) } }
    test.assertTrue(not pcall(onValidate, 'test', '<lb-xnai-patch>data</lb-xnai-patch>', { chatIndex = 22 }),
      'Invalid patch fails validation with context')
    patchResponse = { { op = 'replace', path = '/scenes/0', value = descriptor(47) } }
    getChat = function()
      return { data = 'A\nB' }
    end
    gen.setInputSlots('test', 'A\nB')
    test.assertTrue(not pcall(onValidate, 'test', '<lb-xnai-patch>data</lb-xnai-patch>'), 'Missing interaction location fails validation')
    test.assertTrue(not pcall(onOutput, 'test', '<lb-xnai-patch>data</lb-xnai-patch>', 'A\nB', 22),
      'Missing interaction location fails before generation')
    test.assertTrue(generated == beforeGeneration and persisted == beforePersistence,
      'Invalid interaction causes no image generation or persistence')
    setState = function() end
    getState = function()
      return { { chatIndex = 22, data = { scenes = { ['18'] = descriptor(18) } }, operationID = 'previous' } }
    end
    local newDesc = descriptor(18)
    newDesc.scene = 'changed scene'
    patchResponse = { { op = 'replace', path = '/scenes/0', value = newDesc } }
    local interactionOutput = onOutput('test', '<lb-xnai-patch>data</lb-xnai-patch>',
      'A\n<lb-xnai scene="18">image</lb-xnai>\nB', 22)
    test.assertTrue(interactionOutput:find('scene="18">{{inlay::test}}', 1, true) ~= nil,
      'Response slot replaces its existing interaction location')
    test.assertEquals(generated, beforeGeneration + 1, 'Valid interaction generates one image')
    globalVars['toggle_lb-xnai.generation'] = '1'
    local manualOutput = onOutput('test', '<lb-xnai-patch>data</lb-xnai-patch>',
      'A\n<lb-xnai scene="18">image</lb-xnai>\nB', 22)
    test.assertTrue(manualOutput:find('<lb%-xnai id="scene%-18" operation="previous" scene="18" />') ~= nil,
      'Modified prompt in manual mode clears existing inlay')

    getState = function()
      return { {
        chatIndex = 22,
        data = {
          keyvis = descriptor(-1),
          scenes = { ['18'] = descriptor(18), ['20'] = descriptor(20) },
        },
        operationID = 'previous',
      } }
    end
    local multiSceneOutput = onOutput('test', '<lb-xnai-patch>data</lb-xnai-patch>',
      'A\n<lb-xnai scene="18">image18</lb-xnai>\n<lb-xnai scene="20">image20</lb-xnai>\n<lb-xnai id="keyvis" kv>imageKV</lb-xnai>\nB', 22)
    test.assertTrue(multiSceneOutput:find('<lb%-xnai id="scene%-18" operation="previous" scene="18" />') ~= nil,
      'Modified scene clears inlay in manual mode')
    test.assertTrue(multiSceneOutput:find('scene="20">image20</lb-xnai>', 1, true) ~= nil,
      'Unchanged scene retains existing inlay')
    test.assertTrue(multiSceneOutput:find('id="keyvis" kv operation="previous">imageKV</lb-xnai>', 1, true) ~= nil,
      'Unchanged keyvis retains existing inlay')
    globalVars['toggle_lb-xnai.generation'] = nil
  end)
end)

test.printSummary()
