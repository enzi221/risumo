local M = {}

local CURRENT_VERSION = '4.3.1'
local CHECKED_KEY = 'lightboard.updateChecked'
local VERSION_URL = 'https://raw.githubusercontent.com/enzi221/risumo/main/lb--be/version'

local function parseVersion(value)
  if type(value) ~= 'string' then
    return nil
  end
  local major, minor, patch = value:match('^(%d+)%.(%d+)%.(%d+)$')
  if not major then
    return nil
  end
  return { tonumber(major), tonumber(minor), tonumber(patch) }
end

local function newerVersion(value)
  local latest = parseVersion(value)
  local current = parseVersion(CURRENT_VERSION)
  if not latest then
    return false
  end
  for i = 1, 3 do
    if latest[i] ~= current[i] then
      return latest[i] > current[i]
    end
  end
  return false
end

local function escapeXML(value)
  return (value:gsub('&', '&amp;'):gsub('<', '&lt;'):gsub('>', '&gt;')
    :gsub('"', '&quot;'):gsub("'", '&#39;'):gsub('{', '&#123;'):gsub('}', '&#125;'))
end

--- Attempts one update check per chat, including failed requests.
--- @param triggerId string
--- @return string notice Empty when disabled, already checked, unavailable, or current.
function M.check(triggerId)
  if getGlobalVar(triggerId, 'toggle_lightboard.skipUpdateCheck') == '1'
      or getChatVar(triggerId, CHECKED_KEY) == '1' then
    return ''
  end

  setChatVar(triggerId, CHECKED_KEY, '1')
  local ok, notice = pcall(function()
    local queryId = triggerId:gsub('[^%w%-._~]', function(char)
      return string.format('%%%02X', string.byte(char))
    end)
    local raw = request(triggerId, VERSION_URL .. '?triggerId=' .. queryId):await()
    if type(raw) ~= 'string' then
      return ''
    end
    local response = json.decode(raw)
    if type(response) ~= 'table' or response.status ~= 200 or type(response.data) ~= 'string' then
      return ''
    end
    local metadata = json.decode(response.data)
    if type(metadata) ~= 'table' or not newerVersion(metadata.version)
        or type(metadata.downloadUrl) ~= 'string'
        or not metadata.downloadUrl:match('^https://[^%s]+$') then
      return ''
    end
    return '<lb-update version="' .. metadata.version .. '">' .. escapeXML(metadata.downloadUrl) .. '</lb-update>'
  end)

  if not ok then
    return ''
  end
  return notice
end

function M.dismiss(triggerId)
  setChatVar(triggerId, 'lightboard.updateDismissed', '1')
  for i, chat in ipairs(getFullChat(triggerId)) do
    local cleaned, count = chat.data:gsub('<lb%-update%s[^>]*>.-</lb%-update>', '')
    if count > 0 then
      setChat(triggerId, i - 1, cleaned)
      reloadChat(triggerId, i - 1)
    end
  end
end

return M
