local MAX_CONS = 2

local function parseCons(content)
  if type(content) ~= 'string' then
    return nil
  end

  local value = content:match('^%s*%[con:([^%]]+)%]%s*$')
  if not value then
    return nil
  end

  local identifiers = {}
  for identifier in value:gmatch('[^,]+') do
    if not identifier:match('^[%w._/%-]+$') then
      return nil
    end
    table.insert(identifiers, identifier)
  end

  if #identifiers < 1 or table.concat(identifiers, ',') ~= value then
    return nil
  end

  return identifiers
end

---@param value any
---@return boolean
local function denseArray(value)
  if type(value) ~= 'table' then
    return false
  end

  local count = 0
  for key in pairs(value) do
    if type(key) ~= 'number' or key < 1 or key % 1 ~= 0 then
      return false
    end
    count = count + 1
  end
  return count == #value
end

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

---@param posts table[]
local function normalizeCons(posts)
  for _, post in ipairs(posts) do
    post.content = removeCons(post.content)

    for _, comment in ipairs(post.comments) do
      comment.content = truncateCons(comment.content)
    end
  end
end

---@param posts table[]
local function validateCons(posts)
  for _, post in ipairs(posts) do
    if post.content:find('[con:', 1, true) then
      error('Invalid patched miniboard: cons may only appear in comments.')
    end

    for _, comment in ipairs(post.comments) do
      if comment.content:find('[con:', 1, true) and not parseCons(comment.content) then
        error('Invalid patched miniboard: con comments must use safe asset identifiers.')
      end
    end
  end
end

---@param value any
---@param label string
local function requireString(value, label)
  if type(value) ~= 'string' then
    error('Invalid patched miniboard: ' .. label .. ' must be a string.')
  end
end

---@param value any
---@param label string
local function requireNumber(value, label)
  if type(value) ~= 'number' then
    error('Invalid patched miniboard: ' .. label .. ' must be a number.')
  end
end

---@param board any
local function validateBoard(board)
  if type(board) ~= 'table' then
    error('Invalid patched miniboard: root must be an object.')
  end
  requireString(board.name, 'name')
  if board.name == '' then
    error('Invalid patched miniboard: name must not be empty.')
  end
  if not denseArray(board.posts) then
    error('Invalid patched miniboard: posts must be an array.')
  end

  for postIndex, post in ipairs(board.posts) do
    local postLabel = 'posts[' .. tostring(postIndex - 1) .. ']'
    if type(post) ~= 'table' then
      error('Invalid patched miniboard: ' .. postLabel .. ' must be an object.')
    end

    requireString(post.author, postLabel .. '.author')
    requireString(post.content, postLabel .. '.content')
    requireNumber(post.downvotes, postLabel .. '.downvotes')
    requireString(post.time, postLabel .. '.time')
    requireString(post.title, postLabel .. '.title')
    requireNumber(post.upvotes, postLabel .. '.upvotes')

    if not denseArray(post.comments) then
      error('Invalid patched miniboard: ' .. postLabel .. '.comments must be an array.')
    end
    for commentIndex, comment in ipairs(post.comments) do
      local commentLabel = postLabel .. '.comments[' .. tostring(commentIndex - 1) .. ']'
      if type(comment) ~= 'table' then
        error('Invalid patched miniboard: ' .. commentLabel .. ' must be an object.')
      end
      requireString(comment.author, commentLabel .. '.author')
      requireString(comment.content, commentLabel .. '.content')
      requireString(comment.time, commentLabel .. '.time')
    end
  end
end

---@param value string
---@return string
local function escapeAttribute(value)
  return value:gsub('&', '&amp;'):gsub('"', '&quot;'):gsub('<', '&lt;'):gsub('>', '&gt;')
end

---@param previousNode MutationNode?
---@param name string
---@return string
local function createOpenTag(previousNode, name)
  local openTag = previousNode and previousNode.raw:match('^(<lb%-mini[^>]*>)') or '<lb-mini>'
  if previousNode and name == previousNode.attributes.name then
    return openTag
  end

  local escapedName = escapeAttribute(name)
  local count
  openTag, count = openTag:gsub('(%sname%s*=%s*)"[^"]*"', function(prefix)
    return prefix .. '"' .. escapedName .. '"'
  end, 1)
  if count > 0 then
    return openTag
  end

  openTag, count = openTag:gsub("(%sname%s*=%s*)'[^']*'", function(prefix)
    return prefix .. "'" .. escapedName .. "'"
  end, 1)
  if count > 0 then
    return openTag
  end

  openTag, count = openTag:gsub('(%sname%s*=%s*)[^%s>]+', function(prefix)
    return prefix .. '"' .. escapedName .. '"'
  end, 1)
  if count > 0 then
    return openTag
  end

  return openTag:gsub('>$', ' name="' .. escapedName .. '">')
end

---@param fullChat string
---@param replacement string
---@return string
local function replacePatchNode(fullChat, replacement)
  local nodes = prelude.queryNodes('lb-mini-patch', fullChat)
  local node = nodes[#nodes]
  if not node then
    error('Missing <lb-mini-patch> node after interaction.')
  end

  return fullChat:sub(1, node.rangeStart - 1) .. replacement .. fullChat:sub(node.rangeEnd + 1)
end

---@param action string
---@param fullChat string
---@param mutation MutationContext?
---@return string
local function main(_, action, fullChat, mutation)
  if action ~= 'interaction' then
    return fullChat
  end
  if not mutation then
    return fullChat
  end

  local patchNodes = prelude.queryNodes('lb-mini-patch', mutation.output)
  local patchNode = patchNodes[#patchNodes]
  if not patchNode then
    return fullChat
  end

  local patch = json.decode(prelude.trim(patchNode.content))
  local previousNode = mutation.previousNode
  local posts = previousNode and prelude.toon.decode(previousNode.content) or {}
  local board = {
    name = previousNode and previousNode.attributes.name or '미니보드',
    posts = posts,
  }
  local patched = prelude.applyJSONPatch(board, patch)

  validateBoard(patched)
  normalizeCons(patched.posts)
  validateCons(patched.posts)

  local content = prelude.toon.encode(patched.posts, { delimiter = '|' })
  local replacement = createOpenTag(previousNode, patched.name) .. '\n'
      .. content
      .. '\n</lb-mini>'
  return replacePatchNode(fullChat, replacement)
end

return main
