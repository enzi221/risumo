local function main(triggerId, output)
  local runtime = prelude.import(triggerId, 'lb-minitalk.runtime')
  local patch, node = runtime.patch(output)
  if patch then
    return output:sub(node.rangeStart, node.rangeEnd)
  end
  local data = runtime.decode(triggerId, runtime.extract(output).content, true)
  local result = runtime.encode(triggerId, data)
  runtime.preserveKeyFigures(triggerId, data.keyFigures)
  return result
end

return main
