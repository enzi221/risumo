local C = require('./constants')

local M = {}

--- Strips a node block and returns its position.
--- @param text string
--- @param tagName string
--- @param attrs table<string, string>?
--- @return string modifiedText, number? removedPosition
function M.removeNode(text, tagName, attrs)
  if not text then return '', nil end

  local nodes = prelude.queryNodes(tagName, text)
  if #nodes == 0 then return text, nil end

  local targetNode = nil
  if attrs then
    for _, node in ipairs(nodes) do
      local matchAttrs = true
      for k, v in pairs(attrs) do
        if node.attributes[k] ~= v then
          matchAttrs = false
          break
        end
      end
      if matchAttrs then
        targetNode = node
        break
      end
    end
  else
    targetNode = nodes[1]
  end

  if not targetNode then return text, nil end

  local prefix = text:sub(1, targetNode.rangeStart - 1):gsub("\n?$", "")
  local suffix = text:sub(targetNode.rangeEnd + 1):gsub("^\n?", "")

  return prefix .. '\n' .. suffix, #prefix + 2
end

--- Inserts content before [LBDATA END] marker, or appends if not found.
--- @param text string
--- @param newContent string
--- @return string
function M.fallbackInsert(text, newContent)
  local footerStart = text:find(C.LBDATA.PATTERN_END)

  if footerStart then
    local lineStart = footerStart
    while lineStart > 1 and text:sub(lineStart - 1, lineStart - 1) ~= '\n' do
      lineStart = lineStart - 1
    end

    return text:sub(1, lineStart - 1) .. '\n' .. newContent .. '\n' .. text:sub(lineStart)
  else
    return text .. '\n' .. newContent
  end
end

--- Finds the last chat index that contains an LBDATA block.
--- @param fullChat Chat[]
--- @return number? jsIndex (0-based for setChat)
function M.findLastLBDATAChat(fullChat)
  for i = #fullChat, 1, -1 do
    local chat = fullChat[i]
    if chat and chat.role == 'char' and chat.data and chat.data:find(C.LBDATA.PATTERN_START) then
      return i - 1 -- Lua 1-based -> JS 0-based
    end
  end

  return nil
end

--- Replaces the inner content of the last [LBDATA START]..[LBDATA END] block.
--- Returns nil if no block is found.
--- @param text string
--- @param inner string
--- @return string?
function M.replaceLBDATA(text, inner)
  if not text or text == '' then return nil end

  local _, blockStart = nil, nil
  local searchFrom = 1
  while true do
    local s, e = text:find(C.LBDATA.PATTERN_START, searchFrom)
    if not s then break end
    _, blockStart = s, e
    searchFrom = e + 1
  end

  if not blockStart then return nil end

  local blockEnd = text:find(C.LBDATA.PATTERN_END, blockStart + 1)
  if not blockEnd then return nil end

  local trimmedInner = prelude and prelude.trim and prelude.trim(inner or '') or (inner or '')
  if trimmedInner ~= '' then
    trimmedInner = trimmedInner .. '\n'
  end

  return text:sub(1, blockStart) .. '\n' .. trimmedInner .. text:sub(blockEnd)
end

--- @class ResolvedTargets
--- @field targetIdx number? 0-based JS index
--- @field targetContent string?
--- @field lbdataIdx number? 0-based JS index
--- @field lbdataContent string?

--- Resolves target and LBDATA chat indices/contents.
--- @param fullChat Chat[]
--- @return ResolvedTargets
function M.resolveTargets(fullChat)
  local targetIdx = prelude.locateTargetChat(fullChat)
  if not targetIdx then
    return {}
  end

  local targetContent = fullChat[targetIdx + 1] and fullChat[targetIdx + 1].data or ''
  local lbdataIdx = M.findLastLBDATAChat(fullChat) or targetIdx
  local lbdataContent = fullChat[lbdataIdx + 1] and fullChat[lbdataIdx + 1].data or targetContent

  return {
    targetIdx = targetIdx,
    targetContent = targetContent,
    lbdataIdx = lbdataIdx,
    lbdataContent = lbdataContent,
  }
end

--- Appends content into an existing LBDATA block, or inserts a new one if missing.
--- @param text string
--- @param appendContent string?
--- @return string
function M.appendLBDATA(text, appendContent)
  if not text or text == '' then return text end

  local trimmedAppend = prelude.trim(appendContent or '')
  if trimmedAppend == '' then
    return text
  end

  local existingLBDATA = text:match(C.LBDATA.PATTERN_START .. '(.-)' .. C.LBDATA.PATTERN_END) or ''
  local newInner = prelude.trim(existingLBDATA)
  if newInner ~= '' then
    newInner = newInner .. '\n\n' .. trimmedAppend
  else
    newInner = trimmedAppend
  end

  local updated = M.replaceLBDATA(text, newInner)
  if updated then
    return updated
  end

  return M.fallbackInsert(text, trimmedAppend)
end

return M
