local lbdata = require('./lbdata')
local pipeline = require('./pipeline')

local M = {}

--- Runs sideEffect onOutput with proper signature.
--- @param triggerId string
--- @param man Manifest
--- @param pipelineResult string
--- @param chatContent string
--- @param chatIndex number
--- @return string modifiedChatContent, string? lbdataContent
local function runSideEffectOnOutput(triggerId, man, pipelineResult, chatContent, chatIndex)
  if not man.onOutput then
    print('[LightBoard Backend] Warning: sideEffect manifest ' .. man.identifier .. ' has no onOutput callback')
    return chatContent, nil
  end

  local success, modifiedOutput, lbdataOutput = pcall(
    man.onOutput,
    triggerId,
    pipelineResult,
    chatContent,
    chatIndex)
  if success and modifiedOutput and prelude.trim(modifiedOutput) ~= '' then
    return modifiedOutput, lbdataOutput
  end

  local reason = success and 'nil 또는 빈 문자열 반환' or tostring(modifiedOutput)
  error('sideEffect 출력 처리 실패(onOutput). ' .. reason)
end

--- @class HandleSideEffectParams
--- @field man Manifest
--- @field action 'reroll'|'interaction'
--- @field result string
--- @field identifier string
--- @field blockID string?
--- @field onError fun(msg: string)

--- Handles sideEffect result processing (shared between reroll and interact).
--- @param triggerId string
--- @param params HandleSideEffectParams
--- @return boolean success
function M.handleSideEffectResult(triggerId, params)
  local latestChat = getFullChat(triggerId)
  local resolved = lbdata.resolveTargets(latestChat)

  if not resolved.targetIdx then
    params.onError('[LightBoard] sideEffect ' .. params.action .. ' 실패. 대상 채팅을 찾을 수 없습니다.')
    return false
  end

  local targetIdx = resolved.targetIdx
  local originalContent = resolved.targetContent or ''
  local lbdataIdx = resolved.lbdataIdx or targetIdx
  local lbdataChatContent = resolved.lbdataContent or originalContent

  ---@cast targetIdx number
  ---@cast lbdataIdx number

  local cleanedContent = lbdata.removeNode(originalContent, params.identifier,
    params.blockID and { id = params.blockID } or nil)

  local onOutputSuccess, modifiedContent, lbdataContent = pcall(
    runSideEffectOnOutput,
    triggerId,
    params.man,
    params.result,
    cleanedContent,
    targetIdx)

  if not onOutputSuccess or not modifiedContent then
    setChat(triggerId, targetIdx, originalContent)
    params.onError('[LightBoard] sideEffect onOutput 실패. ' .. tostring(modifiedContent))
    return false
  end

  M.applyResult(triggerId, {
    man = params.man,
    action = params.action,
    modifiedContent = modifiedContent,
    lbdataContent = lbdataContent,
    targetIdx = targetIdx,
    lbdataIdx = lbdataIdx,
    lbdataChatContent = lbdataChatContent,
  })

  return true
end

--- @class ApplySideEffectParams
--- @field man Manifest
--- @field action 'reroll'|'interaction'
--- @field modifiedContent string
--- @field lbdataContent string?
--- @field targetIdx number
--- @field lbdataIdx number
--- @field lbdataChatContent string

--- Applies sideEffect output and LBDATA updates to target chats.
--- @param triggerId string
--- @param params ApplySideEffectParams
function M.applyResult(triggerId, params)
  local finalChat = params.modifiedContent

  if params.lbdataIdx == params.targetIdx then
    finalChat = lbdata.appendLBDATA(finalChat, params.lbdataContent)
  else
    local mergedLBDATA = lbdata.appendLBDATA(params.lbdataChatContent or '', params.lbdataContent)
    setChat(triggerId, params.lbdataIdx, mergedLBDATA)
  end

  if params.man.onMutation then
    finalChat = params.man.onMutation(triggerId, params.action, finalChat)
  end

  setChat(triggerId, params.targetIdx, finalChat)
end

--- @class RunSideEffectsParams
--- @field sideEffectManifests Manifest[]
--- @field fullChat Chat[]
--- @field maxConcurrent number

--- Executes sideEffect manifests and applies results to chat/LBDATA.
--- @param triggerId string
--- @param params RunSideEffectsParams
function M.runSideEffects(triggerId, params)
  if #params.sideEffectManifests == 0 then
    return
  end

  local sideEffectResults = {}

  for i = 1, #params.sideEffectManifests, params.maxConcurrent do
    local currentChunkPromises = {}
    local chunkEndIndex = math.min(i + params.maxConcurrent - 1, #params.sideEffectManifests)

    for j = i, chunkEndIndex do
      local man = params.sideEffectManifests[j]
      table.insert(currentChunkPromises, pipeline.runPipelineAsync(triggerId, man, params.fullChat, {
        type = 'generation',
        lazy = man.lazy
      }))
    end

    local chunkResults = Promise.all(currentChunkPromises):await()
    if chunkResults then
      for idx, chunkResult in ipairs(chunkResults) do
        local manIdx = i + idx - 1
        sideEffectResults[manIdx] = chunkResult
      end
    end
  end

  local fullChatNewest = getFullChat(triggerId)
  local resolved = lbdata.resolveTargets(fullChatNewest)
  if not resolved.targetIdx then
    print('[LightBoard Backend] locateTargetChat returned nil')
    return
  end

  local targetIdx = resolved.targetIdx
  local currentChatContent = resolved.targetContent or ''
  local lbdataIdx = resolved.lbdataIdx or targetIdx
  local lbdataChatContent = resolved.lbdataContent or currentChatContent

  ---@cast targetIdx number
  ---@cast lbdataIdx number

  local lazyPlaceholders = {}
  local lbdataContents = {}

  for i, man in ipairs(params.sideEffectManifests) do
    local pipelineResult = sideEffectResults[i]
    if pipelineResult and type(pipelineResult) == "string" and pipelineResult ~= "" then
      if pipelineResult:match('^%s*<lb%-lazy') then
        table.insert(lazyPlaceholders, pipelineResult)
      else
        local success, result, lbdata = pcall(
          runSideEffectOnOutput,
          triggerId,
          man,
          pipelineResult,
          currentChatContent,
          targetIdx)
        if success and result then
          currentChatContent = result
          if lbdata and prelude.trim(lbdata) ~= '' then
            table.insert(lbdataContents, lbdata)
          end
        else
          print("[LightBoard Backend] sideEffect onOutput failed for " ..
            man.identifier .. ": " .. tostring(result))
        end
      end
    end
  end

  local appendToLBDATA = {}
  for _, v in ipairs(lazyPlaceholders) do table.insert(appendToLBDATA, v) end
  for _, v in ipairs(lbdataContents) do table.insert(appendToLBDATA, v) end

  if #appendToLBDATA > 0 then
    local appendContent = table.concat(appendToLBDATA, '\n\n')

    if lbdataIdx == targetIdx then
      currentChatContent = lbdata.appendLBDATA(currentChatContent, appendContent)
    else
      lbdataChatContent = lbdata.appendLBDATA(lbdataChatContent, appendContent)
    end
  end

  setChat(triggerId, targetIdx, currentChatContent)
  if lbdataIdx ~= targetIdx then
    setChat(triggerId, lbdataIdx, lbdataChatContent)
  end
end

return M
