--! Copyright (c) 2026 amonamona
--! CC BY-NC-SA 4.0 https://creativecommons.org/licenses/by-nc-sa/4.0/
--! LightBoard XNAI

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
---@field characters { positive: string; negative: string }[]
---@field inlay? string
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

---@class XNAIPinnedItem
---@field chatIndex number
---@field sceneIndex number
---@field label string
---@field desc XNAIDescriptor

---@param desc XNAIDescriptor
---@return { positive: string, negative: string }
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
      table.insert(negativeParts, character.negative)
    end
  end

  return { positive = t_concat(positiveParts, ' | '), negative = t_concat(negativeParts, ' | ') }
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
            prompts.negative,
          }
        } or nil

        local fullsizePop = h.dialog['lb-xnai-fullsize-pop'] {
          id = popID,
          popover = '',
          h.div['lb-xnai-fullsize-pop-body'] {
            h.button {
              popovertarget = popID,
              type = 'button',
              inlay,
            },
            promptPreview,
            h.div['lb-xnai-fullsize-actions'] { table.unpack(createToolbar(true)) },
          }
        }

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
      -- not generated yet and has data in the stack: can generate new
      if inlay == '' and stackItem and stackItem.data.keyvis then
        local placeholder = h.button['lb-xnai-placeholder'] {
          risu_btn = t_concat({ 'lb-xnai-gen/', chatIndex, '_-1' }),
          type = 'button',
          '✦ 키 비주얼 생성',
          stackItem and stackItem.data.keyvis and h.button['lb-xnai-toolbar-btn'] {
            risu_btn = t_concat({ 'lb-xnai-gen/', chatIndex }),
            title = '전체 생성',
            type = 'button',
            h.lb_xnai_ff_icon { closed = true },
          } or nil,
          chatIndex == chatLength - 1 and h.button['lb-xnai-toolbar-btn'] {
            risu_btn = 'lb-reroll__lb-xnai',
            title = '전체 프롬프트 재생성',
            type = 'button',
            h.lb_reroll_icon { closed = true },
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
        local inStack = stackItem and stackItem.data.keyvis

        local function createToolbar(fullsizePop)
          return {
            -- generated and has data in the stack: can regenerate
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
            chatIndex == chatLength - 1 and h.button['lb-xnai-toolbar-btn'] {
              popovertarget = fullsizePop and popID or nil,
              risu_btn = 'lb-reroll__lb-xnai',
              title = '전체 프롬프트 재생성',
              type = 'button',
              h.lb_reroll_icon { closed = true },
            } or nil,
            fullsizePop and inStack and h.label['lb-xnai-toolbar-btn'] {
              htmlFor = promptID,
              title = '프롬프트 확인',
              h.lb_comment_icon { closed = true }
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
            prompts.negative,
          }
        } or nil

        local fullsizePop = h.dialog['lb-xnai-fullsize-pop'] {
          id = popID,
          popover = '',
          h.div['lb-xnai-fullsize-pop-body'] {
            h.button {
              popovertarget = popID,
              type = 'button',
              inlay,
            },
            promptPreview,
            h.div['lb-xnai-fullsize-actions'] { table.unpack(createToolbar(true)) },
          }
        }

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
    if xnaiPos == '0' then
      out = kv .. '\n\n' .. out
    else
      out = out .. '\n\n' .. kv
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
    local slot = parts[2] and tonumber(parts[2])

    if not chatIndex or not slot then
      return
    end

    local confirmMsg = '정말 이 씬을 지우시겠습니까?'
    local confirmed = alertConfirm(tid, confirmMsg):await()
    if not confirmed then
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

    if stackItem and stackItem.data.scenes[slot] then
      stackItem.data.scenes[slot] = nil
    end

    setState(triggerId, 'lb-xnai-stack', fullState)

    local targetChat = getChat(triggerId, chatIndex)
    local targetNode = prelude.queryNodes('lb-xnai', targetChat.data, { of = tostring(slot), scene = 'true' })

    if #targetNode > 1 then
      setChat(triggerId, chatIndex, t_concat({
        targetChat.data:sub(1, targetNode[1].rangeStart - 1),
        targetChat.data:sub(targetNode[1].rangeEnd + 1),
      }))
      return
    else
      reloadChat(triggerId, chatIndex)
    end

    return
  end

  -- lb-xnai-gen/{chatIndex}_{slot}
  local genPrefix = 'lb%-xnai%-gen/'
  local _, genPrefixEnd = string.find(code, genPrefix)

  if not genPrefixEnd then
    return
  end

  local chatIndex, slot

  local body = code:sub(genPrefixEnd + 1)
  local parts = prelude.split(body, '_')
  chatIndex = tonumber(parts[1])
  slot = parts[2]

  if not chatIndex then
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

  if not stackItem or (slot ~= nil and (forKeyvis and not stackItem.data.keyvis) and not stackItem.data.scenes[slot]) then
    alertNormal(triggerId, '이미지 생성 데이터가 사라졌어요. 오래된 이미지의 데이터는 유지하지 않습니다. 저장 개수 토글을 늘리세요.')
    return
  end

  ---@type table<number, XNAIDescriptor>
  local descriptors = {}
  local count = 0
  if slot then
    local desc = forKeyvis and stackItem.data.keyvis or stackItem.data.scenes[slot]
    if desc then
      count = count + 1
      descriptors[slot] = desc
    end
  else
    if stackItem.data.keyvis then
      count = count + 1
      descriptors['-1'] = stackItem.data.keyvis
    end
    for _, desc in pairs(stackItem.data.scenes or {}) do
      count = count + 1
      descriptors[tostring(desc.slot)] = desc
    end
  end

  if count == 0 then
    return
  end

  local message = [[---
[LBDATA START]
<lb-rerolling><div class="lb-pending lb-rerolling"><span class="lb-pending-note">이미지 생성 중, 채팅을 보내거나 다른 작업을 하지 마세요...</span></div></lb-rerolling>
[LBDATA END]
---]]
  addChat(tid, 'user', message)

  local gen = prelude.import(triggerId, 'lb-xnai.gen')
  for _, desc in pairs(descriptors) do
    local success, data = pcall(gen.generate, triggerId, desc)
    if success then
      desc.inlay = data
    else
      alertNormal(tid, '이미지 생성 중 오류가 발생했습니다.\n' .. tostring(data))
      removeChat(tid, -1)
      return
    end
  end

  local out = getChat(triggerId, chatIndex).data
  local allTargetNodes = prelude.queryNodes('lb-xnai', out)

  -- reverse order to not mess up ranges
  for i = #allTargetNodes, 1, -1 do
    local node = allTargetNodes[i]
    local isKeyvis = node.attributes.kv == 'true'
    local targetNodeSlot = isKeyvis and '-1' or node.attributes.scene

    if descriptors[targetNodeSlot] and descriptors[targetNodeSlot].inlay then
      local attribute = isKeyvis and 'kv' or t_concat({ 'scene="', targetNodeSlot, '"' })

      out = t_concat({
        out:sub(1, node.rangeStart - 1),
        t_concat({ '<lb-xnai ', attribute, '>', descriptors[targetNodeSlot].inlay, '</lb-xnai>' }),
        out:sub(node.rangeEnd + 1),
      })
    end
  end

  setChat(triggerId, chatIndex, out)
  removeChat(tid, -1)
end)
