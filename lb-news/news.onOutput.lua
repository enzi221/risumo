local function main(_, output)
  if not string.find(output, '<lb%-news') then
    return '<lb-lazy id="lb-news">오류: 빈 응답 수신? 수신한 응답을 보려면 편집 버튼을 누르세요. <!--  ' .. output .. ' --></lb-lazy>'
  end

  if not string.find(output, "</lb%-news>") then
    output = output .. '\n</lb-news>'
  end

  -- Add id attribute if missing
  local tagPattern = "(<lb%-news)([^>]*)(>)"
  output = output:gsub(tagPattern, function(openTag, attrs, closeTag)
    if attrs:find("id%s*=") then
      return openTag .. attrs .. closeTag
    end

    local randomId = math.random(1, 999)
    local newAttrs = attrs
    if newAttrs:match("%S") then
      -- Has other attributes, add space before id
      newAttrs = newAttrs .. ' id="' .. randomId .. '"'
    else
      -- No other attributes
      newAttrs = ' id="' .. randomId .. '"'
    end

    return openTag .. newAttrs .. closeTag
  end)

  local nodes = prelude.queryNodes('lb-news', output)
  local node = nodes[#nodes]
  return output:sub(node.rangeStart, node.rangeEnd)
end

return main
