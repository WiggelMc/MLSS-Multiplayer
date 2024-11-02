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

---@param selected_player Player
---@return Player
function player.get_other(selected_player)
    if (selected_player == player.MARIO) then
        return player.LUIGI
    else
        return player.MARIO
    end
end

return player
