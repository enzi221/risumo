local t_concat = table.concat
local triggerId = ''

local function setTriggerId(tid)
  triggerId = tid
  if type(prelude) ~= 'nil' then
    prelude.import(tid, 'toon.decode')
    return
  end
  local source = getLoreBooks(triggerId, 'lightboard-prelude')
  if not source or #source == 0 then
    error('Failed to load lightboard-prelude.')
  end
  load(source[1].content, '@prelude', 't')()
  prelude.import(tid, 'toon.decode')
end

---@class XNAIDescriptor
---@field camera string
---@field characters XNAIPromptSet[]
---@field scene string
---@field slot? number

---@class XNAIResponse
---@field keyvis? XNAIDescriptor
---@field scenes? XNAIDescriptor[]

---@class XNAIStackData
---@field keyvis? XNAIDescriptor
---@field scenes? table<string, XNAIDescriptor>

---@class XNAIStackItem
---@field chatIndex number
---@field data XNAIStackData

---@param desc XNAIDescriptor
---@return XNAIPromptSet
local function buildRawPrompt(desc)
  local lead = {}
  if desc.scene and desc.scene ~= '' then
    table.insert(lead, desc.scene)
  end
  if desc.camera and desc.camera ~= '' then
    table.insert(lead, desc.camera)
  end

  local leadText = #lead > 0 and t_concat(lead, ', ') or ''

  local positiveParts = {
    leadText
  }
  local negativeParts = {
    ''
  }

  if desc.characters then
    for _, character in ipairs(desc.characters) do
      table.insert(positiveParts, character.positive)
      table.insert(negativeParts, character.negative or '')
    end
  end

  return { positive = t_concat(positiveParts, ' | '), negative = t_concat(negativeParts, ' | ') }
end

---@param popID string
---@param inlay string
---@param promptPreview any?
---@param toolbarItems any[]
---@return any
local function createFullsizePop(popID, inlay, promptPreview, toolbarItems)
  return h.dialog['lb-xnai-fullsize-pop'] {
    id = popID,
    popover = '',
    h.div['lb-xnai-fullsize-pop-body'] {
      h.button {
        popovertarget = popID,
        type = 'button',
        inlay,
      },
      promptPreview,
      h.div['lb-xnai-fullsize-actions'] { table.unpack(toolbarItems) },
    }
  }
end

---@param data string
---@param chatIndex number
---@param chatLength number
---@param stackItem XNAIStackItem?
---@return string
local function renderInline(data, chatIndex, chatLength, stackItem)
  local imageNodes = prelude.queryNodes('lb-xnai', data)
  if #imageNodes == 0 then
    return data
  end

  local out = data

  -- kv should be appended/prepended after the loop to not mess up ranges
  ---@type string
  local kv = nil

  -- reverse order to not mess up ranges
  for nodeIndex = #imageNodes, 1, -1 do
    local imageNode = imageNodes[nodeIndex]
    local slot = imageNode.attributes.scene
    local inlay = prelude.trim(imageNode.content)

    local popID = t_concat({ 'lb-xnai-pop-', chatIndex, '-', nodeIndex })
    local promptID = t_concat({ 'lb-xnai-prompt-', chatIndex, '-', nodeIndex })

    if slot then
      -- scenes
      -- not generated yet and has data in the stack: can generate new
      if inlay == '' and stackItem and stackItem.data.scenes[slot] then
        local placeholderText = t_concat({ '씬 #', nodeIndex, ' 생성' })
        local placeholder = h.button['lb-xnai-placeholder'] {
          risu_btn = t_concat({ 'lb-xnai-gen/', chatIndex, '_', slot }),
          type = 'button',
          t_concat({ '✦ ', placeholderText }),
        }
        out = t_concat({
          out:sub(1, imageNode.rangeStart - 1),
          tostring(h.div['lb-xnai-placeholder-wrapper'] { placeholder }),
          out:sub(imageNode.rangeEnd + 1),
        })
      elseif inlay ~= '' then
        local inStack = stackItem and stackItem.data.scenes[slot]

        local function createToolbar(fullsizePop)
          return {
            -- generated and has data in the stack: can regenerate
            inStack and h.button['lb-xnai-toolbar-btn'] {
              popovertarget = fullsizePop and popID or nil,
              risu_btn = t_concat({ 'lb-xnai-gen/', chatIndex, '_', slot }),
              title = '재생성',
              type = 'button',
              h.lb_xnai_play_icon { closed = true },
            } or nil,
            h.button['lb-xnai-toolbar-btn'] {
              popovertarget = fullsizePop and popID or nil,
              risu_btn = t_concat({ 'lb-xnai-delete/', chatIndex, '_', slot }),
              title = '제거',
              type = 'button',
              h.lb_trash_icon { closed = true },
            },
            fullsizePop and inStack and h.label['lb-xnai-toolbar-btn'] {
              htmlFor = promptID,
              title = '프롬프트 확인',
              h.lb_comment_icon { closed = true }
            } or nil,
            inStack and h.button['lb-xnai-toolbar-btn'] {
              popovertarget = fullsizePop and popID or nil,
              risu_btn = t_concat({ 'lb-xnai-edit/', chatIndex, '_', slot }),
              title = '프롬프트 편집',
              h.lb_xnai_edit_icon { closed = true }
            } or nil,
          }
        end

        ---@diagnostic disable-next-line: need-check-nil
        local prompts = inStack and buildRawPrompt(stackItem.data.scenes[slot]) or { positive = '', negative = '' }
        local promptPreview = inStack and h.div['lb-xnai-fullsize-prompt-wrapper'] {
          h.input { id = promptID, type = 'checkbox' },
          h.pre['lb-xnai-fullsize-prompt'] {
            '[Positive]\n',
            prompts.positive,
            h.br { void = true },
            h.br { void = true },
            '[Negative]\n',
            prompts.negative or '',
          }
        } or nil

        local fullsizePop = createFullsizePop(popID, inlay, promptPreview, createToolbar(true))

        local inlineImage = h.button {
          popovertarget = popID,
          type = 'button',
          inlay,
        }

        out = t_concat({
          out:sub(1, imageNode.rangeStart - 1),
          tostring(h.div['lb-xnai-inlay-wrapper'] {
            h.div['lb-xnai-inlay'] {
              h.div['lb-xnai-inlay-actions'] { table.unpack(createToolbar()) }, inlineImage, fullsizePop
            }
          }),
          out:sub(imageNode.rangeEnd + 1),
        })
      end
    else
      -- kv
      local inStack = stackItem and stackItem.data.keyvis

      if inlay == '' and inStack then
        local placeholder = h.button['lb-xnai-placeholder'] {
          risu_btn = t_concat({ 'lb-xnai-gen/', chatIndex, '_-1' }),
          type = 'button',
          '✦ 키 비주얼 생성',
          inStack and h.button['lb-xnai-toolbar-btn'] {
            risu_btn = t_concat({ 'lb-xnai-gen/', chatIndex }),
            title = '전체 생성',
            type = 'button',
            h.lb_xnai_ff_icon { closed = true },
          } or nil,
        }

        kv = tostring(h.div['lb-xnai-placeholder-wrapper'] {
          placeholder
        })

        out = t_concat({
          out:sub(1, imageNode.rangeStart - 1),
          out:sub(imageNode.rangeEnd + 1),
        })
      elseif inlay ~= '' then
        local function createToolbar(fullsizePop)
          return {
            inStack and h.button['lb-xnai-toolbar-btn'] {
              popovertarget = fullsizePop and popID or nil,
              risu_btn = t_concat({ 'lb-xnai-gen/', chatIndex, '_-1' }),
              title = '재생성',
              type = 'button',
              h.lb_xnai_play_icon { closed = true },
            } or nil,
            inStack and h.button['lb-xnai-toolbar-btn'] {
              popovertarget = fullsizePop and popID or nil,
              risu_btn = t_concat({ 'lb-xnai-gen/', chatIndex }),
              title = '전체 재생성',
              type = 'button',
              h.lb_xnai_ff_icon { closed = true },
            } or nil,
            fullsizePop and inStack and h.label['lb-xnai-toolbar-btn'] {
              htmlFor = promptID,
              title = '프롬프트 확인',
              h.lb_comment_icon { closed = true }
            } or nil,
            inStack and h.button['lb-xnai-toolbar-btn'] {
              popovertarget = fullsizePop and popID or nil,
              risu_btn = t_concat({ 'lb-xnai-edit/', chatIndex, '_-1' }),
              title = '프롬프트 편집',
              h.lb_xnai_edit_icon { closed = true }
            } or nil,
          }
        end

        ---@diagnostic disable-next-line: need-check-nil
        local prompts = inStack and buildRawPrompt(stackItem.data.keyvis) or { positive = '', negative = '' }
        local promptPreview = inStack and h.div['lb-xnai-fullsize-prompt-wrapper'] {
          h.input { id = promptID, type = 'checkbox' },
          h.pre['lb-xnai-fullsize-prompt'] {
            '[Positive]\n',
            prompts.positive,
            h.br { void = true },
            h.br { void = true },
            '[Negative]\n',
            prompts.negative or '',
          }
        } or nil

        local fullsizePop = createFullsizePop(popID, inlay, promptPreview, createToolbar(true))

        kv = tostring(h.div['lb-xnai-kv-wrapper'] {
          h.div['lb-xnai-kv-actions'] { table.unpack(createToolbar()) },
          h.button['lb-xnai-kv'] {
            popovertarget = popID,
            type = 'button',
            inlay
          },
          fullsizePop
        })

        out = t_concat({
          out:sub(1, imageNode.rangeStart - 1),
          out:sub(imageNode.rangeEnd + 1),
        })
      end
    end
  end

  if kv then
    local xnaiPos = getGlobalVar(triggerId, 'toggle_lb-xnai.kv.position') or '0'
    local lbdataAtTop = out:match('^%s*%-%-%-\n%[LBDATA START%]')
    local lbdataAtBottom = out:match('%[LBDATA END%]%s*\n%-%-%-\n?%s*$')

    if xnaiPos == '0' then
      if lbdataAtTop then
        local lbdataEndPos = out:find('%[LBDATA END%]%s*\n%-%-%-')
        local insertPos = out:find('\n', out:find('%-%-%-', lbdataEndPos))
        if insertPos then
          out = out:sub(1, insertPos) .. '\n' .. kv .. out:sub(insertPos + 1)
        else
          out = out .. '\n\n' .. kv
        end
      else
        out = kv .. '\n\n' .. out
      end
    else
      local lbdataStartPos = lbdataAtBottom and out:find('%-%-%-\n%[LBDATA START%]')
      if lbdataStartPos then
        out = out:sub(1, lbdataStartPos - 1) .. kv .. '\n\n' .. out:sub(lbdataStartPos)
      else
        out = out .. '\n\n' .. kv
      end
    end
  end

  return out
end

listenEdit(
  "editDisplay",
  function(tid, data, meta)
    setTriggerId(tid)

    if not meta or not meta.index then
      return data
    end

    local chatLength = getChatLength(triggerId)
    local position = meta.index - chatLength
    if position < -5 then
      return data
    end

    ---@type XNAIStackItem[]
    local fullState = getState(triggerId, 'lb-xnai-stack') or {}

    ---@type XNAIStackItem?
    local stackItem = nil
    for _, item in ipairs(fullState) do
      if item.chatIndex == meta.index then
        stackItem = item
        break
      end
    end

    local success, result = pcall(renderInline, data, meta.index, chatLength, stackItem)
    if success then
      return result
    end

    print("[LightBoard] Illustration inline render failed:", tostring(result))
    return data
  end
)

---@type XNAIDeleteHandler
local deleteHandler = require('./xnai_deleteHandler')

---@type XNAIEditHandler
local editHandler = require('./xnai_editHandler')

---@type XNAIRegenHandler
local regenHandler = require('./xnai_regenHandler')

onButtonClick = async(function(tid, code)
  setTriggerId(tid)

  -- lb-xnai-delete/{chatIndex}_{slot}
  local deletePrefix = 'lb%-xnai%-delete/'
  local _, deletePrefixEnd = string.find(code, deletePrefix)

  if deletePrefixEnd then
    local body = code:sub(deletePrefixEnd + 1)
    if body == '' then
      return
    end

    local parts = prelude.split(body, '_')
    if #parts < 1 then
      return
    end

    local chatIndex = tonumber(parts[1])
    local slot = parts[2]

    if not chatIndex or not slot then
      return
    end

    return deleteHandler.deleteScene(tid, chatIndex, slot)
  end

  -- lb-xnai-gen/{chatIndex}_{slot?}
  local genPrefix = 'lb%-xnai%-gen/'
  local _, genPrefixEnd = string.find(code, genPrefix)

  if genPrefixEnd then
    local body = code:sub(genPrefixEnd + 1)
    local parts = prelude.split(body, '_')
    local chatIndex = tonumber(parts[1])
    local slot = parts[2]

    if not chatIndex then
      return
    end

    return regenHandler.regenerate(tid, chatIndex, slot)
  end

  -- lb-xnai-edit/{chatIndex}_{slot}
  local editPrefix = 'lb%-xnai%-edit/'
  local _, editPrefixEnd = string.find(code, editPrefix)

  if editPrefixEnd then
    local body = code:sub(editPrefixEnd + 1)
    local parts = prelude.split(body, '_')
    local chatIndex = tonumber(parts[1])
    local slot = parts[2]

    if not chatIndex or not slot then
      return
    end

    return editHandler.edit(tid, chatIndex, slot)
  end
end)

onStart = function(tid)
  setTriggerId(tid)

  local fullChat = getFullChat(triggerId)
  local lastChat = fullChat[#fullChat]
  local secondLastChat = fullChat[#fullChat - 1]

  local promptNode = prelude.queryNodes('lb-xnai-editing', secondLastChat.data)
  if #promptNode == 0 then
    return
  end

  local chatIndex = tonumber(promptNode[1].attributes.chatIndex)
  local slot = promptNode[1].attributes.slot

  if not chatIndex or not slot or slot == '' then
    return
  end

  ---@type XNAIStackItem[]
  local fullState = getState(triggerId, 'lb-xnai-stack') or {}

  ---@type XNAIStackItem?
  local stackItem = nil
  for _, item in ipairs(fullState) do
    if item.chatIndex == chatIndex then
      stackItem = item
      break
    end
  end

  local forKeyvis = slot == '-1'
  if not stackItem or ((forKeyvis and not stackItem.data.keyvis) and not stackItem.data.scenes[slot]) then
    return
  end

  stopChat(triggerId)

  local camera = lastChat.data:match("%[Camera%]%s*(.-)%s*%[Scene%]")
  local scene = lastChat.data:match("%[Scene%]%s*(.-)%s*%[CharP%]")
  local charP = lastChat.data:match("%[CharP%]%s*(.-)%s*%[CharN%]")
  local charN = lastChat.data:match("%[CharN%]%s*(.*)")

  camera = camera and prelude.trim(camera) or ''
  scene = scene and prelude.trim(scene) or ''
  charP = charP and prelude.trim(charP) or ''
  charN = charN and prelude.trim(charN) or ''

  local charPParts = prelude.split(charP, '|')
  local charNParts = prelude.split(charN, '|')
  ---@type XNAIPromptSet[]
  local characters = {}
  local maxLen = math.max(#charPParts, #charNParts)
  for i = 1, maxLen do
    table.insert(characters, {
      positive = prelude.trim(charPParts[i] or ''),
      negative = prelude.trim(charNParts[i] or ''),
    })
  end

  if forKeyvis then
    stackItem.data.keyvis = {
      camera = camera,
      scene = scene,
      characters = characters,
    }
  else
    stackItem.data.scenes[slot] = {
      camera = camera,
      characters = characters,
      scene = scene,
      slot = tonumber(slot),
    }
  end

  setState(triggerId, 'lb-xnai-stack', fullState)
  reloadChat(triggerId, chatIndex)
  removeChat(triggerId, -2)
  removeChat(triggerId, -1)
end
