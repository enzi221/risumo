--- @meta

--- @param triggerId string
--- @return string
function getDescription(triggerId) end

--- @class LoreBook
--- @field alwaysActive boolean
--- @field comment string
--- @field content string
--- @field insertorder number
--- @field key string
--- @field secondKey string

--- @param triggerId string
--- @param search string
--- @return LoreBook[]
function getLoreBooks(triggerId, search) end

--- @class LoreBookLoaded
--- @field data string
--- @field role 'char'|'system'|'user'

--- @param triggerId string
--- @param reserve number
--- @return LoreBookLoaded[]
function loadLoreBooks(triggerId, reserve) end

--- @param triggerId string
--- @return string
function getPersonaDescription(triggerId) end

--- @param triggerId string
--- @return string
function getPersonaName(triggerId) end

--- @param triggerId string
--- @param url string
--- @return Promise<string|nil> JSON string containing integer `status` and string `data`; errors use status 400, 413, or 429.
function request(triggerId, url) end
