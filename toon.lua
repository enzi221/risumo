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
  - camera: straight-on, upper body
    characters[1]:
      - positive: girl, female, young adult, long brown straight hair, sidelocks, ahoge, brown eyes, tareme, fair skin, large breasts, black jacket, open jacket, white shirt, black pencil skirt, black tie, sitting, hands together, holding cup, looking away, relaxed, focused
        negative: 
    scene: 1girl, interior, cafe, round table, daylight, noon, sidelighting, tea, pouch, pen
    slot: 1
  - camera: pov, from slightly above, upper body
    characters[1]:
      - positive: girl, female, young adult, long brown straight hair, sidelocks, ahoge, brown eyes, tareme, fair skin, large breasts, black jacket, open jacket, white shirt, black pencil skirt, black tie, sitting, holding fork, hands forward, pushing plate, blush, embarrassed, smiling, looking at viewer, source#offering food
        negative: 
    scene: 1girl, interior, cafe, round table, daylight, noon, cheesecake, tea, cake fork
    slot: 7
keyvis:
  camera: pov, from above, upper body
  characters[1]:
    - positive: girl, female, young adult, long brown straight hair, sidelocks, ahoge, brown eyes, tareme, fair skin, large breasts, black jacket, open jacket, white shirt, black pencil skirt, black tie, sitting, holding fork, hands forward, blush, looking at viewer, source#offering food
      negative: 
  scene: 1girl, interior, cafe, round table, daylight, noon, cheesecake, tea, focus on intimacy]]

print(tableToString(toon.decode(x)))
