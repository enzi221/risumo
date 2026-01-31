local str = 'a\n\nb\n\nc'
local a = 0

print(str:gsub('\n\n', function()
  a = a + 1
  return '\n\n[Slot ' .. tostring(a) .. ']'
end))
