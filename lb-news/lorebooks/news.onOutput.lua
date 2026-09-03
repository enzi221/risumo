---@class NewsHeadlineImage
---@field camera string
---@field cast string
---@field characters ImagePromptSet[]
---@field description string
---@field scene string

---@param values any[]
---@return string
local function joinNonempty(values)
  local parts = {}

  for _, value in ipairs(values) do
    if type(value) == 'string' then
      local text = prelude.trim(value)
      if text ~= '' then
        table.insert(parts, text)
      end
    end
  end

  return table.concat(parts, ', ')
end

---@param tid string
---@param node Node
local function generateHeadlineImage(tid, node)
  if getGlobalVar(tid, 'toggle_lb-news.image') ~= '1' then
    return
  end

  local success, content = pcall(prelude.toon.decode, node.content)
  if not success or type(content.headlineImage) ~= 'table' then
    return
  end

  ---@type NewsHeadlineImage
  local headlineImage = content.headlineImage
  local id = tostring(node.attributes.id or '')
  if id == '' then
    return
  end

  local imageState = getState(tid, 'lb-news-images') or {}
  if type(imageState) ~= 'table' then
    imageState = {}
  end
  imageState[id] = nil
  setState(tid, 'lb-news-images', imageState)

  ---@type LightboardImage
  local image = prelude.import(tid, 'lightboard.image')
  local preset = getGlobalVar(tid, 'toggle_lb-news.image.preset')
  if type(preset) ~= 'string' or prelude.trim(preset) == '' or preset == 'null' then
    preset = '1'
  end
  local prompts = image.applyImagePreset(tid, {
    characters = headlineImage.characters or {},
    description = headlineImage.description,
    setup = joinNonempty({ headlineImage.cast, headlineImage.camera, headlineImage.scene }),
  }, {
    presetBookName = '프리셋 ' .. preset,
  })
  if not prompts then
    print('[Lightboard] News headline image preset not found.')
    return
  end

  local generated, inlay = pcall(image.generateImageFromPrompts, tid, prompts)
  if not generated or not inlay or inlay == '' then
    print('[Lightboard] News headline image generation failed:', tostring(inlay))
    return
  end

  imageState[id] = inlay
  setState(tid, 'lb-news-images', imageState)
end

local function main(tid, output)
  if not string.find(output, '<lb%-news') then
    return nil
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

    local randomId = math.random(1, 2147483647)
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
  generateHeadlineImage(tid, node)
  return output:sub(node.rangeStart, node.rangeEnd)
end

return main
