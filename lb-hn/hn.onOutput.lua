local function main(_, output)
  if not string.find(output, '<lb%-hn') then
    return nil
  end

  if not string.find(output, "</lb%-hn>") then
    output = output .. '\n</lb-hn>'
  end

  local nodes = prelude.queryNodes('lb-hn', output)
  local node = nodes[#nodes]
  return output:sub(node.rangeStart, node.rangeEnd)
end

return main
