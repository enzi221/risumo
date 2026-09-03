# Lightboard Prelude

The standard library is then available through the global `prelude` table.

```lua
---@param triggerId string
---@param scope string?
---@param ... any
function prelude.info(triggerId, scope, ...) end

---@param triggerId string
---@param level 'VERBOSE'|'INFO'
---@return boolean
function prelude.logEnabled(triggerId, level) end

---@param triggerId string
---@param scope string?
---@param ... any
function prelude.verbose(triggerId, scope, ...) end

---@param str string
---@return string
function prelude.trim(str) end

---Escape HTML entities.
---@param str string
---@return string
function prelude.escEntities(str) end

---Escape a string to use in Lua string pattern.
---@param str string
---@return string
function prelude.escMatch(str) end

---@class Node
---@field attributes table<string, string>
---@field content string
---@field rangeEnd number
---@field rangeStart number

---Extracts all nodes.
---@param text string
---@return Node[]
function prelude.queryNodes(tagNameRaw, text) end

--- Removes all XML tagged blocks that is not <(tagsToKeep)> and without "keepalive" attribute.
--- @param text string
--- @param tagsToKeep string[]?
--- @return string
function prelude.removeAllNodes(text, tagsToKeep) end

---Get a lorebook with the highest insert order.
---@param triggerId string
---@param name string
---@return LoreBook?
function prelude.getPriorityLoreBook(triggerId, name) end

---@param str string
---@param sep string
---@return string[]
function prelude.split(str, sep) end
```

`prelude.verbose()` and `prelude.info()` follow the backend `lightboard.logLevel` toggle. Its levels are `VERBOSE`, `INFO`, and `NONE`, with `VERBOSE` as the default. Use `prelude.logEnabled()` before constructing an expensive log value. Errors are not controlled by this diagnostic log level.

For example, `prelude.split('a,b,c', ',')` returns `{ 'a', 'b', 'c' }`.

`prelude.toon.decode()` accepts `⇥` at the start of a line as one indentation level. Use visible indentation markers in prompt examples when the request transport does not preserve leading spaces. Keep standard spaces in generated TOON when the transport preserves them.

## Rendering HTML example with h()

The prelude also provides the `h` hyperscript-like HTML rendering function. It automatically escapes all strings passed to it.

```lua
local function render(node)
  local rawContent = node.content
  if not rawContent or rawContent == "" then
    return "[Lightboard Error: Empty Content]"
  end

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
        class = "lb-stats-item lb-stats-full",
        h.span { class = "lb-stats-label", "Outfit" },
        h.span { class = "lb-stats-value", parsed.outfit or "unknown" }
      },
      getGlobalVar(triggerId, 'toggle_lb-stats.equipments') ~= '0' and h.div {
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
```

Use `hraw()` to exclude a string from the escape: `h.span { hraw("<br />") }`.
