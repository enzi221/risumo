local function trim(value)
  return value:match('^%s*(.-)%s*$')
end

local function parse(content)
  local fields = {}
  for field in (content .. '§'):gmatch('(.-)§') do
    fields[#fields + 1] = trim(field)
  end
  if not fields[1] or fields[1] == '' or not fields[2] or fields[2] == '' then
    return nil, 'Provide an event name and schedule separated by §'
  end
  local description = fields[4] or ''
  for index = 5, #fields do
    if fields[index] ~= '' then
      description = description == '' and fields[index] or description .. ' § ' .. fields[index]
    end
  end
  return {
    description = description,
    location = fields[3] or '',
    schedule = fields[2],
    title = fields[1],
  }
end

local function validate(_, content)
  local data, reason = parse(content)
  return data ~= nil, reason
end

local function render(_, content)
  local data = assert(parse(content))
  local details = {
    h.div {
      class = 'lb-minitalk-stdblock-calendar-row',
      h.span { class = 'lb-minitalk-stdblock-calendar-icon', '◷' },
      h.span { class = 'lb-minitalk-stdblock-calendar-value', data.schedule },
    },
  }
  if data.location ~= '' then
    details[#details + 1] = h.div {
      class = 'lb-minitalk-stdblock-calendar-row',
      h.span { class = 'lb-minitalk-stdblock-calendar-icon', '⌖' },
      h.span { class = 'lb-minitalk-stdblock-calendar-value', data.location },
    }
  end
  return tostring(h.div {
    class = 'lb-minitalk-stdblock-card lb-minitalk-stdblock-calendar',
    h.div { class = 'lb-minitalk-stdblock-eyebrow', '▣ 캘린더' },
    h.div { class = 'lb-minitalk-stdblock-title', data.title },
    h.div { class = 'lb-minitalk-stdblock-calendar-details', details },
    h.div { class = 'lb-minitalk-stdblock-calendar-description', data.description },
  })
end

return {
  render = render,
  validate = validate,
}
