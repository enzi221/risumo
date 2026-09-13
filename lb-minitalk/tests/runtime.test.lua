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
local instructions = require('lb-minitalk/lorebooks/lb-minitalk.onInstructions')
local source = read('lb-minitalk/lorebooks/lb.md')
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
local function rejects(value)
  test.assertFails(function()
    validate('test', value)
  end, 'InvalidOutput:', 'Reject invalid room output')
end

local function countVisibleAvatars(rendered)
  local count = 0
  for tag in rendered:gmatch('<div [^>]*>') do
    if tag:find('class="lb-minitalk-avatar lb-minitalk-gradient"', 1, true)
        and tag:find('data-visible="true"', 1, true) then
      count = count + 1
    end
  end
  return count
end

local function countVisibleSenders(rendered, name)
  local count = 0
  for attributes, content in rendered:gmatch('<div ([^>]*)>([^<]*)</div>') do
    if attributes:find('class="lb-minitalk-sender"', 1, true)
        and attributes:find('data-visible="true"', 1, true)
        and content == name then
      count = count + 1
    end
  end
  return count
end

local apply
local block
local con
local decoded
local display
local empty
local extensionCode
local html
local mutate
local operations
local patchOutput
local pause
local previous
local skip
local success

describe('Messenger validation', function()
  it('validates room schema, messages, and output normalization', function()
    validate('test', fixture)
    test.assertEquals(#runtime.decode('test', content, true).messages, 6, 'Korean fixture decoded')
    pause = fixture:gsub('p2|text|방금|찾으면 말해줘', '-|pause|-|10분 후')
    validate('test', pause)
    rejects(pause:gsub('%-|pause|%-|10분 후', 'p2|pause|-|10분 후'))
    rejects(pause:gsub('%-|pause|%-|10분 후', '-|pause|방금|10분 후'))
    rejects(pause:gsub('%-|pause|%-|10분 후', '-|pause|-|'))
    test.assertTrue(output('test', pause):find('pause', 1, true) and output('test', pause):find('10분 후', 1, true),
      'Pause preserved in output')
    skip = fixture:gsub('p2|text|방금|찾으면 말해줘', '-|skip|-|-')
    validate('test', skip)
    rejects(skip:gsub('%-|skip|%-|%-', 'p2|skip|-|-'))
    rejects(skip:gsub('%-|skip|%-|%-', '-|skip|방금|-'))
    rejects(skip:gsub('%-|skip|%-|%-', '-|skip|-|생략'))
    local storedSkip = runtime.decode('test', runtime.extract(output('test', skip)).content, false).messages[6]
    test.assertTrue(storedSkip.sender == '-' and storedSkip.time == '-'
      and storedSkip.type == 'skip' and storedSkip.content == '-', 'Skip preserved in output')
    test.assertEquals(output('test', 'preface\n' .. fixture .. '\ntrailer'), normalized,
      'Output strips surrounding prose')
    test.assertEquals(output('test', '<lb-minitalk>invalid</lb-minitalk>' .. fixture), normalized,
      'Last complete node selected')
    rejects(fixture .. '<lb-minitalk>invalid</lb-minitalk>')
    rejects(fixture:gsub('</lb%-minitalk>', ''))
    rejects(fixture:gsub('messages%[6', 'messages[7'))
    rejects(fixture:gsub('pov: p1', 'pov: unknown'))
    rejects(fixture:gsub('p2|text', 'unknown|text'))
    rejects(fixture:gsub('p2|귤두개', 'p1|귤두개'))
    rejects(fixture:gsub('찾으면 말해줘', '안녕|추가'))
    test.assertEquals(
      runtime.decode('test', runtime.extract(fixture:gsub('찾으면 말해줘', '[con:wave]')).content, true).messages[6].content,
      '[con:wave]', 'Text may contain literal MiniCon syntax')
    rejects(fixture:gsub('pov: p1', 'pov: p1\npov: p2'))
    local multiline = fixture:gsub('찾으면 말해줘', '찾으면\\u000A말해줘')
    test.assertTrue(output('test', multiline:gsub('\\u000A', '\\n')):find('\\u000A', 1, true),
      'Stored newline normalized')
    validate('test', normalized)
    decoded = runtime.decode('test', content, true)
    test.assertTrue(runtime.decode('test', runtime.extract(multiline).content, true).messages[6].content:find('\n', 1, true),
      'Unicode newline decoded')
    empty =
    '<lb-minitalk>\nmessages[0|]:\nname: Empty\nparticipants[2|]{id|name}:\n  p1|A\n  p2|B\npov: p1\n</lb-minitalk>'
    validate('test', empty)
    test.assertEquals(#runtime.decode('test', runtime.extract(empty).content, true).messages, 0, 'Empty room')
    validate('test', output('test', empty))
    con = fixture:gsub('p2|text|방금|찾으면 말해줘', 'p2|con|방금|wave')
    validate('test', con)
    test.assertTrue(output('test', con):find('wave', 1, true), 'Disabled MiniCons preserved in output')
    rejects(con:gsub('|wave', '|wave,smile'))
    toggles['toggle_lb-minitalk.cons'] = '1'
    validate('test', con)
    rejects(con:gsub('|wave', '|wave,smile'))
    rejects(con:gsub('|wave', '|wave,,smile'))
    rejects(con:gsub('|wave', '|{{bad}}'))
    rejects(con:gsub('|wave', '|'))
    rejects(con:gsub('|wave', '|[con:wave]'))
    books['lb-mini.cons'] = { { content = '- `wave`' } }
    extensionCode = [[return {
      render = function(_, content, options)
        return '<b>' .. options.escapeText(content) .. '</b>'
      end,
      validate = function(_, content)
        return content == 'payload'
      end,
    }]]
    books['lb-minitalk.openblock'] = { { content = 'identifier=card\nUse the literal payload string.' } }
    books['lb-minitalk.openblock.card'] = { { content = extensionCode } }
    block = fixture:gsub('p2|text|방금|찾으면 말해줘', 'p2|openblock:card|방금|payload')
    rejects(block)
    test.assertTrue(not instructions('test', { guideline = source }).guideline:find('identifier=card', 1, true),
      'Disabled OpenBlock prompt omitted')
    toggles['toggle_lb-minitalk.openblock'] = '1'
    validate('test', block)
    rejects(block:gsub('|payload', '|invalid'))
    rejects(block:gsub('openblock:card', 'openblock:missing'))
    test.assertTrue(instructions('test', { guideline = source }).guideline:find('identifier=card', 1, true),
      'Enabled OpenBlock prompt attached')
    books['lb-minitalk.openblock.card'] = { { content = 'invalid Lua!' } }
    test.assertTrue(not instructions('test', { guideline = source }).guideline:find('identifier=card', 1, true),
      'Broken extension omitted')
    books['lb-minitalk.openblock.card'] = { { content = extensionCode } }
    for _, consEnabled in ipairs({ '0', '1' }) do
      for _, blocksEnabled in ipairs({ '0', '1' }) do
        toggles['toggle_lb-minitalk.cons'] = consEnabled
        toggles['toggle_lb-minitalk.openblock'] = blocksEnabled
        local guideline = instructions('test', { guideline = source }).guideline
        test.assertEquals(guideline:find('MiniCons', 1, true) ~= nil, consEnabled == '1',
          'MiniCon mentions match supplied instructions')
        test.assertEquals(guideline:find('OpenBlock', 1, true) ~= nil, blocksEnabled == '1',
          'OpenBlock mentions match supplied instructions')
      end
    end
    toggles['toggle_lb-minitalk.preset'] = '1'
    local sideStory = instructions('test', { guideline = source }).guideline
    test.assertTrue(not sideStory:find('### MiniCons', 1, true)
      and not sideStory:find('### OpenBlocks', 1, true)
      and not sideStory:find('<!-- lb-minitalk-cons-guideline -->', 1, true)
      and not sideStory:find('<!-- lb-minitalk-openblock-guideline -->', 1, true),
      'Side story omits enabled media instructions and their markers')
    toggles['toggle_lb-minitalk.preset'] = '0'
    local consBooks = books['lb-mini.cons']
    local blockBooks = books['lb-minitalk.openblock']
    books['lb-mini.cons'] = nil
    books['lb-minitalk.openblock'] = nil
    local withoutCatalogs = instructions('test', { guideline = source }).guideline
    test.assertTrue(not withoutCatalogs:find('MiniCons', 1, true) and not withoutCatalogs:find('OpenBlock', 1, true),
      'Enabled toggles without catalogs introduce no optional types')
    books['lb-mini.cons'] = consBooks
    books['lb-minitalk.openblock'] = blockBooks
  end)
end)

describe('Messenger rendering', function()
  it('renders room controls, messages, extensions, and safe content from the validated fixture', function()
    listenEdit = function(_, callback)
      display = callback
    end
    require('lb-minitalk/triggers/minitalk')
    html = display('test', block, { index = 9 })
    test.assertEquals(countVisibleSenders(html, '귤두개'), 1, 'Consecutive messages show the sender name once')
    test.assertEquals(countVisibleAvatars(html), 1, 'Consecutive messages show one generated avatar')
    local groupRoom = block:gsub(
      'participants%[2|%]{id|name}:\n  p1|퇴근시켜줘\n  p2|귤두개',
      'participants[4|]{id|name}:\n  p1|퇴근시켜줘\n  p2|귤두개\n  p3|야근왕\n  p4|칼퇴요정')
    local renderedGroupRoom = display('test', groupRoom, { index = 9 })
    test.assertTrue(renderedGroupRoom:find(
      '<p class="lb-minitalk-participants">퇴근시켜줘, 귤두개 외 2명</p>', 1, true),
      'Participant list summarizes names after the first two')
    test.assertTrue(html:find('%-%-lb%-minitalk%-gradient%-seed:%d+'), 'Generated avatar has a nickname seed')
    test.assertTrue(html:find('class="lb-minitalk-message-row"', 1, true)
      and html:find('class="lb-minitalk-time"', 1, true), 'Time renders beside message content')
    test.assertTrue(html:find('<div class="lb-minitalk-openblock"><b>payload</b></div>', 1, true),
      'OpenBlock uses a wrapper without a message bubble')
    test.assertTrue(not html:find('<div class="lb-minitalk-content"><b>payload</b>', 1, true),
      'OpenBlock is not nested in a bubble')
    local outgoingBlock = display('test', block:gsub('p2|openblock:card', 'p1|openblock:card'), { index = 9 })
    test.assertTrue(outgoingBlock:find('<div class="lb-minitalk-openblock"><b>payload</b></div>', 1, true),
      'Outgoing OpenBlock also omits a bubble')
    local renderedCon = display('test', con, { index = 9 })
    test.assertTrue(renderedCon:find('<div class="lb-minitalk-media"><img', 1, true),
      'MiniCon uses a wrapper without a message bubble')
    test.assertTrue(not renderedCon:find('<div class="lb-minitalk-content"><img', 1, true),
      'MiniCon is not nested in a bubble')
    local renderedPause = display('test', pause, { index = 9 })
    test.assertTrue(renderedPause:find('<div class="lb-minitalk-pause">10분 후</div>', 1, true),
      'Pause renders as plain elapsed-time text')
    local pausedConversation = [[<lb-minitalk>
messages[4|]{sender|type|time|content}:
  p2|text|얼마 전|첫 메시지
  p2|text|얼마 전|둘째 메시지
  -|pause|-|10분 후
  p2|text|방금|셋째 메시지
name: 민지
participants[2|]{id|name}:
  p1|퇴근시켜줘
  p2|귤두개
pov: p1
</lb-minitalk>]]
    local renderedPausedConversation = display('test', pausedConversation, { index = 9 })
    test.assertEquals(countVisibleSenders(renderedPausedConversation, '귤두개'), 2,
      'Pause starts a new sender group')
    test.assertEquals(countVisibleAvatars(renderedPausedConversation), 2, 'Pause starts a new avatar group')
    local renderedSkip = display('test', skip, { index = 9 })
    test.assertTrue(renderedSkip:find('<div class="lb-minitalk-skip">생략됨</div>', 1, true),
      'Skip renders as a separator')
    for _, eventType in ipairs({ 'invited', 'exit' }) do
      local event = fixture:gsub('p2|text|방금|찾으면 말해줘', '-|' .. eventType .. '|방금|p2')
      validate('test', event)
      local roundtrip = runtime.decode('test', runtime.extract(output('test', event)).content, true)
      test.assertTrue(roundtrip.messages[6].content == 'p2' and roundtrip.messages[6].type == eventType,
        'Membership event roundtrip')
      rejects(event:gsub('|방금|p2', '|방금|unknown'))
      rejects(event:gsub('|방금|p2', '|방금|민지'))
      rejects(event:gsub('%-|' .. eventType, 'p1|' .. eventType))
      local suffix = eventType == 'invited' and '님을 초대했습니다.' or '님이 퇴장했습니다.'
      local rendered = display('test', event, { index = 9 })
      test.assertTrue(rendered:find('귤두개' .. suffix, 1, true) and rendered:find('lb-minitalk-event', 1, true),
        'Membership event rendered as system row')
      local escaped = display('test', event:gsub('p2|귤두개', 'p2|<b>{{bad}}</b>'), { index = 9 })
      test.assertTrue(not escaped:find('<b>', 1, true) and not escaped:find('{{bad}}', 1, true),
        'Membership participant name escaped')
    end
    test.assertTrue(not html:find('<lb-minitalk>', 1, true), 'Data node replaced')
    test.assertTrue(display('test', con, { index = 9 }):find('{{raw::wave}}', 1, true), 'Shared MiniCon assets')
    toggles['toggle_lb-minitalk.cons'] = '0'
    test.assertTrue(display('test', con, { index = 9 }):find('{{raw::wave}}', 1, true),
      'Disabled MiniCons still rendered')
    test.assertTrue(not instructions('test', { guideline = source }).guideline:find('### MiniCons', 1, true),
      'Disabled MiniCon prompt omitted')
    toggles['toggle_lb-minitalk.openblock'] = '0'
    local disabledBlock = display('test', block, { index = 9 })
    test.assertTrue(disabledBlock:find('lb-minitalk-openblock-fallback', 1, true)
      and not disabledBlock:find('payload', 1, true), 'Disabled OpenBlock uses an opaque fallback')
    local hostile = fixture:gsub('찾으면 말해줘', '<script>{{button::x::bad}}</script>')
    local safe = display('test', hostile, { index = 9 })
    test.assertTrue(not safe:find('<script>', 1, true) and not safe:find('{{button', 1, true), 'HTML and CBS escaped')
    toggles['toggle_lb-minitalk.renderer'] = '1'
    books['lb-minitalk.renderer'] = { { content = 'return function() return "<div>custom</div>" end' } }
    test.assertEquals(display('test', roomFixture, { index = 9 }), '<div>custom</div>', 'Custom renderer selected')
    books['lb-minitalk.renderer'] = { { content = 'return function() error("broken") end' } }
    test.assertTrue(display('test', fixture, { index = 9 }):find('lb-minitalk-dialog', 1, true),
      'Custom failure fallback')
    test.assertEquals(display('test', fixture, { index = 0 }), fixture, 'Old display skipped')
    toggles['toggle_lb-minitalk.renderer'] = '0'
    local outgoing = fixture:gsub('p2|text|방금|찾으면', 'p1|text|방금|찾으면')
    test.assertTrue(display('test', outgoing, { index = 9 }):find('data-self="true"', 1, true),
      'Viewpoint bubble aligned right')
  end)
end)

describe('Messenger mutation', function()
  it('applies interaction patches to the shared rendered fixture while preserving valid history', function()
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
    apply = function(ops, previous)
      operations = ops
      validate('test', patchOutput)
      return mutate('test', 'interaction', 'before' .. patchOutput .. 'after', {
        output = patchOutput,
        previousNode = previous,
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
    operations = { { op = 'move', path = '/messages/0' } }
    rejects(patchOutput)
    rejects('<lb-minitalk-patch>invalid</lb-minitalk-patch>')
    success = pcall(apply, { { op = 'replace', path = '/pov', value = 'unknown' } }, previous)
    test.assertTrue(not success, 'Invalid patched room rejected')
    success = pcall(apply, { { op = 'remove', path = '/messages/99' } }, previous)
    test.assertTrue(not success, 'Invalid patch path rejected')
    test.assertEquals(mutate('test', 'reroll', fixture), fixture, 'Reroll unchanged')
  end)
end)

describe('Messenger key-figure state', function()
  it('merges key-figure updates into cached state without storing them in the room', function()
    validate('test', roomFixture)
    rejects(fixture:gsub('민지|귤두개|모두에게 짧게 연속 전송하며 정정은 새 메시지로 보냄', '민지|귤두개'))
    local stored = output('test', fixture)
    local preserved = variables['lb-minitalk.keyfigures']
    test.assertEquals(output('test', roomFixture), normalized, 'Missing key figures accepted')
    test.assertEquals(variables['lb-minitalk.keyfigures'], preserved, 'Missing key figures preserve state')
    test.assertTrue(stored:find('keyFigures', 1, true) == nil, 'Key figures removed from stored room output')
    test.assertEquals(#runtime.decode('test', runtime.extract(stored).content, false).keyFigures, 1,
      'Stored room hydrates key figures from cached state')
    local guideline = instructions('test', { guideline = source }).guideline
    test.assertTrue(guideline:find('{{getvar::lb-minitalk.keyfigures}}', 1, true) ~= nil
      and guideline:find('<previous-key-figures>', 1, true) ~= nil,
      'Preserved mappings use CBS in the core guideline')
    patchOutput = '<lb-minitalk-patch>fixture</lb-minitalk-patch>'
    success = pcall(apply, {
      { op = 'replace', path = '/keyFigures/0/note', value = 'changed style' },
    }, runtime.extract(stored))
    test.assertTrue(not success, 'Interaction patch cannot target consumed key figures')
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
    test.assertEquals(instructions('test', { guideline = '' }).guideline, '',
      'Instruction preprocessing does not inject key figures')
  end)
end)

test.printSummary()
