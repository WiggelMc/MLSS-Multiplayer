local table_helper = require "table_helper"

---@class ByteDataClass
local byte_data = {}


---@param addr integer
---@return integer
local function read_byte(addr)
    return memory.readbyte(addr, "IWRAM")
end

---@param addr integer
---@param pos integer
---@return boolean
local function read_bit(addr, pos)
    return bit.check(read_byte(addr), pos)
end

---@class (exact) ByteData
---@field is_pause_screen_open boolean # True if the Pause Screen is open (Select)
---@field is_dialog_open boolean # True if a Dialog Box is Open (Textbox, Battle)
---@field is_movement_disabled boolean # True if you cannot move with the Dpad
---@field front_player_index integer # Front Player in the Overworld (0x01: Mario / 0x02: Luigi)
---@field battle_turn_player integer # Active Player in Battle (0x98: Mario / 0x99: Luigi // other: Enemy)

---@return ByteData
function byte_data.read_byte_data()
    local check = bit.check

    ---@type ByteData
    return {
        is_pause_screen_open = read_bit(0x0D5E, 0),
        is_dialog_open = read_bit(0x03D1, 4),
        is_movement_disabled = read_bit(0x2451, 0),
        front_player_index = read_byte(0x241C),
        battle_turn_player = read_byte(0x3FC9),
        data_misc_1 = read_byte(0x7C4D),
        data_misc_2 = read_byte(0x7B59),
        data_misc_3 = read_byte(0x7B4E),
        data_misc_4 = read_byte(0x037B),
        data_misc_5 = read_byte(0x7B05),
    }
end

return byte_data
