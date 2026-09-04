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
