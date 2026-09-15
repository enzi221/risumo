local function parse(content)
  local fields = {}
  for field in (content .. '§'):gmatch('(.-)§') do
    fields[#fields + 1] = field:match('^%s*(.-)%s*$')
  end
  if not fields[1] or fields[1] == '' or not fields[2] or fields[2] == ''
    or not fields[3] or fields[3] == '' then
    return nil, 'Provide website name, URL, and page title separated by §'
  end
  return {
    description = fields[4] or '',
    site = fields[1],
    title = fields[3],
    url = fields[2],
  }
end

local function validate(_, content)
  local data, reason = parse(content)
  return data ~= nil, reason
end

local function render(_, content)
  local data = assert(parse(content))
  local function text(tag, class, value)
    return h[tag] { class = 'lb-minitalk-stdblock-' .. class, value }
  end
  return tostring(h.div {
    class = 'lb-minitalk-stdblock-card lb-minitalk-stdblock-opengraph',
    text('div', 'eyebrow', '↗ ' .. data.site),
    h.div {
      class = 'lb-minitalk-stdblock-opengraph-summary',
      text('div', 'title', data.title),
      text('div', 'description', data.description),
    },
    text('div', 'url', data.url),
  })
end

return {
  render = render,
  validate = validate,
}
