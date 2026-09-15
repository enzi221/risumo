local avatarPatterns = { 'blobs', 'dots', 'orbs', 'stripes' }

local function avatarSeed(value)
  local seed = 7
  for index = 1, #value do
    seed = (seed * 131 + value:byte(index)) % 2147483647
  end
  return seed
end

local function avatarProperties(name)
  local seed = avatarSeed(name)
  local pattern = avatarPatterns[(math.floor(seed / 64800) % #avatarPatterns) + 1]
  local style = string.format('--lb-minitalk-gradient-seed:%d', seed)
  return pattern, style
end

local function summarizeParticipants(participants)
  if #participants <= 2 then
    return table.concat(participants, ', ')
  end
  return string.format('%s, %s 외 %d명', participants[1], participants[2], #participants - 2)
end

local function render(triggerId, data, options)
  local colors = { ['0'] = 'pink', ['1'] = 'blue', ['2'] = 'yellow', ['3'] = 'green' }
  local color = colors[getGlobalVar(triggerId, 'toggle_lb-minitalk.theme')] or 'pink'
  local theme = getGlobalVar(triggerId, 'toggle_lb-minitalk.darkness') == '1' and 'dark' or 'light'
  local names = {}
  local participants = {}
  for _, participant in ipairs(data.participants) do
    names[participant.id] = participant.name
    table.insert(participants, participant.name)
  end
  local messages = {}
  local previousSender
  for _, message in ipairs(data.messages) do
    if message.type == 'pause' then
      previousSender = nil
      table.insert(messages, h.div {
        class = 'lb-minitalk-arc-pause',
        message.content,
      })
    elseif message.type == 'skip' then
      previousSender = nil
      table.insert(messages, h.div { class = 'lb-minitalk-arc-skip', '생략됨' })
    elseif message.type == 'invited' or message.type == 'exit' then
      previousSender = nil
      table.insert(messages, h.div {
        class = 'lb-minitalk-arc-event',
        hraw(options.renderContent(message)),
      })
    else
      local contentClass = 'lb-minitalk-arc-content'
      local groupStart = message.sender ~= previousSender
      local avatarPattern, avatarStyle = avatarProperties(names[message.sender])
      if message.type == 'con' then
        contentClass = 'lb-minitalk-arc-media'
      elseif message.type:match('^openblock:') then
        contentClass = 'lb-minitalk-arc-openblock'
      end
      table.insert(messages, h.div {
        class = 'lb-minitalk-arc-message',
        data_group_start = groupStart and 'true' or 'false',
        data_self = message.sender == data.pov and 'true' or 'false',
        h.div {
          class = 'lb-minitalk-arc-avatar lb-minitalk-gradient',
          data_pattern = avatarPattern,
          data_visible = groupStart and 'true' or 'false',
          style = avatarStyle,
        },
        h.div {
          class = 'lb-minitalk-arc-message-body',
          h.div {
            class = 'lb-minitalk-arc-sender',
            data_visible = groupStart and 'true' or 'false',
            names[message.sender],
          },
          h.div {
            class = 'lb-minitalk-arc-message-row',
            h.div {
              class = contentClass,
              hraw(options.renderContent(message)),
            },
            h.div {
              class = 'lb-minitalk-arc-meta',
              h.span {
                class = 'lb-minitalk-arc-time',
                message.time,
              },
            },
          },
        },
      })
      previousSender = message.sender
    end
  end
  if #messages == 0 then
    table.insert(messages, h.p { class = 'lb-minitalk-arc-empty', '메시지 없음' })
  end
  return tostring(h.div {
    class = 'lb-module-opener-root',
    data_id = 'lb-minitalk',
    h.button {
      class = 'lb-module-opener',
      popovertarget = options.id,
      type = 'button',
      '미니톡',
    },
    h.dialog {
      class = 'lb-dialog lb-minitalk-arc-root lb-minitalk-arc-dialog',
      data_color = color,
      data_theme = theme,
      id = options.id,
      popover = '',
      h.header {
        class = 'lb-minitalk-arc-header',
        h.div {
          class = 'lb-minitalk-arc-heading',
          h.div {
            class = 'lb-minitalk-arc-heading-row',
            h.h2 { class = 'lb-minitalk-arc-title', data.name },
            h.span { class = 'lb-minitalk-arc-count', tostring(#participants) },
          },
          h.p {
            class = 'lb-minitalk-arc-participants',
            summarizeParticipants(participants),
          },
        },
        h.div {
          class = 'lb-minitalk-arc-header-actions',
          h.button {
            class = 'lb-minitalk-arc-room-btn',
            risu_btn = 'lb-interaction__lb-minitalk__ChangeRoom',
            title = '채팅방 변경',
            type = 'button',
            '채팅방 변경',
          },
          h.button {
            class = 'lb-minitalk-arc-action-btn',
            risu_btn = 'lb-reroll__lb-minitalk',
            title = '다시 생성',
            type = 'button',
            h.lb_reroll_icon { closed = true },
          },
          h.button {
            class = 'lb-minitalk-arc-action-btn',
            risu_btn = 'lb-interaction__lb-minitalk__immediate#PassTime',
            title = '시간 보내기',
            type = 'button',
            h.lb_timer { closed = true },
          },
        },
      },
      h.div { class = 'lb-minitalk-arc-messages', messages },
      h.div {
        class = 'lb-minitalk-arc-composer',
        h.button {
          class = 'lb-minitalk-arc-input-button',
          risu_btn = 'lb-interaction__lb-minitalk__SendMessage',
          title = '메시지 입력',
          type = 'button',
          '메시지 입력…',
        },
        h.button {
          class = 'lb-minitalk-arc-close-btn',
          popovertarget = options.id,
          popovertargetaction = 'hide',
          type = 'button',
          '닫기',
        },
      },
    },
  })
end

return render
