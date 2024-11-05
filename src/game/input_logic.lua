local player = require "game.player"

---@class InputLogicClass
local input_logic = {}


---@param data ByteData
---@return ControlState
function input_logic.get_control_state(data)
    ---@type ControlState
    local state = {
        primary = "MARIO",
        a_player = "Primary",
        face_button_control = "Primary",
        menu_button_control = "Primary"
    }

    if (data.front_player_index == 1) then
        state.primary = player.MARIO
    else
        state.primary = player.LUIGI
    end

    if (data.is_pause_screen_open or data.is_dialog_open or data.is_movement_disabled) then
        state.face_button_control = "Primary"
        state.menu_button_control = "Primary"
        state.a_player = "Primary"
    else
        state.face_button_control = "Split"
        state.menu_button_control = "Split"
        state.a_player = "Primary"
    end

    return state
end

return input_logic
