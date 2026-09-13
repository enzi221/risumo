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
local toggles = {
  ['toggle_lb-mini.keyfigures'] = '1',
}
local variables = {}

getChatVar = function(_, name)
  return variables[name]
end
setChatVar = function(_, name, value)
  variables[name] = value
end
getGlobalVar = function(_, name)
  return toggles[name] or '0'
end
getLoreBooks = function(_, name)
  return books[name] or {}
end

prelude = require('prelude')
for _, name in ipairs({ 'decode', 'encode' }) do
  books['toon.' .. name] = { { content = read('lb--be/lorebooks/toon.' .. name .. '.lua') } }
end
prelude.import('test', 'toon.decode')
prelude.import('test', 'toon.encode')

local output = require('lb-mini/lorebooks/mini.onOutput')
local mutate = require('lb-mini/lorebooks/mini.onMutation')
local validate = require('lb-mini/lorebooks/mini.onValidate')
local operations = {}

json = {
  decode = function(value)
    if value ~= 'fixture' then
      error('Invalid JSON fixture')
    end
    return operations
  end,
}

local generated = [[<lb-mini name="test">
keyFigures[1|]{keyFigure|nickname|note}:
  Dante|시계대가리|무심한 말투
posts[1|]:
  - author: 시계대가리
    title: 제목
    time: 방금
    upvotes: 1
    downvotes: 0
    content: 본문
    comments[1|]{author|time|content}:
      도끼자루|방금|댓글
</lb-mini>]]

describe('Miniboard key-figure state', function()
  it('consumes key figures into cached state without storing them in the board', function()
    validate('test', generated)
    local stored = output('test', generated)
    local preserved = variables['lb-mini.keyfigures']
    test.assertTrue(type(preserved) == 'string' and preserved:find('시계대가리', 1, true) ~= nil,
      'Generated key figures cached')
    test.assertTrue(stored:find('keyFigures', 1, true) == nil, 'Key figures removed from stored board output')

    local noUpdates = generated:gsub(
      'keyFigures%[1|%]{keyFigure|nickname|note}:\n  [^\n]+',
      'keyFigures[0|]:')
    output('test', noUpdates)
    test.assertEquals(variables['lb-mini.keyfigures'], preserved, 'Empty key-figure updates preserve cached state')

    local added = generated:gsub(
      'keyFigures%[1|%]{keyFigure|nickname|note}:\n  [^\n]+',
      'keyFigures[1|]{keyFigure|nickname|note}:\n  Vergilius|베르|단호한 말투')
    output('test', added)
    local merged = prelude.toon.decode(variables['lb-mini.keyfigures'])
    test.assertEquals(#merged, 2, 'New key-figure updates merge into cached state')
    local mergedPreserved = variables['lb-mini.keyfigures']

    local previousNode = prelude.queryNodes('lb-mini', stored)[1]
    previousNode.raw = stored
    local decoded = prelude.toon.decode(previousNode.content)
    test.assertEquals(#decoded.posts, 1, 'Stored posts remain decodable')

    operations = { {
      op = 'replace',
      path = '/posts/0/upvotes',
      value = 2,
    } }
    local patch = '<lb-mini-patch>fixture</lb-mini-patch>'
    local updated = mutate('test', 'interaction', patch, {
      output = patch,
      previousNode = previousNode,
    })
    test.assertTrue(updated:find('keyFigures', 1, true) == nil, 'Mutation keeps key figures out of board output')
    test.assertEquals(variables['lb-mini.keyfigures'], mergedPreserved, 'Mutation preserves cached key figures')

    variables['lb-mini.keyfigures'] = '[1|]:\n  - nickname: 레거시\n    note: 이전형식'
    output('test', added)
    local recovered = prelude.toon.decode(variables['lb-mini.keyfigures'])
    test.assertEquals(#recovered, 1, 'Malformed or legacy cached key figures are safely ignored')
    test.assertEquals(recovered[1].keyFigure, 'Vergilius', 'Valid incoming update is preserved')

    local legacyBlock = '<lb-mini name="테스트">\n[1|]:\n  - author: 구버전\n    title: 구제목\n    time: 방금\n    upvotes: 1\n    downvotes: 0\n    content: 구본문\n    comments[0|]:\n</lb-mini>'
    local legacyPreviousNode = prelude.queryNodes('lb-mini', legacyBlock)[1]
    legacyPreviousNode.raw = legacyBlock
    local legacyPatched = mutate('test', 'interaction', patch, {
      output = patch,
      previousNode = legacyPreviousNode,
    })
    local decodedLegacyPatched = prelude.toon.decode(prelude.queryNodes('lb-mini', legacyPatched)[1].content)
    test.assertEquals(decodedLegacyPatched.posts[1].upvotes, 2, 'Legacy previous node can be mutated')
  end)
end)

test.printSummary()
