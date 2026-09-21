local function main(triggerId, output, context)
  local runtime = prelude.import(triggerId, 'lb-minitalk.runtime')
  local operations = runtime.patch(output)
  if operations then
    if context and context.previousNode then
      local previous = context.previousNode
      local decodeSuccess, room = pcall(runtime.decode, triggerId, previous.content, false)
      if decodeSuccess and type(room) == 'table' then
        local target = {
          messages = room.messages,
          name = room.name,
          participants = room.participants,
          pov = room.pov,
        }
        local patchSuccess, patched = pcall(prelude.applyJSONPatch, target, operations)
        if not patchSuccess then
          error('InvalidOutput: Failed to apply JSON Patch: ' .. tostring(patched))
        end
        patched.keyFigures = room.keyFigures or {}
        runtime.validateData(triggerId, patched, false)
      end
    end
    return
  end
  runtime.decode(triggerId, runtime.extract(output).content, true)
end

return main
