_ENV.prelude = {}

local toon = require('toon.decode')

local function tableToString(t, indent)
  indent = indent or 0
  if type(t) ~= "table" then
    return tostring(t)
  end
  local pad = string.rep("  ", indent)
  local padInner = string.rep("  ", indent + 1)
  local str = "{\n"
  local first = true
  for k, v in pairs(t) do
    if not first then str = str .. ",\n" end
    first = false
    str = str .. padInner .. "[" .. tostring(k) .. "] = "
    if type(v) == "table" then
      str = str .. tableToString(v, indent + 1)
    else
      str = str .. tostring(v)
    end
  end
  return str .. "\n" .. pad .. "}"
end

local x = [[scenes[2]:
  - camera: upper body, straight-on
    characters[1|]{positive|negative}:
      girl, adolescent, shoulder-length straight black hair, dark eyes, slender, small breasts, oversized navy hoodie, heart-shaped face, silver necklace, sitting, hands on lap, staring, looking away, indifferent, blank stare|
    scene: 1girl, interior, convenience store, night, fluorescent lighting, table, window
    slot: 3
  - camera: upper body, from side
    characters[1|]{positive|negative}:
      girl, adolescent, shoulder-length straight black hair, dark eyes, slender, small breasts, oversized navy hoodie, pouting, annoyed, looking away, glaring, sitting, arms crossed|
    scene: 1girl, interior, convenience store, night, artificial lighting, microwave in background
    slot: 10
keyvis:
  camera: cowboy shot, from side, dutch angle
  characters[1|]{positive|negative}:
      girl, adolescent, shoulder-length straight black hair, dark eyes, slender, small breasts, oversized navy hoodie, blue jeans, black sneakers, heart-shaped face, silver necklace, sitting at counter, pouting, tucking hair behind ear, looking away, embarrassed|
  scene: 1girl, interior, convenience store, night, fluorescent lighting, plastic table, glass window, reflection]]

print(tableToString(toon.decode(x)))
