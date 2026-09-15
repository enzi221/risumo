local function validate(triggerId, content)
  local picture = prelude.import(triggerId, 'lb-minitalk-picture.lib')
  local data, reason = picture.parse(content)
  return data ~= nil, reason
end

local function render(triggerId, content, options)
  local inputId = options.id .. '-picture-' .. tostring(options.messageIndex)
  local code = table.concat({
    'lb-minitalk-picture-generate/',
    tostring(options.chatIndex),
    '_',
    tostring(options.messageIndex),
  })

  return tostring(h.div {
    class = 'lb-minitalk-picture-pending',
    h.input {
      class = 'lb-minitalk-picture-state',
      id = inputId,
      type = 'radio',
      void = true,
    },
    h.label {
      class = 'lb-minitalk-picture-placeholder',
      htmlFor = inputId,
      risu_btn = code,
      title = '이미지 생성',
      h.span {
        class = 'lb-minitalk-picture-spinner',
        h.span { class = 'lb-minitalk-picture-icon', '🖼️' },
        h.span { '다운로드' }
      },
    },
  })
end

return {
  render = render,
  validate = validate,
}
