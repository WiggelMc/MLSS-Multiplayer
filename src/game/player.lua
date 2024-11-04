---@class PlayerClass
local player = {}

---@enum Player
player = {
    MARIO = "MARIO",
    LUIGI = "LUIGI"
}

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
