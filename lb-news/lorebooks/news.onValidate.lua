local function main(tid, output)
  local nodes = prelude.queryNodes('lb-news', output)
  if #nodes == 0 then
    return
  end

  local success, content = pcall(prelude.toon.decode, nodes[#nodes].content)
  if not success then
    error('InvalidOutput: Invalid TOON format. ' .. tostring(content))
  end

  if getGlobalVar(tid, 'toggle_lb-news.image') == '1' then
    if type(content.headlineImage) ~= 'table' then
      error('InvalidOutput: Missing "headlineImage" object in TOON data.')
    end
    if type(content.headlineImage.camera) ~= 'string' or prelude.trim(content.headlineImage.camera) == '' then
      error('InvalidOutput: Missing "headlineImage.camera" text in TOON data.')
    end
    if type(content.headlineImage.cast) ~= 'string' or prelude.trim(content.headlineImage.cast) == '' then
      error('InvalidOutput: Missing "headlineImage.cast" text in TOON data.')
    end
    if type(content.headlineImage.characters) ~= 'table' then
      error('InvalidOutput: Missing "headlineImage.characters" array in TOON data.')
    end
    for _, character in ipairs(content.headlineImage.characters) do
      if type(character.positive) ~= 'string' or prelude.trim(character.positive) == '' then
        error('InvalidOutput: Missing "headlineImage.characters[].positive" text in TOON data.')
      end
      if character.negative ~= nil and type(character.negative) ~= 'string' then
        error('InvalidOutput: "headlineImage.characters[].negative" must be text when present.')
      end
    end
    if type(content.headlineImage.description) ~= 'string' or prelude.trim(content.headlineImage.description) == '' then
      error('InvalidOutput: Missing "headlineImage.description" text in TOON data.')
    end
    if type(content.headlineImage.scene) ~= 'string' or prelude.trim(content.headlineImage.scene) == '' then
      error('InvalidOutput: Missing "headlineImage.scene" text in TOON data.')
    end
  end

  if type(content.topAds) ~= 'table' then
    error('InvalidOutput: Missing "topAds" array in TOON data.')
  end
  if #content.topAds ~= 2 then
    error('InvalidOutput: "topAds" array must contain exactly 2 ads.')
  end
  for _, ad in ipairs(content.topAds) do
    if type(ad.boxStyle) ~= 'string' or prelude.trim(ad.boxStyle) == '' then
      error('InvalidOutput: Missing "topAds[].boxStyle" text in TOON data.')
    end
    if type(ad.content) ~= 'string' or prelude.trim(ad.content) == '' then
      error('InvalidOutput: Missing "topAds[].content" text in TOON data.')
    end
    if type(ad.textStyle) ~= 'string' or prelude.trim(ad.textStyle) == '' then
      error('InvalidOutput: Missing "topAds[].textStyle" text in TOON data.')
    end
  end

  if type(content.bottomAd) ~= 'table' then
    error('InvalidOutput: Missing "bottomAd" object in TOON data.')
  end
  if type(content.bottomAd.boxStyle) ~= 'string' or prelude.trim(content.bottomAd.boxStyle) == '' then
    error('InvalidOutput: Missing "bottomAd.boxStyle" text in TOON data.')
  end
  if type(content.bottomAd.content) ~= 'string' or prelude.trim(content.bottomAd.content) == '' then
    error('InvalidOutput: Missing "bottomAd.content" text in TOON data.')
  end
  if type(content.bottomAd.textStyle) ~= 'string' or prelude.trim(content.bottomAd.textStyle) == '' then
    error('InvalidOutput: Missing "bottomAd.textStyle" text in TOON data.')
  end
end

return main
