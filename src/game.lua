---@class Game
local game = {}


---@class (exact) Game.GuiText
---@field mode string?
---@field front_player string?
---@field battle_player string?

---@param mode Game.Mode
---@param front_player Game.Player
---@param battle_player Game.Player
---@return Game.GuiText
function game.get_gui_text(mode, front_player, battle_player, config_data)
    ---@type Game.GuiText
    local gui_text = {}

    if (Settings.show_mode) then
        gui_text.mode = GameModeStrings[mode]
    end

    if (Settings.show_front_player) then
        gui_text.front_player = PlayerStrings[front_player]
    end

    if (Settings.show_battle_player) then
        gui_text.battle_player = PlayerStrings[battle_player]
    end

    return gui_text
end



return game
