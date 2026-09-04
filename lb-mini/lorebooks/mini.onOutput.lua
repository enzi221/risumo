local MAX_CONS = 2
local KEYFIGURES_VARIABLE = 'lb-mini.keyfigures'

---@param content any
---@return any
local function removeCons(content)
  if type(content) ~= 'string' then
    return content
  end

  local cleaned = content:gsub('[ \t]*%[con:[^%]]*%][ \t]*', ' (콘 제거됨) ')
  return prelude.trim(cleaned)
end

---@param content any
---@return any
local function truncateCons(content)
  if type(content) ~= 'string' then
    return content
  end

  local value = content:match('^%s*%[con:([^%]]+)%]%s*$')
  if not value then
    return content
  end

  local identifiers = {}
  for identifier in (value .. ','):gmatch('(.-),') do
    table.insert(identifiers, identifier)
  end

  while #identifiers > MAX_CONS do
    table.remove(identifiers)
  end

  return '[con:' .. table.concat(identifiers, ',') .. ']'
end

---@param posts MiniboardPostData[]
local function normalizeCons(posts)
  for _, post in ipairs(posts) do
    post.content = removeCons(post.content)

    for _, comment in ipairs(post.comments or {}) do
      comment.content = truncateCons(comment.content)
    end
  end
end

---@param triggerId string
---@param output string
local function preserveKeyFigures(triggerId, output)
  if getGlobalVar(triggerId, 'toggle_lb-mini.keyfigures') ~= '1' then
    return
  end

  local nodes = prelude.queryNodes('lb-mini-keyfigures', output)
  if #nodes == 0 then
    return
  end

  local keyFigures = prelude.trim(nodes[#nodes].content)
  if keyFigures == '[0|]:' then
    keyFigures = ''
  end

  if getChatVar(triggerId, KEYFIGURES_VARIABLE) ~= keyFigures then
    setChatVar(triggerId, KEYFIGURES_VARIABLE, keyFigures)
  end
end

local function main(triggerId, output)
  if not string.find(output, '<lb%-mini[%s>/]') then
    return nil
  end

  if not string.find(output, "</lb%-mini>") then
    local keyFiguresStart = string.find(output, '<lb%-mini%-keyfigures[%s>/]')
    if keyFiguresStart then
      output = output:sub(1, keyFiguresStart - 1)
          .. '</lb-mini>\n'
          .. output:sub(keyFiguresStart)
    else
      output = output .. '\n</lb-mini>'
    end
  end

  local nodes = prelude.queryNodes('lb-mini', output)
  local node = nodes[#nodes]
  local extracted = output:sub(node.rangeStart, node.rangeEnd)
  local success, posts = pcall(prelude.toon.decode, node.content)
  if not success then
    return extracted
  end

  preserveKeyFigures(triggerId, output)
  normalizeCons(posts)

  local openTag = extracted:match('^(<lb%-mini[^>]*>)')
  if not openTag then
    return extracted
  end

  local content = prelude.toon.encode(posts, { delimiter = '|' })
  return openTag .. '\n' .. content .. '\n</lb-mini>'
end

return main
