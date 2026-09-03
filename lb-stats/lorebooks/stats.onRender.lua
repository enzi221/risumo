--! Copyright (c) 2025-2026 amonamona
--! CC BY-NC-SA 4.0 https://creativecommons.org/licenses/by-nc-sa/4.0/
--! Lightboard Stats

---Renders a node into HTML.
---@param node Node
---@return string
local function render(triggerId, node)
  local rawContent = node.content
  if not rawContent or rawContent == "" then
    return "[Lightboard Error: Empty Content]"
  end

  ---@class StatsData
  ---@field custom string
  ---@field equipments string
  ---@field location string
  ---@field outfit string
  ---@field time string
  ---@field weather string

  ---@type StatsData
  local parsed = prelude.toon.decode(node.content)

  local custom = getGlobalVar(triggerId, 'toggle_lb-stats.custom')

  return tostring(h.section {
    data_id = 'lb-stats',
    class = "lb-stats-container",
    h.div {
      class = "lb-stats-header",
      h.span "STATUS",
      h.button['lb-reroll'] {
        risu_btn = 'lb-reroll__lb-stats',
        type = 'button',
        h.lb_reroll_icon { closed = true }
      },
    },
    h.div {
      class = "lb-stats-grid",
      h.div {
        class = "lb-stats-item",
        h.span { class = "lb-stats-label", "Location" },
        h.span { class = "lb-stats-value", parsed.location or "unknown" }
      },
      h.div {
        class = "lb-stats-item",
        h.span { class = "lb-stats-label", "Time" },
        h.span { class = "lb-stats-value", parsed.time or "unknown" }
      },
      h.div {
        class = "lb-stats-item",
        h.span { class = "lb-stats-label", "Weather" },
        h.span { class = "lb-stats-value", parsed.weather or "unknown" }
      },
      h.div {
        class = "lb-stats-item lb-stats-full",
        h.span { class = "lb-stats-label", "Outfit" },
        h.span { class = "lb-stats-value", parsed.outfit or "unknown" }
      },
      getGlobalVar(triggerId, 'lb-stats.equipments') ~= '0' and h.div {
        class = "lb-stats-item lb-stats-full",
        h.span { class = "lb-stats-label", "Equipments" },
        h.span { class = "lb-stats-value", parsed.equipments or "unknown" }
      } or nil,
      custom ~= '' and custom ~= 'null' and h.div {
        class = "lb-stats-item lb-stats-full",
        h.span { class = "lb-stats-label", custom },
        h.span { class = "lb-stats-value", parsed.custom or "none" }
      } or nil,
    },
  })
end

local function main(tid, data, chatIndex, chatLength)
  if not data or data == '' then
    return ''
  end

  if chatIndex ~= 0 then
    local position = chatIndex - chatLength
    if position < -9 then
      return data
    end
  end

  local extractionSuccess, extractionResult = pcall(prelude.queryNodes, 'lb-stats', data)
  if not extractionSuccess then
    print("[Lightboard] Stats extraction failed:", tostring(extractionResult))
    return data
  end

  local lastResult = extractionResult and extractionResult[#extractionResult] or nil
  if not lastResult then
    return data
  end

  local output = ''
  local lastIndex = 1

  -- 0: prepend, 1: append
  local position = getGlobalVar(tid, 'toggle_lb-stats.position') or '0'

  for i = 1, #extractionResult do
    local match = extractionResult[i]
    if match.rangeStart > lastIndex then
      output = output .. '\n\n' .. data:sub(lastIndex, match.rangeStart - 1)
    end
    if i == #extractionResult then
      if position == '0' then
        output = render(tid, lastResult) .. output
      else
        output = output .. render(tid, lastResult)
      end
    end
    lastIndex = match.rangeEnd + 1
  end

  return output .. data:sub(lastIndex)
end

return main
