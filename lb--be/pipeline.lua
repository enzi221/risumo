local prompt = require('./prompts')
local lbdata = require('./lbdata')
local C = require('./constants')

local M = {}

local VALIDATION_ERROR_PREFIX = "InvalidOutput:"

--- @param triggerId string
--- @param man Manifest
--- @param prom Chat[]
--- @param modeOverride '1'|'2'?
local function runLLM(triggerId, man, prom, modeOverride)
  local mode = modeOverride or man.mode

  if mode == '1' then
    return LLM(triggerId, prom)
  else
    return axLLM(triggerId, prom)
  end
end

--- @param man Manifest
--- @param response LLMResult
--- @return string?
local function cleanLLMResult(man, response)
  if response.success then
    local cleanOutput = response.result:gsub("```[^\n]*\n?", "")
    cleanOutput = lbdata.removeNode(cleanOutput, "Thoughts")
    cleanOutput = lbdata.removeNode(cleanOutput, "lb-process")

    return cleanOutput
  else
    print("[LightBoard Backend] Failed to get LLM response for " .. man.identifier .. ":\n" .. response.result)
    error('LLM 요청 실패. ' .. response.result)
  end
end

--- Pipeline for prompt creation, LLM execution, and result processing.
--- @param triggerId string
--- @param man Manifest
--- @param fullChat Chat[]
--- @param options table
--- @return string?
function M.runPipeline(triggerId, man, fullChat, options)
  local modeType = options.type

  if modeType ~= 'interaction' and options.lazy then
    return '\n<lb-lazy id="' .. man.identifier .. '" />'
  end

  local promptSuccess, promptResult = pcall(prompt.make, triggerId, man, fullChat, modeType, options.extras)
  if not promptSuccess then
    print("[LightBoard] Failed to create prompt for " .. man.identifier .. ": " .. tostring(promptResult))
    return '\n<lb-lazy id="' .. man.identifier .. '" />'
  end
  local prom = promptResult
  print('[LightBoard Backend][VERBOSE] Prompt created.')

  local maxRetries = tonumber(getGlobalVar(triggerId, C.CONFIG.MAX_RETRIES)) or 0
  local retryMode = getGlobalVar(triggerId, C.CONFIG.RETRY_MODE) or '0'

  local attempts = 0

  while true do
    print('[LightBoard Backend][VERBOSE] Prompt submitted. Try #' .. attempts)

    --- @type '1'|'2'|nil
    --- @diagnostic disable-next-line: assign-type-mismatch
    local modeOverride = attempts > 0 and retryMode ~= '0' and retryMode or nil

    local response = runLLM(triggerId, man, prom, modeOverride)
    print('[LightBoard Backend][VERBOSE] Received response.')

    local processSuccess, result = pcall(cleanLLMResult, man, response)
    if not processSuccess then
      error('응답을 처리하지 못했습니다. ' .. tostring(result))
    end
    print('[LightBoard Backend][VERBOSE] Response cleaned.')

    -- critical failure, instant fallback
    if (modeType == 'generation' or modeType == 'reroll') and (not result or result == '' or result == nil) then
      error('모델 응답이 비어있거나 null입니다. 검열됐을 수 있습니다.')
    end

    -- validation from FE
    local valid = true
    local validationError = nil

    if man.onValidate and result then
      print('[LightBoard Backend][VERBOSE] Response validating.')

      local success, err = pcall(man.onValidate, triggerId, result)
      if not success then
        local cleanErr = tostring(err):gsub("^.-:%d+: ", "")
        if cleanErr:find("^" .. VALIDATION_ERROR_PREFIX) then
          -- only if the error is a validation error
          valid = false
          validationError = cleanErr:sub(#VALIDATION_ERROR_PREFIX + 1):match("^%s*(.-)%s*$")
        else
          -- assume success otherwise
          print("[LightBoard] Validation script error in " .. man.identifier .. ": " .. tostring(err))
        end
      end
    end

    if valid or attempts >= maxRetries then
      if valid then
        print('[LightBoard Backend][VERBOSE] Validation complete.')
      else
        print('[LightBoard] Validation failed for ' ..
          man.identifier .. ' but max retries reached: ' .. tostring(validationError))
      end

      if man.onOutput and result and not man.sideEffect then
        local success, modifiedOutput = pcall(man.onOutput, triggerId, result)
        if success and modifiedOutput and modifiedOutput ~= '' then
          result = modifiedOutput
        else
          print("[LightBoard Backend] Failed processing (onOutput) for " ..
            man.identifier .. ": " .. tostring(modifiedOutput))

          local reason = success and 'nil 반환' or tostring(modifiedOutput)
          error('출력 처리 실패(onOutput). ' .. reason .. '\n\n출력:\n' .. result:gsub('\n', '\\n'))
        end
      end

      return result
    end

    attempts = attempts + 1
    print("[LightBoard] Validation failed for " ..
      man.identifier .. ". Retrying (" .. attempts .. "/" .. maxRetries .. "): " .. tostring(validationError))

    table.insert(prom, {
      content = result,
      role = 'char'
    })

    local thoughtsFlag = getGlobalVar(triggerId, C.CONFIG.THOUGHTS) or '0'
    local printInstruction = string.format(
      'Only print the corrected full data wrapped in %s, without apologies, explanations, or any preambles.',
      man.identifier)
    if thoughtsFlag == '0' then
      printInstruction =
          string.format(
            'Only print the %s node and corrected full data in it, without any apologies, explanations, or preambles. Analyze the error sources step-by-step in <lb-process> block. (Ignore previous lb-process usage instruction; only use it for correcting the data.)',
            man.identifier)
    end

    local retryInstruction = string.format([[<system>
Validation error!

Your previous output did not adhere to the required format, or contained invalid data.
Error message: %s

Please fix your last output into correct structure as previously instructed, while keeping the data intact.

%s
</system>]],
      validationError, printInstruction)

    table.insert(prom, {
      role = 'user',
      content = retryInstruction
    })
  end
end

--- @type fun(triggerId: string, man: Manifest, chatContext: Chat[], options: table): Promise<string?>
M.runPipelineAsync = async(M.runPipeline)

return M
