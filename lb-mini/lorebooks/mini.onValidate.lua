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

local function requireString(value, label)
  if type(value) ~= 'string' then
    error('InvalidOutput: ' .. label .. ' must be a string.')
  end
end

local function requireNumber(value, label)
  if type(value) ~= 'number' then
    error('InvalidOutput: ' .. label .. ' must be a number.')
  end
end

local function validateBoard(board)
  if type(board) ~= 'table' then
    error('InvalidOutput: Board root must be an object.')
  end
  requireString(board.name, 'name')
  if board.name == '' then
    error('InvalidOutput: name must not be empty.')
  end
  if not denseArray(board.posts) then
    error('InvalidOutput: posts must be an array.')
  end
  for postIndex, post in ipairs(board.posts) do
    local postLabel = 'posts[' .. tostring(postIndex - 1) .. ']'
    if type(post) ~= 'table' then
      error('InvalidOutput: ' .. postLabel .. ' must be an object.')
    end

    requireString(post.author, postLabel .. '.author')
    requireString(post.content, postLabel .. '.content')
    requireNumber(post.downvotes, postLabel .. '.downvotes')
    requireString(post.time, postLabel .. '.time')
    requireString(post.title, postLabel .. '.title')
    requireNumber(post.upvotes, postLabel .. '.upvotes')

    if not denseArray(post.comments) then
      error('InvalidOutput: ' .. postLabel .. '.comments must be an array.')
    end
    for commentIndex, comment in ipairs(post.comments) do
      local commentLabel = postLabel .. '.comments[' .. tostring(commentIndex - 1) .. ']'
      if type(comment) ~= 'table' then
        error('InvalidOutput: ' .. commentLabel .. ' must be an object.')
      end
      requireString(comment.author, commentLabel .. '.author')
      requireString(comment.content, commentLabel .. '.content')
      requireString(comment.time, commentLabel .. '.time')
    end
  end
end

local function validateCons(posts)
  for _, post in ipairs(posts) do
    local postContent = post.content or ''
    if postContent:find('[con:', 1, true) then
      error('InvalidOutput: Cons may only appear in comments.')
    end

    for _, comment in ipairs(post.comments or {}) do
      local content = comment.content or ''
      if content:find('[con:', 1, true) and not parseCons(content) then
        error('InvalidOutput: Cons must be the entire comment content and use safe asset identifiers.')
      end
    end
  end
end

local function validatePatch(patch)
  if type(patch) ~= 'table' then
    error('InvalidOutput: <lb-mini-patch> must contain a JSON array.')
  end

  local operationCount = 0
  for key in pairs(patch) do
    if type(key) ~= 'number' or key < 1 or key % 1 ~= 0 then
      error('InvalidOutput: <lb-mini-patch> must contain a JSON array.')
    end
    operationCount = operationCount + 1
  end

  if operationCount ~= #patch then
    error('InvalidOutput: JSON Patch array must not contain gaps.')
  end
  if operationCount == 0 then
    error('InvalidOutput: JSON Patch array must contain at least one operation.')
  end

  for _, operation in ipairs(patch) do
    if type(operation) ~= 'table' then
      error('InvalidOutput: Each JSON Patch operation must be an object.')
    end
    if operation.op ~= 'add' and operation.op ~= 'remove' and operation.op ~= 'replace' then
      error('InvalidOutput: JSON Patch op must be add, remove, or replace.')
    end
    if type(operation.path) ~= 'string' then
      error('InvalidOutput: Each JSON Patch operation requires a string path.')
    end
    if operation.path ~= '' and operation.path:sub(1, 1) ~= '/' then
      error('InvalidOutput: JSON Patch paths must be empty or begin with /.')
    end
    if operation.path:find('~[^01]') or operation.path:sub(-1) == '~' then
      error('InvalidOutput: JSON Patch path contains an invalid escape.')
    end
    if operation.op == 'remove' and operation.path == '' then
      error('InvalidOutput: Removing the board root is not supported.')
    end
    if operation.op ~= 'remove' and rawget(operation, 'value') == nil then
      error('InvalidOutput: JSON Patch add and replace operations require value.')
    end
  end
end

---@param triggerId string
---@param output string
local function validateKeyFigures(triggerId, data)
  if getGlobalVar(triggerId, 'toggle_lb-mini.keyfigures') ~= '1' then
    return
  end

  if type(data.keyFigures) ~= 'table' then
    error('InvalidOutput: Missing keyFigures array in <lb-mini>.')
  end

  for _, keyFigure in ipairs(data.keyFigures) do
    if type(keyFigure) ~= 'table'
        or type(keyFigure.nickname) ~= 'string'
        or type(keyFigure.keyFigure) ~= 'string'
        or type(keyFigure.note) ~= 'string' then
      error('InvalidOutput: Each preserved key figure requires nickname, keyFigure, and note strings.')
    end
  end
end

local function main(triggerId, output, context)
  local patchNodes = prelude.queryNodes('lb-mini-patch', output)
  if #patchNodes > 0 then
    local success, patch = pcall(json.decode, prelude.trim(patchNodes[#patchNodes].content))
    if not success then
      error('InvalidOutput: Invalid JSON Patch. ' .. tostring(patch))
    end

    validatePatch(patch)

    if context and context.previousNode then
      local previousNode = context.previousNode
      local decodeSuccess, previous = pcall(prelude.toon.decode, previousNode.content)
      if decodeSuccess and type(previous) == 'table' then
        local previousPosts = {}
        if type(previous.posts) == 'table' then
          previousPosts = previous.posts
        elseif #previous > 0 or next(previous) == nil then
          previousPosts = previous
        end

        local board = {
          name = previousNode.attributes and previousNode.attributes.name or '미니보드',
          posts = previousPosts,
        }

        local patchSuccess, patched = pcall(prelude.applyJSONPatch, board, patch)
        if not patchSuccess then
          error('InvalidOutput: Failed to apply JSON Patch. ' .. tostring(patched))
        end

        validateBoard(patched)
        validateCons(patched.posts)
      end
    end
    return
  end

  local nodes = prelude.queryNodes('lb-mini', output)
  if #nodes == 0 then
    error('InvalidOutput: Missing <lb-mini> node.')
  end

  local success, content = pcall(prelude.toon.decode, nodes[#nodes].content)
  if not success then
    error('InvalidOutput: Invalid TOON format. ' .. tostring(content))
  end

  if type(content) ~= 'table' or type(content.posts) ~= 'table' then
    error('InvalidOutput: <lb-mini> must contain a TOON object with a posts array.')
  end

  validateCons(content.posts)
  validateKeyFigures(triggerId, content)
end

return main
