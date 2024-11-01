---@class GameModeClass
local game_mode = {}

---@enum GameMode
game_mode = {
    MENU = "MODE_MENU",
    BATTLE = "MODE_BATTLE",
    LEVEL_UP = "MODE_LEVEL_UP",
    FIELD = "MODE_FIELD"
}

---@type table<GameMode, string>
local strings = {
    [game_mode.MENU] = "M",
    [game_mode.BATTLE] = "B",
    [game_mode.LEVEL_UP] = "L",
    [game_mode.FIELD] = "F"
}

---@param mode GameMode
---@return string
function game_mode.to_string(mode)
    return strings[mode]
end

return game_mode
