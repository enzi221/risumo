local function parse(content)
  local fields = {}
  for field in (content .. '§'):gmatch('(.-)§') do
    local trimmed = field:match('^%s*(.-)%s*$')
    if trimmed ~= '' then
      fields[#fields + 1] = trimmed
    end
  end
  if #fields < 3 then
    return nil, 'Provide a question and at least two options'
  end
  local data = { options = {}, question = fields[1], total = 0 }
  for index = 2, #fields do
    local label, count = fields[index]:match('^(.-)%s*::%s*([^:]-)%s*$')
    if not label then
      label, count = fields[index], '0'
    end
    label = label:match('^%s*(.-)%s*$')
    local votes = tonumber(count)
    if count == '' then
      votes = 0
    end
    if label == '' or not votes or votes < 0 or votes == math.huge or votes % 1 ~= 0 then
      return nil, 'Each option needs a label and a nonnegative integer vote count'
    end
    data.total = data.total + votes
    if data.total == math.huge then
      return nil, 'Vote total must be finite'
    end
    data.options[#data.options + 1] = { label = label, votes = votes }
  end
  return data
end

local function validate(_, content)
  local data, reason = parse(content)
  return data ~= nil, reason
end

local function render(_, content)
  local data = assert(parse(content))
  local rows = {}
  for _, option in ipairs(data.options) do
    local percent = 0
    if data.total > 0 then
      percent = math.floor(option.votes / data.total * 100 + 0.5)
    end
    rows[#rows + 1] = h.div {
      class = 'lb-minitalk-stdblock-option',
      h.div {
        class = 'lb-minitalk-stdblock-option-line',
        h.span { class = 'lb-minitalk-stdblock-label', option.label },
        h.span {
          class = 'lb-minitalk-stdblock-count',
          hraw(string.format('%.0f표 · %d%%', option.votes, percent)),
        },
      },
      h.div {
        class = 'lb-minitalk-stdblock-track',
        h.div { class = 'lb-minitalk-stdblock-fill', style = 'width:' .. percent .. '%;' },
      },
    }
  end
  return tostring(h.div {
    class = 'lb-minitalk-stdblock-card',
    h.div { class = 'lb-minitalk-stdblock-eyebrow', '▥ 투표' },
    h.div { class = 'lb-minitalk-stdblock-title', data.question },
    h.div { class = 'lb-minitalk-stdblock-options', rows },
    h.div {
      class = 'lb-minitalk-stdblock-footer',
      hraw(data.total == 0 and '아직 참여한 사람이 없어요' or string.format('총 %.0f표', data.total)),
    },
  })
end

return {
  render = render,
  validate = validate,
}
