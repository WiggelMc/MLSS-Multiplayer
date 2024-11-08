local table_helper = require "table_helper"

---@class ByteDataClass
local byte_data = {}


---@param addr integer
---@return integer
local function read_iw_byte(addr)
    return memory.readbyte(addr, "IWRAM")
end

---@param addr integer
---@return integer
local function read_ew_byte(addr)
    return memory.readbyte(addr, "EWRAM")
end

---@param addr integer
---@param pos integer
---@return boolean
local function read_iw_bit(addr, pos)
    return bit.check(read_iw_byte(addr), pos)
end

---@class (exact) ByteData
---@field is_pause_screen_open boolean # True if the Pause Screen is open (Select)
---@field is_dialog_open boolean # True if a Dialog Box is Open (Textbox, Battle)
---@field is_movement_disabled boolean # True if you cannot move with the Dpad
---@field front_player_index integer # Front Player in the Overworld (0x01: Mario / 0x02: Luigi)
---@field battle_turn_player integer # Active Player in Battle (0x98: Mario / 0x99: Luigi // other: Enemy) (maybe only last ?? bits should be read???)

---@return ByteData
function byte_data.read_byte_data()
    local check = bit.check

    ---@type ByteData
    return {
        is_pause_screen_open = read_iw_bit(0x0D5E, 0),
        is_dialog_open = read_iw_bit(0x03D1, 4),
        is_movement_disabled = read_iw_bit(0x2451, 0),
        front_player_index = read_iw_byte(0x241C),
        battle_turn_player = read_iw_byte(0x3FC9),
        data_misc_1 = read_iw_byte(0x0BE9),
        data_misc_2 = read_iw_byte(0x0C24),
        data_misc_3 = read_iw_byte(0x0D62),
        data_misc_4 = read_iw_byte(0x0D6A),
        data_misc_5 = read_iw_byte(0x4176),
        data_misc_6 = read_iw_byte(0x428B),
        data_misc_7 = read_iw_byte(0x4616),
    }
end

return byte_data
