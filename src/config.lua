---@class ConfigClass
local config = {}

---@class (exact) Config
---@field input_map table<Player,InputLayout>
---@field allow_lead_take boolean
---@field allow_lead_give boolean
---@field log_inputs boolean
---@field show_gui_rect boolean
---@field show_mode boolean
---@field show_front_player boolean
---@field show_battle_player boolean

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

return config
