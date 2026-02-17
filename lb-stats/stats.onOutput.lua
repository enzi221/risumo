local function main(_, output)
  if not string.find(output, '<lb%-stats') then
    return '<lb-lazy id="lb-stats">오류: 빈 응답 수신? 수신한 응답을 보려면 편집 버튼을 누르세요. <!--  ' .. output .. ' --></lb-lazy>'
  end

  if not string.find(output, "</lb%-stats>") then
    output = output .. '\n</lb-stats>'
  end

  -- Add keepalive attribute if missing
  local tagPattern = "(<lb%-stats)([^>]*)(>)"
  output = output:gsub(tagPattern, function(openTag, attrs, closeTag)
    if attrs:find("keepalive") then
      return openTag .. attrs .. closeTag
    end

    local newAttrs = attrs
    if newAttrs:match("%S") then
      -- Has other attributes, add space before id
      newAttrs = newAttrs .. ' keepalive'
    else
      -- No other attributes
      newAttrs = ' keepalive'
    end

    return openTag .. newAttrs .. closeTag
  end)

  local allBlocks = prelude.queryNodes('lb-stats', output)
  local body = nil
  if #allBlocks >= 1 then
    body = allBlocks[1]
  end

  if not body then
    print('[LightBoard] No <lb-stats> block found')
    return ''
  end

  return output:sub(body.rangeStart, body.rangeEnd)
end

return main
