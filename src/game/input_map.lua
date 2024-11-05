---@diagnostic disable: name-style-check
local player = require "game.player"
local logic_helper = require "lib.logic_helper"

---@class InputMapClass
local input_map = {}


---@class (exact) ControlState
---@field primary Player
---@field a_player ("Mario" | "Primary")
---@field menu_button_control ("Primary" | "Split")
---@field face_button_control ("Primary" | "Split")

---@class (exact) GbaInput
---@field Left boolean
---@field Right boolean
---@field Up boolean
---@field Down boolean
---@field A boolean
---@field B boolean
---@field L boolean
---@field R boolean
---@field Start boolean
---@field Select boolean
---@field Power boolean

---@param control_state ControlState
---@param gameplay_config GameplayConfig
---@param joy_inputs table<string, boolean?>
---@return GbaInput
function input_map.get_gba_input(control_state, gameplay_config, joy_inputs)
    ---@type GbaInput
    local gba_inputs = {
        Left = false,
        Right = false,
        Up = false,
        Down = false,
        A = false,
        B = false,
        L = false,
        R = false,
        Start = false,
        Select = false,
        Power = false
    }

    local primary_map = gameplay_config.input_layouts[control_state.primary]

    ---@type Player
    local a_player = logic_helper.ternary(
        control_state.a_player == "Mario",
        player.MARIO,
        control_state.primary
    )
    local a_player_map = gameplay_config.input_layouts[a_player]
    local b_player_map = gameplay_config.input_layouts[player.get_other(a_player)]


    gba_inputs.Left = joy_inputs[primary_map.left] or false
    gba_inputs.Right = joy_inputs[primary_map.right] or false
    gba_inputs.Up = joy_inputs[primary_map.up] or false
    gba_inputs.Down = joy_inputs[primary_map.down] or false
    gba_inputs.Select = joy_inputs[primary_map.menu] or false

    if (control_state.face_button_control == "Primary") then
        gba_inputs.A = joy_inputs[primary_map.menu_confirm] or false
        gba_inputs.B = joy_inputs[primary_map.menu_cancel] or false
    else -- "Split"
        gba_inputs.A = joy_inputs[a_player_map.action_perform] or false
        gba_inputs.B = joy_inputs[b_player_map.action_perform] or false
    end

    if (control_state.menu_button_control == "Primary") then
        gba_inputs.L = joy_inputs[primary_map.menu_L] or false
        gba_inputs.R = joy_inputs[primary_map.menu_R] or false
        gba_inputs.Start = joy_inputs[primary_map.menu_start] or false
    else -- "Split"
        gba_inputs.L = joy_inputs[b_player_map.action_cycle] or false
        gba_inputs.R = joy_inputs[a_player_map.action_cycle] or false
        if (gameplay_config.require_coop_swap) then
            gba_inputs.Start = (joy_inputs[a_player_map.lead_give] and joy_inputs[b_player_map.lead_take])
                or false
        else
            gba_inputs.Start = (joy_inputs[a_player_map.lead_give] and gameplay_config.allow_lead_give)
                or (joy_inputs[b_player_map.lead_take] and gameplay_config.allow_lead_take)
                or false
        end
    end

    return gba_inputs
end

return input_map
