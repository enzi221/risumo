local function trim(value)
  return value:match('^%s*(.-)%s*$')
end

local function parse(content)
  local question, choice = content:match('^(.-)§(.-)$')
  if not question or not choice then
    return nil, 'Provide a poll question and selected option separated by §'
  end
  question = trim(question)
  choice = trim(choice)
  if question == '' or choice == '' then
    return nil, 'Provide a poll question and selected option separated by §'
  end
  return {
    choice = choice,
    question = question,
  }
end

local function validate(_, content)
  local data, reason = parse(content)
  return data ~= nil, reason
end

local function render(_, content, options)
  local data = assert(parse(content))
  local function escaped(value)
    return hraw(options.escapeText(value))
  end
  return tostring(h.div {
    class = 'lb-minitalk-stdblock-card lb-minitalk-stdblock-poll-vote',
    h.div { class = 'lb-minitalk-stdblock-eyebrow', '✓ 투표 완료' },
    h.div { class = 'lb-minitalk-stdblock-title', escaped(data.question) },
    h.div { class = 'lb-minitalk-stdblock-vote-choice', escaped(data.choice) },
  })
end

return {
  render = render,
  validate = validate,
}
