--- @meta

--- @class Prompt
--- @field content string
--- @field role 'char'|'system'|'user'
local Prompt = {}

--- @class LLMResult
--- @field result string
--- @field success boolean
local LLMResult = {}

--- @param triggerId string
--- @param prompt Prompt[]
--- @param multimedia? boolean
--- @param options? { streaming?: boolean }
--- @return LLMResult
function LLM(triggerId, prompt, multimedia, options) end

--- @param triggerId string
--- @param prompt Prompt[]
--- @param multimedia? boolean
--- @param options? { streaming?: boolean }
--- @return LLMResult
function axLLM(triggerId, prompt, multimedia, options) end

--- @param triggerId string
--- @param prompt string
--- @param negativePrompt string
--- @return Promise<string>
function generateImage(triggerId, prompt, negativePrompt) end

--- @param triggerId string
--- @param text string
--- @return Promise<number>
function getTokens(triggerId, text) end
