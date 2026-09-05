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
local function validateKeyFigures(triggerId, output)
  if getGlobalVar(triggerId, 'toggle_lb-mini.keyfigures') ~= '1' then
    return
  end

  local nodes = prelude.queryNodes('lb-mini-keyfigures', output)
  if #nodes == 0 then
    error('InvalidOutput: Missing <lb-mini-keyfigures> node.')
  end

  local content = prelude.trim(nodes[#nodes].content)
  if not content:match('^%[%d+%|%]:') then
    error('InvalidOutput: <lb-mini-keyfigures> must contain a TOON array.')
  end

  local success, keyFigures = pcall(prelude.toon.decode, content)
  if not success or type(keyFigures) ~= 'table' then
    error('InvalidOutput: Invalid <lb-mini-keyfigures> TOON format.')
  end

  for _, keyFigure in ipairs(keyFigures) do
    if type(keyFigure) ~= 'table'
        or type(keyFigure.nickname) ~= 'string'
        or type(keyFigure.keyFigure) ~= 'string'
        or type(keyFigure.note) ~= 'string' then
      error('InvalidOutput: Each preserved key figure requires nickname, keyFigure, and note strings.')
    end
  end
end

local function main(triggerId, output)
  local patchNodes = prelude.queryNodes('lb-mini-patch', output)
  if #patchNodes > 0 then
    local success, patch = pcall(json.decode, prelude.trim(patchNodes[#patchNodes].content))
    if not success then
      error('InvalidOutput: Invalid JSON Patch. ' .. tostring(patch))
    end

    validatePatch(patch)
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

  validateCons(content)
  validateKeyFigures(triggerId, output)
end

return main
