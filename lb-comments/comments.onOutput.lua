local function main(_, output)
  if not string.find(output, '<lb%-comments') then
    return '<lb-lazy id="lb-comments">오류: 빈 응답 수신? 수신한 응답을 보려면 편집 버튼을 누르세요. <!--  ' .. output .. ' --></lb-lazy>'
  end

  if not string.find(output, "</lb%-comments>") then
    output = output .. '\n</lb-comments>'
  end

  local nodes = prelude.queryNodes('lb-comments', output)
  local node = nodes[#nodes]
  return output:sub(node.rangeStart, node.rangeEnd)
end

return main
