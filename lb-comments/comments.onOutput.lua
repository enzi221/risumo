local function main(_, output)
  if not string.find(output, '<lb%-comments') then
    return nil
  end

  if not string.find(output, "</lb%-comments>") then
    output = output .. '\n</lb-comments>'
  end

  local nodes = prelude.queryNodes('lb-comments', output)
  local node = nodes[#nodes]
  return output:sub(node.rangeStart, node.rangeEnd)
end

return main
