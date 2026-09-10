local test = require('test')
local applyJSONPatch = require('json-patch')

local describe = test.describe
local it = test.it
local assertDeepEquals = test.assertDeepEquals
local assertFails = test.assertFails

describe('add', function()
  it('appends an array value', function()
    local original = {
      posts = {
        {
          comments = {},
          title = 'First',
        },
      },
    }
    local patched = applyJSONPatch(original, {
      {
        op = 'add',
        path = '/posts/0/comments/-',
        value = {
          author = 'User',
          content = 'New comment',
        },
      },
    })

    assertDeepEquals(patched.posts[1].comments, {
      {
        author = 'User',
        content = 'New comment',
      },
    }, 'append with -')
    assertDeepEquals(original.posts[1].comments, {}, 'preserve the original document')
  end)

  it('inserts an array value at a zero-based index', function()
    local patched = applyJSONPatch({ posts = { 'second' } }, {
      {
        op = 'add',
        path = '/posts/0',
        value = 'first',
      },
    })
    assertDeepEquals(patched.posts, { 'first', 'second' }, 'insert at array index')
  end)

  it('adds an object member', function()
    local patched = applyJSONPatch({ board = {} }, {
      {
        op = 'add',
        path = '/board/name',
        value = 'Miniboard',
      },
    })
    assertDeepEquals(patched, { board = { name = 'Miniboard' } }, 'add object member')
  end)

  it('uses - as an object key outside arrays', function()
    local patched = applyJSONPatch({ board = { name = 'Miniboard' } }, {
      {
        op = 'add',
        path = '/board/-',
        value = 'value',
      },
    })
    assertDeepEquals(patched.board, { ['-'] = 'value', name = 'Miniboard' }, 'add - object member')
  end)
end)

describe('remove and replace', function()
  it('applies operations against the current patched state', function()
    local patched = applyJSONPatch({ values = { 'a', 'b', 'c' } }, {
      {
        op = 'remove',
        path = '/values/0',
      },
      {
        op = 'replace',
        path = '/values/0',
        value = 'updated',
      },
    })
    assertDeepEquals(patched.values, { 'updated', 'c' }, 'use sequential array indexes')
  end)

  it('replaces the document root', function()
    local patched = applyJSONPatch({ old = true }, {
      {
        op = 'replace',
        path = '',
        value = {
          name = 'New board',
          posts = {},
        },
      },
    })
    assertDeepEquals(patched, { name = 'New board', posts = {} }, 'replace root')
  end)
end)

describe('JSON Pointer', function()
  it('decodes escaped object keys', function()
    local patched = applyJSONPatch({ data = { ['a/b'] = 1, ['m~n'] = 2 } }, {
      {
        op = 'replace',
        path = '/data/a~1b',
        value = 3,
      },
      {
        op = 'replace',
        path = '/data/m~0n',
        value = 4,
      },
    })
    assertDeepEquals(patched.data, { ['a/b'] = 3, ['m~n'] = 4 }, 'decode ~1 and ~0')
  end)
end)

describe('validation', function()
  it('rejects unsupported operations', function()
    assertFails(function()
      applyJSONPatch({}, {
        {
          op = 'move',
          path = '/value',
        },
      })
    end, 'op must be add, remove, or replace', 'reject unsupported op')
  end)

  it('rejects missing targets', function()
    assertFails(function()
      applyJSONPatch({}, {
        {
          op = 'replace',
          path = '/missing',
          value = true,
        },
      })
    end, 'path does not exist', 'reject missing replace target')
  end)

  it('rejects out-of-bounds array indexes', function()
    assertFails(function()
      applyJSONPatch({ values = { 'a' } }, {
        {
          op = 'add',
          path = '/values/2',
          value = 'b',
        },
      })
    end, 'array add index is out of bounds', 'reject invalid add index')
  end)

  it('rejects invalid pointer escapes', function()
    assertFails(function()
      applyJSONPatch({}, {
        {
          op = 'add',
          path = '/invalid~2key',
          value = true,
        },
      })
    end, 'invalid JSON Pointer escape', 'reject invalid escape')
  end)
end)

test.printSummary()
