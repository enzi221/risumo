local CONS_EXAMPLE_MARKER = '<!-- lb-mini-cons-example -->'
local CONS_GUIDELINE_MARKER = '<!-- lb-mini-cons-guideline -->'

local function replaceMarker(text, marker, replacement)
  return text:gsub(prelude.escMatch(marker), function()
    return replacement
  end)
end

local function collectCons(triggerId)
  if getGlobalVar(triggerId, 'toggle_lb-mini.cons') ~= '1' then
    return ''
  end

  local contents = {}
  local lorebooks = getLoreBooks(triggerId, 'lb-mini.cons') or {}

  for _, lorebook in ipairs(lorebooks) do
    local content = prelude.trim(lorebook.content or '')
    if content ~= '' then
      table.insert(contents, content)
    end
  end

  return table.concat(contents, '\n\n')
end

---@param triggerId string
---@return string
local function main(triggerId, instructions)
  local cons = collectCons(triggerId)
  local example = ''
  local guideline = ''

  if cons ~= '' then
    guideline = [[## MiniCons

MiniCons are small square reaction images that comment authors can post, similar to 디씨콘 or 아카콘. Authors may use MiniCons as a relevant reaction or as a context-free 뻘댓글. Some posts may only has con comments, some only texts, some mixed. Other authors may react to the cons as well. In short, emulate how real 디씨콘 or 아카콘 are used.

Write a MiniCon comment as exactly `[con:identifier]` or `[con:identifier,identifier]`. Duplicate identifiers allowed. A comment may contain 1-2 MiniCons and nothing else. Do not put spaces between identifiers. Use MiniCons only in comments. If authors want to post both text and cons, they add two separate comments; one with only the cons, another with the text.

Use only the identifiers provided below:

]] .. cons

    example = [[
A comment with cons:

```toon
comments[1|]{author|time|content}:
⇥⇥⇥...|...|[con:identifier1,identifier2]
```
]]
  end

  instructions.guideline = replaceMarker(instructions.guideline, CONS_GUIDELINE_MARKER, guideline)
  instructions.guideline = replaceMarker(instructions.guideline, CONS_EXAMPLE_MARKER, example)

  return instructions
end

return main
