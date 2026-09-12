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
---@param keyFigures table[]
local function preserveKeyFigures(triggerId, keyFigures)
  if getGlobalVar(triggerId, 'toggle_lb-mini.keyfigures') ~= '1' then
    return
  end
  if #keyFigures == 0 then
    return
  end

  prelude.import(triggerId, 'toon.decode')
  prelude.import(triggerId, 'toon.encode')
  local preserved = getChatVar(triggerId, KEYFIGURES_VARIABLE)
  local entries = {}
  if type(preserved) == 'string' and prelude.trim(preserved) ~= '' and preserved ~= 'null' then
    local success, decoded = pcall(prelude.toon.decode, preserved)
    if success and type(decoded) == 'table' then
      entries = decoded
    end
  end

  local indices = {}
  for index, entry in ipairs(entries) do
    indices[entry.keyFigure] = index
  end
  for _, entry in ipairs(keyFigures) do
    local index = indices[entry.keyFigure]
    if index then
      entries[index] = entry
    else
      table.insert(entries, entry)
      indices[entry.keyFigure] = #entries
    end
  end

  local content = prelude.toon.encode(entries, { delimiter = '|' })

  if preserved ~= content then
    setChatVar(triggerId, KEYFIGURES_VARIABLE, content)
  end
end

local function encodeData(triggerId, data)
  prelude.import(triggerId, 'toon.encode')
  local posts = data.posts or {}
  local root = setmetatable({
    posts = #posts > 0 and posts or nil,
  }, { __toonKeyOrder = { 'posts' } })
  local prefix = ''
  if #posts == 0 then
    prefix = prefix .. 'posts[0|]:\n'
  end
  return prefix .. prelude.toon.encode(root, { delimiter = '|' })
end

local function main(triggerId, output)
  local patchNodes = prelude.queryNodes('lb-mini-patch', output)
  if #patchNodes > 0 then
    return output:sub(patchNodes[#patchNodes].rangeStart, patchNodes[#patchNodes].rangeEnd)
  end

  if not string.find(output, '<lb%-mini[%s>/]') then
    return nil
  end

  if not string.find(output, "</lb%-mini>") then
    output = output .. '\n</lb-mini>'
  end

  local nodes = prelude.queryNodes('lb-mini', output)
  local node = nodes[#nodes]
  local extracted = output:sub(node.rangeStart, node.rangeEnd)
  local success, data = pcall(prelude.toon.decode, node.content)
  if not success then
    return extracted
  end

  data.keyFigures = data.keyFigures or {}
  normalizeCons(data.posts)
  preserveKeyFigures(triggerId, data.keyFigures)

  local openTag = extracted:match('^(<lb%-mini[^>]*>)')
  if not openTag then
    return extracted
  end

  local content = encodeData(triggerId, data)
  return openTag .. '\n' .. content .. '\n</lb-mini>'
end

return main
