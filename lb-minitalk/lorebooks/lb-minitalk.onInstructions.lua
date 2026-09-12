local CONS_MARKER = '<!-- lb-minitalk-cons-guideline -->'
local OPENBLOCK_MARKER = '<!-- lb-minitalk-openblock-guideline -->'

local function collectLorebooks(triggerId, name)
  local contents = {}
  local lorebooks = getLoreBooks(triggerId, name) or {}

  for _, lorebook in ipairs(lorebooks) do
    local content = prelude.trim(lorebook.content or '')
    if content ~= '' then
      table.insert(contents, content)
    end
  end

  return table.concat(contents, '\n\n')
end

local function replaceMarker(text, marker, replacement)
  return text:gsub(prelude.escMatch(marker), function()
    return replacement
  end)
end

local function main(triggerId, instructions)
  local cons = ''
  if getGlobalVar(triggerId, 'toggle_lb-minitalk.cons') == '1' then
    cons = collectLorebooks(triggerId, 'lb-mini.cons')
  end

  local consGuideline = ''
  if cons ~= '' then
    consGuideline = [[### MiniCons

MiniCons are small square stickers/emoticons that participants can post instead of a text message. They may use MiniCons as a relevant reaction or as a context-free 뻘글. Others may react to the cons as well. In short, emulate how real stickers/emoticons are used.

Set `type` to `con` and write exactly one identifier from the catalog in `content`. Send additional MiniCons as separate messages. Send accompanying text as a separate message if any. Choose reaction images according to the sender's habits and the conversation; do not force their use.

Use only the identifiers in this catalog:

]] .. cons
  end

  local runtime = prelude.import(triggerId, 'lb-minitalk.runtime')
  local definitions = {}
  local extensions = runtime.openblocks(triggerId)
  local identifiers = {}
  for identifier in pairs(extensions) do
    table.insert(identifiers, identifier)
  end
  table.sort(identifiers)
  for _, identifier in ipairs(identifiers) do
    table.insert(definitions, 'identifier=' .. identifier .. '\n' .. extensions[identifier].description)
  end
  local openblocks = table.concat(definitions, '\n\n')
  local openblockGuideline = ''
  if openblocks ~= '' then
    openblockGuideline = [[### OpenBlocks

Treat each OpenBlock as one complete sent message. Set `type` to `openblock:identifier`, replacing `identifier` with an exact identifier from the definitions below. Write `content` as a string in that definition's payload format. Apply TOON string quoting and escaping to the complete payload, including any embedded delimiters, quotes, or line breaks.

Use these definitions:

]] .. openblocks
  end

  instructions.guideline = replaceMarker(instructions.guideline, CONS_MARKER, consGuideline)
  instructions.guideline = replaceMarker(instructions.guideline, OPENBLOCK_MARKER, openblockGuideline)

  return instructions
end

return main
