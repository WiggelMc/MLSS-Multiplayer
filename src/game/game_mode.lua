---@class GameModeClass
local GameMode = {}

---@enum GameMode
GameMode = {
    MENU = "MODE_MENU",
    BATTLE = "MODE_BATTLE",
    LEVEL_UP = "MODE_LEVEL_UP",
    FIELD = "MODE_FIELD"
}

---@type table<GameMode, string>
local Strings = {
    [GameMode.MENU] = "M",
    [GameMode.BATTLE] = "B",
    [GameMode.LEVEL_UP] = "L",
    [GameMode.FIELD] = "F"
}

---@param mode GameMode
---@return string
function GameMode.toString(mode)
    return Strings[mode]
end

return GameMode
