local function fail(operationIndex, message)
  error('Invalid JSON Patch operation #' .. operationIndex .. ': ' .. message, 0)
end

---@param value any
---@return boolean
local function nullValue(value)
  return type(_ENV.null) ~= 'nil' and value == _ENV.null
end

---@param value any
---@return any
local function cloneJSONValue(value)
  if type(value) ~= 'table' or nullValue(value) then
    return value
  end

  local cloned = {}
  for key, nestedValue in pairs(value) do
    cloned[key] = cloneJSONValue(nestedValue)
  end
  return cloned
end

---@param token string
---@param operationIndex number
---@return string
local function decodePointerToken(token, operationIndex)
  if token:find('~[^01]') or token:sub(-1) == '~' then
    fail(operationIndex, 'path contains an invalid JSON Pointer escape')
  end

  local decoded = token:gsub('~1', '/'):gsub('~0', '~')
  return decoded
end

---@param path any
---@param operationIndex number
---@return string[]
local function parsePointer(path, operationIndex)
  if type(path) ~= 'string' then
    fail(operationIndex, 'path must be a string')
  end
  if path == '' then
    return {}
  end
  if path:sub(1, 1) ~= '/' then
    fail(operationIndex, 'path must be empty or begin with /')
  end

  local tokens = {}
  local tokenStart = 2
  while true do
    local separator = path:find('/', tokenStart, true)
    local token = separator and path:sub(tokenStart, separator - 1) or path:sub(tokenStart)
    table.insert(tokens, decodePointerToken(token, operationIndex))

    if not separator then
      break
    end
    tokenStart = separator + 1
  end

  return tokens
end

---@param token string
---@return integer?
local function parseArrayIndex(token)
  if token ~= '0' and not token:match('^[1-9]%d*$') then
    return nil
  end

  local index = tonumber(token)
  if not index or index % 1 ~= 0 then
    return nil
  end
  return index
end

---@param value table
---@return boolean array
---@return boolean empty
local function inspectContainer(value)
  local count = 0
  local highestIndex = 0

  for key in pairs(value) do
    if type(key) ~= 'number' or key < 1 or key % 1 ~= 0 then
      return false, false
    end
    count = count + 1
    highestIndex = math.max(highestIndex, key)
  end

  if count == 0 then
    return false, true
  end
  return highestIndex == count, false
end

---@param container any
---@param token string
---@param operationIndex number
---@return any
local function readChild(container, token, operationIndex)
  if type(container) ~= 'table' or nullValue(container) then
    fail(operationIndex, 'path traverses a non-container value')
  end

  local array, empty = inspectContainer(container)
  local arrayIndex = parseArrayIndex(token)
  if (array or empty) and token == '-' then
    fail(operationIndex, '- is valid only for the final add path token')
  end

  if array or (empty and arrayIndex ~= nil) then
    if arrayIndex == nil or arrayIndex >= #container then
      fail(operationIndex, 'array path index is out of bounds')
    end
    return container[arrayIndex + 1]
  end

  local value = container[token]
  if value == nil then
    fail(operationIndex, 'path does not exist')
  end
  return value
end

---@param document any
---@param tokens string[]
---@param operationIndex number
---@return table
local function resolveParent(document, tokens, operationIndex)
  local parent = document
  for tokenIndex = 1, #tokens - 1 do
    parent = readChild(parent, tokens[tokenIndex], operationIndex)
  end

  if type(parent) ~= 'table' or nullValue(parent) then
    fail(operationIndex, 'target parent is not a container')
  end
  return parent
end

---@param parent table
---@param token string
---@param operation table
---@param operationIndex number
local function applyAtPath(parent, token, operation, operationIndex)
  local array, empty = inspectContainer(parent)
  local arrayIndex = parseArrayIndex(token)
  local arrayTarget = array or (empty and (token == '-' or arrayIndex ~= nil))

  if arrayTarget then
    if operation.op == 'add' then
      if token == '-' then
        table.insert(parent, cloneJSONValue(operation.value))
        return
      end
      if arrayIndex == nil or arrayIndex > #parent then
        fail(operationIndex, 'array add index is out of bounds')
      end
      table.insert(parent, arrayIndex + 1, cloneJSONValue(operation.value))
      return
    end

    if token == '-' or arrayIndex == nil or arrayIndex >= #parent then
      fail(operationIndex, 'array path index is out of bounds')
    end
    if operation.op == 'remove' then
      table.remove(parent, arrayIndex + 1)
      return
    end

    parent[arrayIndex + 1] = cloneJSONValue(operation.value)
    return
  end

  if operation.op ~= 'add' and parent[token] == nil then
    fail(operationIndex, 'path does not exist')
  end
  if operation.op == 'remove' then
    parent[token] = nil
    return
  end
  parent[token] = cloneJSONValue(operation.value)
end

---@param document any
---@param patch table
---@return any
local function applyJSONPatch(document, patch)
  if type(patch) ~= 'table' or nullValue(patch) then
    error('Invalid JSON Patch: patch must be an array', 0)
  end

  local operationCount = 0
  for key in pairs(patch) do
    if type(key) ~= 'number' or key < 1 or key % 1 ~= 0 then
      error('Invalid JSON Patch: patch must be an array', 0)
    end
    operationCount = operationCount + 1
  end
  if operationCount ~= #patch then
    error('Invalid JSON Patch: patch array must not contain gaps', 0)
  end

  local patched = cloneJSONValue(document)
  for operationIndex, operation in ipairs(patch) do
    if type(operation) ~= 'table' or nullValue(operation) then
      fail(operationIndex, 'operation must be an object')
    end
    if operation.op ~= 'add' and operation.op ~= 'remove' and operation.op ~= 'replace' then
      fail(operationIndex, 'op must be add, remove, or replace')
    end
    if operation.op ~= 'remove' and rawget(operation, 'value') == nil then
      fail(operationIndex, 'add and replace require value')
    end

    local tokens = parsePointer(operation.path, operationIndex)
    if #tokens == 0 then
      if operation.op == 'remove' then
        fail(operationIndex, 'removing the document root is not supported')
      end
      patched = cloneJSONValue(operation.value)
    else
      local parent = resolveParent(patched, tokens, operationIndex)
      applyAtPath(parent, tokens[#tokens], operation, operationIndex)
    end
  end

  return patched
end

return applyJSONPatch
