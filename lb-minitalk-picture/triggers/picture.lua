local BUTTON_PATTERN = '^lb%-minitalk%-picture%-generate/(-?%d+)_(%d+)$'

local function setup(triggerId)
  if type(prelude) == 'nil' then
    local books = getLoreBooks(triggerId, 'lightboard-prelude') or {}
    if not books[1] then
      error('Lightboard backend is required.')
    end
    assert(load(books[1].content, '@prelude', 't'))()
  end
end

local function cleanRequest(data)
  for _, message in ipairs(data) do
    if type(message.content) == 'string' then
      local nodes = prelude.queryNodes('lb-minitalk', message.content)
      for index = #nodes, 1, -1 do
        local node = nodes[index]
        local contentStart = node.rangeStart + #node.openTag
        local contentEnd = node.rangeEnd - #'</lb-minitalk>'
        message.content = message.content:sub(1, contentStart - 1)
            .. node.content:gsub('%%%%', '')
            .. message.content:sub(contentEnd + 1)
      end
    end
  end

  return data
end

local function generate(triggerId, chatIndex, messageIndex)
  local chat = getChat(triggerId, chatIndex)
  if not chat or type(chat.data) ~= 'string' then
    error('생성할 첨부사진 채팅을 찾을 수 없습니다.')
  end

  local runtime = prelude.import(triggerId, 'lb-minitalk.runtime')
  local node = runtime.extract(chat.data)
  local data = runtime.decode(triggerId, node.content, false)
  local message = data.messages[messageIndex]
  if not message or (message.type ~= 'openblock:picture'
        and message.type ~= 'openblock:picture-generated') then
    error('생성할 첨부사진 메시지를 찾을 수 없습니다.')
  end

  local picture = prelude.import(triggerId, 'lb-minitalk-picture.lib')
  local original = message.content
  local source, reason
  if message.type == 'openblock:picture-generated' then
    local generated
    generated, reason = picture.parseGenerated(message.content)
    if generated then
      original = generated.original
      source = generated.source
    end
  else
    source, reason = picture.parse(message.content)
  end
  if not source then
    error(reason)
  end

  local prompts = picture.buildPrompts(triggerId, source)
  if not prompts then
    error('이미지 프롬프트를 생성할 수 없습니다. 삽화 모듈 프리셋이 있나요?')
  end

  ---@type LightboardImage
  local image = prelude.import(triggerId, 'lightboard.image')
  local inlay = image.generateImageFromPrompts(triggerId, prompts, {
    emptyPositive = '긍정 프롬프트가 비어있어요.',
    requestFailed = '이미지 생성 API 호출 실패. 설정을 다시 점검하세요.',
  })

  message.content = inlay .. ' § ' .. original
  message.type = 'openblock:picture-generated'

  local replacement = runtime.encode(triggerId, data)
  local output = table.concat({
    chat.data:sub(1, node.rangeStart - 1),
    replacement,
    chat.data:sub(node.rangeEnd + 1),
  })
  setChat(triggerId, chatIndex, output)
  reloadChat(triggerId, chatIndex)
end

onButtonClick = async(function(triggerId, code)
  local chatIndex, messageIndex = code:match(BUTTON_PATTERN)
  if not chatIndex then
    return
  end

  setup(triggerId)
  chatIndex = tonumber(chatIndex)
  local success, reason = pcall(generate, triggerId, chatIndex, tonumber(messageIndex))
  if not success then
    local chat = getChat(triggerId, chatIndex)
    if chat and type(chat.data) == 'string' then
      setChat(triggerId, chatIndex, chat.data)
      reloadChat(triggerId, chatIndex)
    end
    prelude.info(triggerId, 'lb-minitalk-picture', 'Image generation failed. error=' .. tostring(reason))
    alertNormal(triggerId, '첨부사진 생성 중 오류가 발생했습니다.\n' .. tostring(reason))
  end
end)

listenEdit('editRequest', function(triggerId, data)
  setup(triggerId)
  return cleanRequest(data)
end)
