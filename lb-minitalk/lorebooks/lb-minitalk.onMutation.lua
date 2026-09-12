local function main(triggerId, action, fullChat, mutation)
  if action ~= 'interaction' or not mutation then
    return fullChat
  end
  local runtime = prelude.import(triggerId, 'lb-minitalk.runtime')
  local patch = runtime.patch(mutation.output)
  if not patch then
    return fullChat
  end
  local previous = mutation.previousNode
  local room = previous and runtime.decode(triggerId, previous.content, false) or {}
  local target = {
    messages = room.messages,
    name = room.name,
    participants = room.participants,
    pov = room.pov,
  }
  local patched = prelude.applyJSONPatch(target, patch)
  patched.keyFigures = room.keyFigures
  local _, node = runtime.patch(fullChat)
  if not node then
    error('Missing <lb-minitalk-patch> node after interaction.')
  end
  runtime.validateData(triggerId, patched, false)
  local result = fullChat:sub(1, node.rangeStart - 1) .. runtime.encode(triggerId, patched)
      .. fullChat:sub(node.rangeEnd + 1)
  return result
end

return main
