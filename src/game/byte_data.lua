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
---@field front_player_index integer # Front Player in the Overworld (1: Mario / 2: Luigi)

---@return ByteData
function byte_data.read_byte_data()
    local check = bit.check

    ---@type ByteData
    return {
        is_pause_screen_open = read_bit(0x0D5E, 0),
        is_dialog_open = read_bit(0x03D1, 4),
        is_movement_disabled = read_bit(0x2451, 0),
        front_player_index = read_byte(0x241C),
        battle_turn_player_1 = read_byte(0x7B47),
        battle_turn_player_2 = read_byte(0x7B74),
        battle_turn_player_3 = read_byte(0x0389),
        battle_turn_player_4 = read_byte(0x7B4E),
        battle_turn_player_5 = read_byte(0x037B),
        battle_turn_player_6 = read_byte(0x7B05),
    }
end

return byte_data
