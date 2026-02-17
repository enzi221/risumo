local function main(_, output)
  if not string.find(output, '<lb%-hn') then
    return '<lb-lazy id="lb-hn">오류: 빈 응답 수신? 수신한 응답을 보려면 편집 버튼을 누르세요. <!--  ' .. output .. ' --></lb-lazy>'
  end

  if not string.find(output, "</lb%-hn>") then
    output = output .. '\n</lb-hn>'
  end

  local nodes = prelude.queryNodes('lb-hn', output)
  local node = nodes[#nodes]
  return output:sub(node.rangeStart, node.rangeEnd)
end

return main
