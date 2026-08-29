--- @meta

--- @class Chat
--- @field data string
--- @field role 'char'|'system'|'user'
--- @field time number
local Chat = {}

--- @param triggerId string
--- @return string
function getCharacterLastMessage(triggerId) end

--- @param triggerId string
--- @return number
function getChatLength(triggerId) end

--- @param triggerId string
--- @return Chat[]
function getFullChat(triggerId) end

--- Returns up to `count` recent main-chat entries in chronological order.
--- @param triggerId string
--- @param count number Negative values become 0. Fractional values are rounded down.
--- @return Chat[]
function getRecentChats(triggerId, count) end

--- @param triggerId string
--- @param index number
--- @return Chat
function getChat(triggerId, index) end

--- @param triggerId string
--- @param index number
--- @param msg string
--- @return nil
function setChat(triggerId, index, msg) end

--- @param triggerId string
--- @param chats Chat[]
function setFullChat(triggerId, chats) end

--- @param triggerId string
--- @param index number
function removeChat(triggerId, index) end
