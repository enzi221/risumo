local function main(_, output)
  if not string.find(output, '<lb%-mini') then
    return '<lb-lazy id="lb-mini">오류: 빈 응답 수신? 수신한 응답을 보려면 편집 버튼을 누르세요. <!--  ' .. output .. ' --></lb-lazy>'
  end

  if not string.find(output, "</lb%-mini>") then
    output = output .. '\n</lb-mini>'
  end

  local nodes = prelude.queryNodes('lb-mini', output)
  local node = nodes[#nodes]
  return output:sub(node.rangeStart, node.rangeEnd)
end

return main
