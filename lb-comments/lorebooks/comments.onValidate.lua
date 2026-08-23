local function main(_, output)
  local nodes = prelude.queryNodes('lb-comments', output)
  if #nodes == 0 then
    return
  end

  local success, content = pcall(prelude.toon.decode, nodes[#nodes].content)
  if not success then
    error('InvalidOutput: Invalid TOON format. ' .. tostring(content))
  end
end

return main
