local function setup(triggerId)
  if type(prelude) == 'nil' then
    local books = getLoreBooks(triggerId, 'lightboard-prelude') or {}
    if not books[1] then
      error('Lightboard backend is required.')
    end
    assert(load(books[1].content, '@prelude', 't'))()
  end
  return prelude.import(triggerId, 'lb-minitalk.runtime')
end

local function escapeText(value)
  return prelude.escEntities(value):gsub('{', '&#123;'):gsub('}', '&#125;')
end

local function render(triggerId, text, meta)
  local runtime = setup(triggerId)
  local chatIndex = meta and meta.index or 0
  if meta and meta.index ~= nil and chatIndex < getChatLength(triggerId) - 9 then
    return text
  end
  local nodes = prelude.queryNodes('lb-minitalk', text)
  for index = #nodes, 1, -1 do
    local node = nodes[index]
    local data, extensions = runtime.decode(triggerId, node.content, false)
    local renderData = {
      messages = data.messages,
      name = data.name,
      participants = data.participants,
      pov = data.pov,
    }
    local options = {
      chatIndex = chatIndex,
      escapeText = escapeText,
      id = 'lb-minitalk-' .. chatIndex .. '-' .. index .. '-' .. math.random(1000000),
    }
    options.renderContent = function(message)
      if message.type == 'invited' or message.type == 'exit' then
        for _, participant in ipairs(data.participants) do
          if participant.id == message.content then
            local suffix = message.type == 'invited' and '님을 초대했습니다.' or '님이 퇴장했습니다.'
            return escapeText(participant.name .. suffix)
          end
        end
      end
      if message.type == 'text' then
        return escapeText(message.content)
      end
      if message.type == 'con' then
        local identifier = runtime.conIdentifier(message.content)
        return tostring(h.img {
          alt = identifier,
          class = 'lb-minitalk-con',
          src = '{{raw::' .. identifier .. '}}',
          void = true,
        })
      end
      local identifier = message.type:match('^openblock:(.+)$')
      local extension = extensions[identifier]
      if extension then
        local success, html = pcall(extension.render, triggerId, message.content, options)
        if success and type(html) == 'string' and html ~= '' then
          return html
        end
        print('[Lightboard] Messenger OpenBlock render failed:', identifier, tostring(html))
      end
      return tostring(h.div { class = 'lb-minitalk-openblock-fallback' })
    end
    local renderer
    if getGlobalVar(triggerId, 'toggle_lb-minitalk.renderer') == '1' then
      local success, custom = pcall(runtime.loadValue, triggerId, 'lb-minitalk.renderer')
      if success and type(custom) == 'function' then
        renderer = custom
      end
    end
    local success, html = false, nil
    if renderer then
      success, html = pcall(renderer, triggerId, renderData, options)
    end
    if not success or type(html) ~= 'string' or html == '' then
      renderer = runtime.loadValue(triggerId, 'lb-minitalk.renderer.default')
      html = renderer(triggerId, renderData, options)
    end
    if type(html) ~= 'string' or html == '' then
      error('Messenger renderer must return nonempty HTML.')
    end
    text = text:sub(1, node.rangeStart - 1) .. html .. text:sub(node.rangeEnd + 1)
  end
  return text
end

listenEdit('editDisplay', function(triggerId, text, meta)
  local success, result = pcall(render, triggerId, text, meta)
  if success then
    return result
  end
  print('[Lightboard] Messenger display failed:', tostring(result))
  return text .. '<lb-lazy id="lb-minitalk">표시 실패</lb-lazy>'
end)
