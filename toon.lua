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
  - camera: upper body
    characters[1|]{positive|negative}:
      girl, adolescent, chin-length blue hair, asymmetric bangs, turquoise eyes, fair skin, blush, black newsboy cap, black hairpins, charcoal gray mini one-piece, white shirt, teal belt, standing, earnest, holding object, hands together, offering cassette tape, looking at viewer|
    scene: 1girl, exterior, city, city square, daylight, afternoon
    slot: 5
  - camera: cowboy shot
    characters[1|]{positive|negative}:
      girl, female, short dark brown hair, gray eyes, tan skin, athletic, black tactical jacket, orange armband, gray cropped turtleneck, cargo pants, utility belt, holster, standing, walking, cynical, indifferent, looking at other|
    scene: 1girl, exterior, city, city square, daylight, afternoon
    slot: 12
keyvis:
  camera: cowboy shot
  characters[1|]{positive|negative}:
      girl, adolescent, chin-length blue hair, asymmetric bangs, turquoise eyes, fair skin, blush, black newsboy cap, black hairpins, charcoal gray mini one-piece, white shirt, teal belt, standing, nervous, looking at other, clutching cassette tape|
  scene: 1girl, exterior, city, city square, public square, concrete buildings, daylight, shadow, 1.2::depth of field::]]

print(tableToString(toon.decode(x)))
