--! Copyright (c) 2025-2026 amonamona
--! CC BY-NC-SA 4.0 https://creativecommons.org/licenses/by-nc-sa/4.0/
--! LightBoard Stats

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

---Renders a node into HTML.
---@param node Node
---@return string
local function render(node)
  local rawContent = node.content
  if not rawContent or rawContent == "" then
    return "[LightBoard Error: Empty Content]"
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

listenEdit(
  "editDisplay",
  function(tid, data, meta)
    if not data or data == '' then
      return ''
    end

    setTriggerId(tid)

    if meta and meta.index ~= nil then
      local position = meta.index - getChatLength(triggerId)
      if position < -10 then
        return data
      end
    end

    local extractionSuccess, extractionResult = pcall(prelude.queryNodes, 'lb-stats', data)
    if not extractionSuccess then
      print("[LightBoard] Stats extraction failed:", tostring(extractionResult))
      return data
    end

    local lastResult = extractionResult and extractionResult[#extractionResult] or nil
    if not lastResult then
      return data
    end

    local renderSuccess, rendered = pcall(render, lastResult)
    if not renderSuccess then
      print("[LightBoard] Stats render failed:", tostring(rendered))
      rendered = '<lb-lazy id="lb-stats">오류: ' .. tostring(rendered) .. '</lb-lazy>'
    end

    local cleaned = string.gsub(data, '<lb%-stats[^>]*>.-</lb%-stats>', '')

    -- 0: prepend, 1: append
    local renderPosition = getGlobalVar(triggerId, 'toggle_lb-stats.position') or '0'
    if renderPosition == '0' then
      return rendered .. cleaned
    end

    return cleaned .. rendered
  end
)
