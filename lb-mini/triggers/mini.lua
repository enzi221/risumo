--! Copyright (c) 2025-2026 amonamona
--! CC BY-NC-SA 4.0 https://creativecommons.org/licenses/by-nc-sa/4.0/
--! Lightboard Miniboard

local triggerId = ''

local function setTriggerId(tid)
  triggerId = tid
  if type(prelude) ~= 'nil' then
    prelude.import(tid, 'toon.decode')
    prelude.import(tid, 'toon.encode')
    return
  end
  local source = getLoreBooks(triggerId, 'lightboard-prelude')
  if not source or #source == 0 then
    error('Failed to load lightboard-prelude.')
  end
  load(source[1].content, '@prelude', 't')()
  prelude.import(tid, 'toon.decode')
  prelude.import(tid, 'toon.encode')
end

local CUSTOM_RENDERER_NAME = 'lb-mini.renderer'
local DEFAULT_RENDERER_NAME = 'lb-mini.renderer.default'

local THEME_COLORS = {
  {
    dark = '#ff6b9d',
    light = '#ff005e',
  },
  {
    dark = '#4299e1',
    light = '#007BFF',
  },
  {
    dark = '#ecc94b',
    light = '#d4af37',
  },
  {
    dark = '#66bb6a',
    light = '#2e7d32',
  },
}

---@class MiniboardCommentData
---@field author string
---@field cons string[]? Asset identifiers when content is absent.
---@field content string? Comment text when cons is absent.
---@field time string

---@class MiniboardPostData
---@field author string
---@field comments MiniboardCommentData[]
---@field content string
---@field time string
---@field title string
---@field downvotes string
---@field upvotes string

---@class MiniboardRenderData
---@field attributes table<string, string>
---@field posts MiniboardPostData[]

---@param name string
---@return function?
local function loadRenderer(name)
  local book = prelude.getPriorityLoreBook(triggerId, name)
  if not book or not book.content or prelude.trim(book.content) == '' then
    return nil
  end

  local chunk, loadError = load(book.content, '@' .. name, 't')
  if not chunk then
    print('[Lightboard] Miniboard renderer compile failed:', tostring(loadError))
    return nil
  end

  local success, renderer = pcall(chunk)
  if not success or type(renderer) ~= 'function' then
    print('[Lightboard] Miniboard renderer load failed:', tostring(renderer))
    return nil
  end

  return renderer
end

---@return function
local function resolveRenderer()
  if getGlobalVar(triggerId, 'toggle_lb-mini.renderer') == '1' then
    local renderer = loadRenderer(CUSTOM_RENDERER_NAME)
    if renderer then
      return renderer
    end
  end

  local renderer = loadRenderer(DEFAULT_RENDERER_NAME)
  if not renderer then
    error('Failed to load the default Miniboard renderer.')
  end

  return renderer
end

---@param chatIndex number
---@return MiniboardRenderOptions
local function getRenderOptions(chatIndex)
  local darkness = getGlobalVar(triggerId, 'toggle_lb-mini.darkness') == '1' and 'dark' or 'light'
  local themeValue = getGlobalVar(triggerId, 'toggle_lb-mini.theme')
  local themeIndex = type(themeValue) == 'string' and tonumber(themeValue) or 0
  local colors = THEME_COLORS[themeIndex + 1] or THEME_COLORS[1]

  return {
    chatIndex = chatIndex,
    color = colors[darkness],
    darkness = darkness,
  }
end

---@param content any
---@return string[]?
local function parseConReferences(content)
  if type(content) ~= 'string' then
    return nil
  end

  local value = content:match('^%s*%[con:([^%]]+)%]%s*$')
  if not value then
    return nil
  end

  local identifiers = {}
  for identifier in value:gmatch('[^,]+') do
    if not identifier:match('^[%w._/%-]+$') then
      return nil
    end
    table.insert(identifiers, identifier)
  end

  if #identifiers < 1 or table.concat(identifiers, ',') ~= value then
    return nil
  end

  return identifiers
end

---@param content string
---@return table
local function decodeBoard(content)
  local board = prelude.toon.decode(content)
  local posts = board.posts

  for _, post in ipairs(posts) do
    for _, comment in ipairs(post.comments or {}) do
      local cons = parseConReferences(comment.content)
      if cons then
        comment.cons = cons
        comment.content = nil
      end
    end
  end

  return board
end

---@param board table
---@return string
local function encodeBoard(board)
  local posts = board.posts or {}
  local root = setmetatable({
    posts = #posts > 0 and posts or nil,
  }, { __toonKeyOrder = { 'posts' } })
  local prefix = ''
  if #posts == 0 then
    prefix = prefix .. 'posts[0|]:\n'
  end
  return prefix .. prelude.toon.encode(root, { delimiter = '|' })
end

local function main(data, chatIndex)
  if not data or data == '' then
    return ''
  end

  local extractionSuccess, extractionResult = pcall(prelude.queryNodes, 'lb-mini', data)
  if not extractionSuccess then
    print("[Lightboard] Miniboard extraction failed:", tostring(extractionResult))
    return data
  end

  local lastResult = extractionResult and extractionResult[#extractionResult] or nil
  if not lastResult then
    return data
  end

  local renderer = resolveRenderer()
  local board = decodeBoard(lastResult.content)
  local renderData = {
    attributes = lastResult.attributes,
    posts = board.posts,
  }
  local options = getRenderOptions(chatIndex)
  local renderSuccess, rendered = pcall(renderer, triggerId, renderData, options)

  if not renderSuccess then
    error(rendered)
  end

  if type(rendered) ~= 'string' or rendered == '' then
    error('Miniboard renderer must return a non-empty string.')
  end

  return data:sub(1, lastResult.rangeStart - 1)
      .. rendered
      .. data:sub(lastResult.rangeEnd + 1)
end

listenEdit(
  "editDisplay",
  function(tid, data, meta)
    setTriggerId(tid)

    local chatIndex = meta and meta.index or 0

    if chatIndex ~= 0 then
      local position = chatIndex - getChatLength(triggerId)
      if position < -9 then
        return data
      end
    end

    local success, result = pcall(main, data, chatIndex)
    if success then
      return result
    else
      print("[Lightboard] Miniboard display failed:", tostring(result))
      return data .. '<lb-lazy id="lb-mini">오류: ' .. result .. '</lb-lazy>'
    end
  end
)

onButtonClick = async(function(tid, code)
  setTriggerId(tid)

  local prefix = "lb%-mini%-delete/"
  local _, prefixEnd = string.find(code, prefix)

  if not prefixEnd then
    return
  end

  local body = code:sub(prefixEnd + 1)
  if body == "" then
    return
  end

  -- body: {chatIndex}/{postIndex}[/{commentIndex}]
  local parts = prelude.split(body, '_')

  if #parts < 2 then
    return
  end

  local chatIndex = tonumber(parts[1])
  local postIndex = tonumber(parts[2])
  local commentIndex = tonumber(parts[3]) -- nil if deleting post

  local deathMessage = chatIndex .. '번 채팅의 ' .. postIndex .. '번 글을 찾을 수 없습니다.'

  if not chatIndex or not postIndex then
    alertNormal(tid, deathMessage)
    return
  end

  local targetType = commentIndex and '댓글' or '글'
  local confirmed = alertConfirm(tid, '정말 이 ' .. targetType .. '을 지우시겠습니까?'):await()
  if not confirmed then
    return
  end

  local chat = getChat(tid, chatIndex)
  if not chat or not chat.data then
    alertNormal(tid, deathMessage)
    return
  end

  local nodes = prelude.queryNodes('lb-mini', chat.data)
  if not nodes or #nodes == 0 then
    alertNormal(tid, deathMessage)
    return
  end

  local node = nodes[#nodes]
  local board = decodeBoard(node.content)
  local posts = board.posts

  if postIndex < 1 or postIndex > #posts then
    alertNormal(tid, deathMessage)
    return
  end

  if commentIndex then
    local post = posts[postIndex]
    if commentIndex < 1 or commentIndex > #post.comments then
      alertNormal(tid, chatIndex .. '번 채팅 ' .. postIndex .. '번 글의 ' .. commentIndex .. '번 댓글을 찾을 수 없습니다.')
      return
    end
    table.remove(post.comments, commentIndex)
  else
    table.remove(posts, postIndex)
  end

  local newContent = encodeBoard(board)
  local newBlock = node.openTag .. "\n" .. newContent .. "\n</" .. node.tagName .. ">"
  local newData = chat.data:sub(1, node.rangeStart - 1) .. newBlock .. chat.data:sub(node.rangeEnd + 1)

  setChat(tid, chatIndex, newData)
end)
