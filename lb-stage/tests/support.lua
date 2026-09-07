local function readFile(path)
  local file = assert(io.open(path, 'r'))
  local text = file:read('*a')
  file:close()
  return text
end

local books = {
  ['lb-stage.lb.onInput'] = 'lb-stage/lorebooks/stage.onInput.lua',
  ['lb-stage.state'] = 'lb-stage/lorebooks/stage.state.lua',
  ['toon.decode'] = 'lb--be/lorebooks/toon.decode.lua',
  ['toon.encode'] = 'lb--be/lorebooks/toon.encode.lua',
}

function getLoreBooks(_, name)
  return { { content = readFile(assert(books[name], name)) } }
end

null = {}
package.preload['./json-patch'] = function()
  return dofile('lb--be/lorebooks/json-patch.lua')
end
dofile('lb--be/lorebooks/prelude.lua')
prelude.import('test', 'toon.decode')
prelude.import('test', 'toon.encode')

return { readFile = readFile }
