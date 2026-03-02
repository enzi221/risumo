local function main(_, output)
  if not string.find(output, '<lb%-mini') then
    return nil
  end

  if not string.find(output, "</lb%-mini>") then
    output = output .. '\n</lb-mini>'
  end

  local nodes = prelude.queryNodes('lb-mini', output)
  local node = nodes[#nodes]
  return output:sub(node.rangeStart, node.rangeEnd)
end

return main
