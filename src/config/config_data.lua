local config_preset = require "config.config_preset"
local table_helper  = require "table_helper"
local player        = require "game.player"
local config_file   = require "config_file"

---@class ConfigDataClass
local config_data   = {}


---@class (exact) Config
---@field gameplay GameplayConfig
---@field debug DebugConfig

---@class (exact) GameplayConfig
---@field input_layouts table<Player,InputLayout>
---@field allow_lead_take boolean
---@field allow_lead_give boolean
---@field require_coop_swap boolean

---@class (exact) DebugConfig
---@field log_inputs boolean
---@field log_config boolean
---@field show_hud boolean
---@field hud_scale number
---@field hud_position HudPosition
---@field open_debug_window boolean
---@field debug_window_scale number


---@class (exact) InputLayout
---@field left string
---@field right string
---@field up string
---@field down string
---@field menu string
---@field menu_confirm string
---@field menu_cancel string
---@field menu_start string
---@field menu_L string
---@field menu_R string
---@field action_perform string
---@field action_cycle string
---@field lead_take string
---@field lead_give string


---@class InputLayoutTypes : InputLayout
---@field device string

---@type InputLayoutTypes
local input_config_types = {
    device = "string",
    left = "string",
    right = "string",
    up = "string",
    down = "string",
    menu = "string",
    menu_confirm = "string",
    menu_cancel = "string",
    menu_start = "string",
    menu_L = "string",
    menu_R = "string",
    action_perform = "string",
    action_cycle = "string",
    lead_take = "string",
    lead_give = "string"
}

---@alias HudPosition
---| "top_left"
---| "top_right"
---| "bottom_left"
---| "bottom_right"

local config_types = {
    ["Gameplay"] = {
        allow_lead_take = "boolean",
        allow_lead_give = "boolean",
        require_coop_swap = "boolean"
    },
    ["Debug"] = {
        log_inputs = "boolean",
        log_config = "boolean",
        show_hud = "boolean",
        hud_scale = "number",
        ---@type HudPosition[]
        hud_position = { "top_left", "top_right", "bottom_left", "bottom_right" },
        open_debug_window = "boolean",
        debug_window_scale = "number"
    },
    ["Mario"] = input_config_types,
    ["Luigi"] = input_config_types
}

config_data.file_name = "mlss_multiplayer.ini"

---@return boolean
function config_data.exists()
    return config_file.exists(config_data.file_name)
end

---@return nil
function config_data.generate_preset()
    return config_file.generate_preset(config_data.file_name, config_preset.text)
end

---@return table
local function init_config()
    return {
        gameplay = {
            input_layouts = {
                [player.MARIO] = {},
                [player.LUIGI] = {}
            }
        },
        debug = {}
    }
end

---@param config table
---@param section string
---@param key string
---@param value any
---@return nil
local function set_config_value(config, section, key, value)
    if (section == "Gameplay") then
        config["gameplay"][key] = value
    elseif (section == "Debug") then
        config["debug"][key] = value
    elseif (section == "Mario") then
        config["gameplay"]["input_layouts"][player.MARIO][key] = value
    elseif (section == "Luigi") then
        config["gameplay"]["input_layouts"][player.LUIGI][key] = value
    end
end

---@param config table
---@return Config
local function fix_config(config)
    local layouts = config["gameplay"]["input_layouts"]
    for _, layout in pairs(layouts) do
        local device = layout.device
        layout.device = nil
        if (device ~= "") then
            for key, value in pairs(layout) do
                layout[key] = device .. " " .. value
            end
        end
    end
    return config --[[@as Config]]
end

---@return Config?, string[]?
function config_data.load()
    local config_type_table = table_helper.deepcopy(config_types)
    local config = init_config()

    local function set_value(section, key, value)
        set_config_value(config, section, key, value)
    end

    local errors = config_file.read(config_data.file_name, config_type_table, {}, set_value)

    if (errors == nil) then
        return fix_config(config), nil
    else
        return nil, errors
    end
end

return config_data
