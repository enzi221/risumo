local test = require('test')
local describe = test.describe
local it = test.it

local function read(path)
  local file = assert(io.open(path))
  local content = file:read('*a')
  file:close()
  return content
end

local books = {}
local toggles = {}
local variables = {}
getChatVar = function(_, name)
  return variables[name]
end
setChatVar = function(_, name, value)
  variables[name] = value
end
getLoreBooks = function(_, name)
  return books[name] or {}
end
getGlobalVar = function(_, name)
  return toggles[name] or '0'
end
getChatLength = function()
  return 10
end

prelude = require('prelude')

for _, name in ipairs({ 'runtime', 'renderer.default' }) do
  books['lb-minitalk.' .. name] = { { content = read('lb-minitalk/lorebooks/lb-minitalk.' .. name .. '.lua') } }
end
for _, name in ipairs({ 'decode', 'encode' }) do
  books['toon.' .. name] = { { content = read('lb--be/lorebooks/toon.' .. name .. '.lua') } }
end
local runtime = prelude.import('test', 'lb-minitalk.runtime')
local validate = require('lb-minitalk/lorebooks/lb-minitalk.onValidate')
local output = require('lb-minitalk/lorebooks/lb-minitalk.onOutput')
local fixture = [[<lb-minitalk>
messages[6|]{sender|type|time|content}:
  p2|text|얼마 전|아직 회사야
  p2|text|얼마 전|나 먼저 감
  p2|text|얼마 전|충전기 안내 데스크에 맡겨둠
  p2|text|얼마 전|아
  p2|text|얼마 전|1층 말고 2층
  p2|text|방금|찾으면 말해줘
name: 민지
participants[2|]{id|name}:
  p1|퇴근시켜줘
  p2|귤두개
pov: p1
keyFigures[1|]{keyFigure|nickname|note}:
  민지|귤두개|모두에게 짧게 연속 전송하며 정정은 새 메시지로 보냄
</lb-minitalk>]]
local roomFixture = fixture:gsub(
  'keyFigures%[1|%]{keyFigure|nickname|note}:\n  [^\n]+\n', '')
local content = runtime.extract(fixture).content
local normalized = output('test', fixture)

local apply
local block
local con
local decoded
local empty
local extensionCode
local mutate
local operations
local patchOutput
local pause
local previous
local skip

describe('Messenger validation', function()
  it('validates room schema, messages, and output normalization', function()
    validate('test', fixture)
    test.assertEquals(#runtime.decode('test', content, true).messages, 6, 'Korean fixture decoded')

    pause = fixture:gsub('p2|text|방금|찾으면 말해줘', '-|pause|-|10분 후')
    validate('test', pause)
    test.assertTrue(output('test', pause):find('pause', 1, true) and output('test', pause):find('10분 후', 1, true),
      'Pause preserved in output')

    skip = fixture:gsub('p2|text|방금|찾으면 말해줘', '-|skip|-|-')
    validate('test', skip)
    local storedSkip = runtime.decode('test', runtime.extract(output('test', skip)).content, false).messages[6]
    test.assertTrue(storedSkip.sender == '-' and storedSkip.time == '-'
      and storedSkip.type == 'skip' and storedSkip.content == '-', 'Skip preserved in output')

    test.assertEquals(output('test', 'preface\n' .. fixture .. '\ntrailer'), normalized,
      'Output strips surrounding prose')
    test.assertEquals(output('test', '<lb-minitalk>invalid</lb-minitalk>' .. fixture), normalized,
      'Last complete node selected')

    test.assertEquals(
      runtime.decode('test', runtime.extract(fixture:gsub('찾으면 말해줘', '[con:wave]')).content, true).messages[6].content,
      '[con:wave]', 'Text may contain literal MiniCon syntax')

    local multiline = fixture:gsub('찾으면 말해줘', '찾으면\\u000A말해줘')
    test.assertTrue(output('test', (multiline:gsub('\\u000A', '\\n'))):find('\\u000A', 1, true),
      'Stored newline normalized')
    validate('test', normalized)
    decoded = runtime.decode('test', content, true)
    test.assertTrue(runtime.decode('test', runtime.extract(multiline).content, true).messages[6].content:find('\n', 1, true),
      'Unicode newline decoded')

    empty = '<lb-minitalk>\nmessages[0|]:\nname: Empty\nparticipants[2|]{id|name}:\n  p1|A\n  p2|B\npov: p1\n</lb-minitalk>'
    validate('test', empty)
    test.assertEquals(#runtime.decode('test', runtime.extract(empty).content, true).messages, 0, 'Empty room')
    validate('test', output('test', empty))

    con = fixture:gsub('p2|text|방금|찾으면 말해줘', 'p2|con|방금|wave')
    validate('test', con)
    test.assertTrue(output('test', con):find('wave', 1, true), 'Disabled MiniCons preserved in output')

    toggles['toggle_lb-minitalk.cons'] = '1'
    validate('test', con)

    extensionCode = [[return {
      render = function(_, content) return '<b>' .. content .. '</b>' end,
      validate = function(_, content)
        return content == 'payload', 'Card requires payload'
      end,
    }]]
    books['lb-minitalk.openblock'] = {
      { content = 'identifier=card\nCard description' },
    }
    books['lb-minitalk.openblock.card'] = { { content = extensionCode } }
    block = fixture:gsub('p2|text|방금|찾으면 말해줘', 'p2|openblock:card|방금|payload')
    toggles['toggle_lb-minitalk.openblock'] = '1'
    validate('test', block)

    local storedData = runtime.decode('test', runtime.extract(block).content, false)
    test.assertEquals(storedData.messages[6].type, 'openblock:card', 'OpenBlock message decoded')

    local invalidBlock = block:gsub('payload', 'invalid')
    local displayed = runtime.decode('test', runtime.extract(invalidBlock).content, false)
    test.assertEquals(displayed.messages[6].content, 'invalid',
      'Stored OpenBlock content does not prevent room display')
    local success, reason = pcall(runtime.decode, 'test', runtime.extract(invalidBlock).content, true)
    test.assertTrue(not success and tostring(reason):find('Card requires payload', 1, true) ~= nil,
      'Generation validation reports the OpenBlock reason')
  end)
end)

describe('Messenger mutation', function()
  it('applies interaction patches while preserving valid history', function()
    mutate = require('lb-minitalk/lorebooks/lb-minitalk.onMutation')
    json = {
      decode = function(value)
        if value ~= 'fixture' then
          error('Invalid JSON fixture')
        end
        return operations
      end,
    }
    patchOutput = '<lb-minitalk-patch>fixture</lb-minitalk-patch>'
    apply = function(ops, prev)
      operations = ops
      validate('test', patchOutput)
      return mutate('test', 'interaction', 'before' .. patchOutput .. 'after', {
        output = patchOutput,
        previousNode = prev,
      })
    end
    previous = runtime.extract(fixture)
    operations = {}
    test.assertEquals(output('test', patchOutput), patchOutput, 'Patch survives onOutput')

    local appended = apply({ {
      op = 'add',
      path = '/messages/-',
      value = { content = '고마워\n정말', sender = 'p1', time = '신규', type = 'text' },
    } }, previous)
    local room = runtime.decode('test', runtime.extract(appended).content, false)
    test.assertTrue(#room.messages == 7 and room.messages[7].sender == 'p1', 'Append patch adds a message')
    test.assertEquals(room.messages[1].content, decoded.messages[1].content, 'History preserved')
    test.assertEquals(room.messages[7].time, '신규', 'Appended message time preserved')
    for index, message in ipairs(decoded.messages) do
      test.assertEquals(room.messages[index].time, message.time, 'Append patch preserves existing time')
    end
    test.assertTrue(appended:sub(1, 6) == 'before' and appended:sub(-5) == 'after', 'Surrounding chat preserved')

    local changed = output('test', empty)
    validate('test', changed)
    for _, context in ipairs({ {}, { previousNode = previous } }) do
      context.output = changed
      local fullChat = 'before' .. changed .. 'after'
      test.assertEquals(mutate('test', 'interaction', fullChat, context), fullChat,
        'Complete room output bypasses patch mutation')
    end

    local passed = apply({ {
      op = 'add',
      path = '/messages/-',
      value = { content = '잠시 후', sender = '-', time = '-', type = 'pause' },
    }, {
      op = 'add',
      path = '/messages/-',
      value = { content = '아직 바빠?', sender = 'p2', time = '신규', type = 'text' },
    } }, previous)
    local continued = runtime.decode('test', runtime.extract(passed).content, false)
    test.assertTrue(#continued.messages == 8 and continued.messages[8].sender == 'p2',
      'Multi-operation patch adds messages in order')
    test.assertEquals(continued.messages[8].time, '신규', 'Multi-operation patch preserves new message time')
    for index, message in ipairs(decoded.messages) do
      test.assertEquals(continued.messages[index].time, message.time, 'Multi-operation patch preserves existing time')
    end
    test.assertEquals(continued.messages[6].content, decoded.messages[6].content,
      'Multi-operation patch preserves prior messages')

    local silent = apply({}, previous)
    test.assertEquals(#runtime.decode('test', runtime.extract(silent).content, false).messages, 6,
      'Empty patch preserves room')
    test.assertEquals(mutate('test', 'reroll', fixture), fixture, 'Reroll unchanged')
  end)
end)

describe('Messenger key-figure state', function()
  it('merges key-figure updates into cached state without storing them in the room', function()
    validate('test', roomFixture)
    local stored = output('test', fixture)
    local preserved = variables['lb-minitalk.keyfigures']
    test.assertEquals(output('test', roomFixture), normalized, 'Missing key figures accepted')
    test.assertEquals(variables['lb-minitalk.keyfigures'], preserved, 'Missing key figures preserve state')
    test.assertTrue(stored:find('keyFigures', 1, true) == nil, 'Key figures removed from stored room output')
    test.assertEquals(#runtime.decode('test', runtime.extract(stored).content, false).keyFigures, 1,
      'Stored room hydrates key figures from cached state')

    local updated = apply({ { op = 'replace', path = '/name', value = 'changed room' } }, runtime.extract(stored))
    test.assertTrue(updated:find('keyFigures', 1, true) == nil, 'Mutation keeps key figures out of room output')
    test.assertEquals(variables['lb-minitalk.keyfigures'], preserved, 'Mutation preserves cached key figures')

    local cleared = fixture:gsub(
      'keyFigures%[1|%]{keyFigure|nickname|note}:\n  [^\n]+\n', 'keyFigures[0|]:\n')
    output('test', cleared)
    test.assertEquals(variables['lb-minitalk.keyfigures'], preserved, 'Empty key-figure updates preserve state')

    local added = fixture:gsub(
      'keyFigures%[1|%]{keyFigure|nickname|note}:\n  [^\n]+',
      [[keyFigures[1|]{keyFigure|nickname|note}:
  Vergilius|베르|단호한 말투]])
    output('test', added)
    test.assertEquals(#prelude.toon.decode(variables['lb-minitalk.keyfigures']), 2,
      'New key-figure updates merge into preserved state')

    local replaced = fixture:gsub(
      'keyFigures%[1|%]{keyFigure|nickname|note}:\n  [^\n]+',
      [[keyFigures[1|]{keyFigure|nickname|note}:
  민지|귤셋|모두에게 짧게 보내고 친한 친구에게만 문장 끝을 생략함]])
    output('test', replaced)
    local replacedKeyFigures = prelude.toon.decode(variables['lb-minitalk.keyfigures'])
    test.assertEquals(#replacedKeyFigures, 2, 'Same key figure replaces the preserved entry')
    test.assertEquals(replacedKeyFigures[1].nickname, '귤셋', 'Replacement updates the nickname')
    test.assertEquals(replacedKeyFigures[1].note,
      '모두에게 짧게 보내고 친한 친구에게만 문장 끝을 생략함', 'Replacement updates the note')

    operations = { { op = 'replace', path = '/messages/99/time', value = 'test' } }
    test.assertTrue(not pcall(validate, 'test', patchOutput, { previousNode = runtime.extract(stored) }),
      'Invalid patch fails validation with previousNode')
  end)
end)

test.printSummary()
