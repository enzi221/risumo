local function main(_, output)
  local nodes = prelude.queryNodes('lb-mini', output)
  if #nodes == 0 then
    error('InvalidOutput: Missing <lb-mini> node.')
  end

  local success, content = pcall(prelude.toon.decode, nodes[#nodes].content)
  if not success then
    error('InvalidOutput: Invalid TOON format. ' .. tostring(content))
  end
end

return main
