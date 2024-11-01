---@class PlayerClass
local player = {}

---@enum Player
player = {
    MARIO = "MARIO",
    LUIGI = "LUIGI"
}

---@type table<Player, string>
local strings = {
    [player.MARIO] = "M",
    [player.LUIGI] = "L"
}

---@param player Player
---@return string
function player.to_string(player)
    return strings[player]
end

return player
