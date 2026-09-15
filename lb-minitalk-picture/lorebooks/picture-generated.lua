local function validate(triggerId, content)
  local picture = prelude.import(triggerId, 'lb-minitalk-picture.lib')
  local data, reason = picture.parseGenerated(content)
  return data ~= nil, reason
end

local function render(triggerId, content, options)
  local picture = prelude.import(triggerId, 'lb-minitalk-picture.lib')
  local data = picture.parseGenerated(content)
  if not data then
    return tostring(h.div { class = 'lb-minitalk-picture-unavailable', '첨부사진을 표시할 수 없습니다' })
  end

  local inputId = options.id .. '-picture-regenerate-' .. tostring(options.messageIndex)
  local popoverId = options.id .. '-picture-popover-' .. tostring(options.messageIndex)
  local code = table.concat({
    'lb-minitalk-picture-generate/',
    tostring(options.chatIndex),
    '_',
    tostring(options.messageIndex),
  })

  return tostring(h.div {
    class = 'lb-minitalk-picture-generated-wrapper',
    h.input {
      class = 'lb-minitalk-picture-state',
      id = inputId,
      type = 'radio',
      void = true,
    },
    data.inlay and h.button {
      class = 'lb-minitalk-picture-generated',
      popovertarget = popoverId,
      title = '사진 크게 보기',
      type = 'button',
      hraw(data.inlay),
    } or h.div {
      class = 'lb-minitalk-picture-unavailable',
      '첨부사진을 표시할 수 없습니다',
    },
    h.label {
      class = 'lb-minitalk-picture-regenerate',
      htmlFor = inputId,
      risu_btn = code,
      title = '사진 재생성',
      h.span { class = 'lb-minitalk-picture-regenerate-icon', h.lb_reroll_icon { closed = true } },
    },
    data.inlay and h.dialog {
      class = 'lb-minitalk-picture-popover',
      id = popoverId,
      popover = '',
      h.button {
        popovertarget = popoverId,
        title = '사진 닫기',
        type = 'button',
        hraw(data.inlay),
      },
    } or nil,
  })
end

return {
  render = render,
  validate = validate,
}
