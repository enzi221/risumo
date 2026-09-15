local function parse(content)
  if type(content) ~= 'string' or content:find('[\r\n]') then
    return nil, 'Write picture content on one line'
  end

  local fields = {}
  for field in (content .. '§'):gmatch('(.-)§') do
    fields[#fields + 1] = prelude.trim(field)
  end

  if fields[1] == '' then
    return nil, 'Provide a setup and perspective before any character descriptions'
  end

  local characters = {}
  for index = 2, #fields do
    if fields[index] ~= '' then
      characters[#characters + 1] = {
        positive = fields[index],
      }
    end
  end

  return {
    characters = characters,
    description = '',
    setup = fields[1],
  }
end

local function parseGenerated(content)
  if type(content) ~= 'string' or content:find('[\r\n]') then
    return nil, 'Write generated picture content on one line'
  end

  local result, original = content:match('^(.-)%s*§%s*(.+)$')
  if not result or prelude.trim(result) == '' then
    return nil, 'Keep the generated image result before the original picture content'
  end

  result = prelude.trim(result)
  local source, reason = parse(original)
  if not source then
    return nil, reason
  end

  return {
    inlay = result:match('^%{%{inlay::[^{}]+%}%}$') and result or nil,
    original = original,
    source = source,
  }
end

local function buildPrompts(triggerId, source)
  ---@type LightboardImage
  local image = prelude.import(triggerId, 'lightboard.image')
  local preset = getGlobalVar(triggerId, 'toggle_lb-minitalk-picture.preset')
  if type(preset) ~= 'string' or prelude.trim(preset) == '' or preset == 'null' then
    preset = getGlobalVar(triggerId, 'toggle_lb-xnai.preset')
    if type(preset) ~= 'string' or prelude.trim(preset) == '' or preset == 'null' then
      preset = '1'
    end
  end

  local comfy = getGlobalVar(triggerId, 'toggle_lb-xnai.compat.comfy') == '1'
  local negativeNote = getGlobalVar(triggerId, 'toggle_lb-xnai.negative')
  if type(negativeNote) ~= 'string' or negativeNote == 'null' then
    negativeNote = ''
  end
  local positiveNote = getGlobalVar(triggerId, 'toggle_lb-xnai.positive')
  if type(positiveNote) ~= 'string' or positiveNote == 'null' then
    positiveNote = ''
  end

  return image.applyImagePreset(triggerId, source, {
    characterDivider = comfy and getGlobalVar(triggerId, 'toggle_lb-xnai.compat.charDivider') == '1'
        and '\n\n' or ' | ',
    characterPromptSeparated = getGlobalVar(triggerId, 'toggle_lb-xnai.compat.charPrompt') == '1',
    comfy = comfy,
    inlineSeparator = ', ',
    negativeNote = negativeNote,
    positiveNote = positiveNote,
    presetBookName = '프리셋 ' .. preset,
    sectionSeparator = ',\n\n',
    weightMode = getGlobalVar(triggerId, 'toggle_lb-xnai.compat.weight') == '1' and 'convert' or 'strip',
  })
end

return {
  buildPrompts = buildPrompts,
  parse = parse,
  parseGenerated = parseGenerated,
}
