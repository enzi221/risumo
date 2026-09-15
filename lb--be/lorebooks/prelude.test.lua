local test = require('test')

local books = {}

getLoreBooks = function(_, name)
  return books[name] or {}
end

local prelude = require('prelude')

test.describe('Prelude lore book lookup', function()
  test.it('resolves single-level requires without changing source lore books', function()
    books.nested = { { content = 'nested' } }
    books.shared = { { content = 'text <!-- lb:require:nested -->' } }
    books.target = { { content = 'Before <!-- lb:require:shared --> after' } }

    local resolved = assert(prelude.getPriorityLoreBook('test', 'target'))
    test.assertEquals(resolved.content, 'Before text <!-- lb:require:nested --> after',
      'Resolve one require level')
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
end)

test.printSummary()
