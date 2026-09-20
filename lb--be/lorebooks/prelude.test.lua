local test = require('test')

local books = {}

getLoreBooks = function(_, name)
  return books[name] or {}
end

local prelude = require('prelude')

test.describe('Prelude lore book lookup', function()
  test.it('resolves nested requires without changing source lore books', function()
    books.nested = { { content = 'nested' } }
    books.shared = { { content = 'text <!-- lb:require:nested -->' } }
    books.target = { { content = 'Before <!-- lb:require:shared --> after' } }

    local resolved = assert(prelude.getPriorityLoreBook('test', 'target'))
    test.assertEquals(resolved.content, 'Before text nested after', 'Resolve nested requires')
    test.assertEquals(books.target[1].content, 'Before <!-- lb:require:shared --> after',
      'Keep source content unchanged')
  end)

  test.it('resolves every lore book while preserving lookup order', function()
    books.shared = {
      { content = 'first' },
      { content = '' },
      { content = 'second' },
      {},
    }
    books.target = {
      { content = '<!-- lb:require:all:shared -->', insertorder = 1 },
      { content = '<!-- lb:require:missing -->', insertorder = 2 },
    }

    local resolved = prelude.getLoreBooks('test', 'target')
    test.assertEquals(#resolved, 2, 'Keep every matched lore book')
    test.assertEquals(resolved[1].content, 'first\n\nsecond', 'Resolve all matches in lookup order')
    test.assertEquals(resolved[2].content, '', 'Replace a missing require with empty content')
    test.assertEquals(prelude.getPriorityLoreBook('test', 'target').content, '',
      'Resolve the highest insert order lore book')
  end)

  test.it('stops circular requires and requires deeper than five levels', function()
    books.cycleA = { { content = 'A<!-- lb:require:cycleB -->' } }
    books.cycleB = { { content = 'B<!-- lb:require:cycleA -->' } }
    books.level1 = { { content = '1<!-- lb:require:level2 -->' } }
    books.level2 = { { content = '2<!-- lb:require:level3 -->' } }
    books.level3 = { { content = '3<!-- lb:require:level4 -->' } }
    books.level4 = { { content = '4<!-- lb:require:level5 -->' } }
    books.level5 = { { content = '5<!-- lb:require:level6 -->' } }
    books.level6 = { { content = '6' } }
    books.depthTarget = { { content = '<!-- lb:require:level1 -->' } }

    test.assertEquals(prelude.getPriorityLoreBook('test', 'cycleA').content, 'AB',
      'Drop a circular require at the repeated lore book')
    test.assertEquals(prelude.getPriorityLoreBook('test', 'depthTarget').content, '12345',
      'Drop requires beyond five levels')
  end)
end)

test.printSummary()
