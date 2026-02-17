local function main(_, output)
  local nodes = prelude.queryNodes('lb-news', output)
  if #nodes == 0 then
    return
  end

  local success, content = pcall(prelude.toon.decode, nodes[#nodes].content)
  if not success then
    error('InvalidOutput: Invalid TOON format. ' .. tostring(content))
  end

  if type(content.topAds) ~= 'table' then
    error('InvalidOutput: Missing "topAds" array in TOON data.')
  end
  if #content.topAds ~= 2 then
    error('InvalidOutput: "topAds" array must contain exactly 2 ads.')
  end
  for _, ad in ipairs(content.topAds) do
    if #ad.bg ~= 7 or #ad.fg ~= 7 or #ad.border ~= 7 then
      error('InvalidOutput: Ad colors must be in hex format (e.g., #RRGGBB).')
    end
  end

  if #content.bottomAd.bg ~= 7 or #content.bottomAd.fg ~= 7 or #content.bottomAd.border ~= 7 then
    error('InvalidOutput: Ad colors must be in hex format (e.g., #RRGGBB).')
  end
end

return main
