-- Base64 encoding function (helper)
local function base64Encode(data)
  local b = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'
  return ((data:gsub('.', function(x)
    local r, b = '', x:byte()
    for i = 8, 1, -1 do r = r .. (b % 2 ^ i - b % 2 ^ (i - 1) > 0 and '1' or '0') end
    return r
  end) .. '0000'):gsub('%d%d%d?%d?%d?%d?', function(x)
    if (#x < 6) then return '' end
    local c = 0
    for i = 1, 6 do c = c + (x:sub(i, i) == '1' and 2 ^ (6 - i) or 0) end
    return b:sub(c + 1, c + 1)
  end) .. ({ '', '==', '=' })[#data % 3 + 1])
end

local function xor(str)
  local result = {}
  for i = 1, #str do
    local byte = string.byte(str, i)
    table.insert(result, byte ~ 0xFF) -- XOR with 0xFF
  end

  -- Convert to base64
  local bytes = string.char(table.unpack(result))
  return base64Encode(bytes)
end

local function main(triggerId, output)
  local resolve = prelude.import(triggerId, 'lb-stage.state')
  local data = resolve(triggerId, output)
  prelude.import(triggerId, 'toon.encode')
  local content = prelude.toon.encode(data, { delimiter = '|' })
  return '<lb-stage>' .. xor(content) .. '</lb-stage>'
end

return main
