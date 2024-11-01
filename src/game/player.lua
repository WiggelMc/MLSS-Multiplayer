---@class PlayerClass
local Player = {}

---@enum Player
Player = {
    MARIO = "MARIO",
    LUIGI = "LUIGI"
}

---@type table<Player, string>
local Strings = {
    [Player.MARIO] = "M",
    [Player.LUIGI] = "L"
}

---@param player Player
---@return string
function Player.toString(player)
    return Strings[player]
end

return Player
