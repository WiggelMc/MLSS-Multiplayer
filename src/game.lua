-- ---@class Game
-- local game = {}


-- ---@class (exact) Game.GuiText
-- ---@field mode string?
-- ---@field front_player string?
-- ---@field battle_player string?

-- ---@param mode Game.Mode
-- ---@param front_player Game.Player
-- ---@param battle_player Game.Player
-- ---@return Game.GuiText
-- function game.get_gui_text(mode, front_player, battle_player, config_data)
--     ---@type Game.GuiText
--     local gui_text = {}

--     if (Settings.show_mode) then
--         gui_text.mode = GameModeStrings[mode]
--     end

--     if (Settings.show_front_player) then
--         gui_text.front_player = PlayerStrings[front_player]
--     end

--     if (Settings.show_battle_player) then
--         gui_text.battle_player = PlayerStrings[battle_player]
--     end

--     return gui_text
-- end

-- local ConfigData
-- local updateGameData, get_other_player, get_byte_data, get_game_mode, get_front_player, get_battle_player
-- local get_input, define_inputs, get_gui_text, redraw_gui_text, main, exit

-- ---@return GameData
-- local function get_game_data()
--     local byte_data = get_byte_data()
--     local mode = get_game_mode(byte_data)
--     local front_player = get_front_player(byte_data)
--     local battle_player = get_battle_player(byte_data)
--     local inputs = input.get()
--     local gui_text = get_gui_text(mode, front_player, battle_player)
--     local screen_height = client.screenheight()

--     ---@type GameData
--     return {
--         byte_data = byte_data,
--         mode = mode,
--         front_player = front_player,
--         battle_player = battle_player,
--         inputs = inputs,
--         gui_text = gui_text,
--         screen_height = screen_height
--     }
-- end



-- ---@class (exact) ByteData
-- ---@field is_pause_screen_open boolean
-- ---@field is_dialog_open boolean
-- ---@field is_movement_disabled boolean
-- ---@field front_player_index integer

-- ---@return ByteData
-- function get_byte_data()
--     ---@type ByteData
--     return {
--         is_pause_screen_open = bit.check(memory.readbyte(0x0D5E, "IWRAM"), 0),
--         is_dialog_open = bit.check(memory.readbyte(0x03D1, "IWRAM"), 4),       -- active in battle
--         is_movement_disabled = bit.check(memory.readbyte(0x2451, "IWRAM"), 0), -- active in battle
--         front_player_index = memory.readbyte(0x241C, "IWRAM")
--         -- 0x241C M1 L2
--         -- 0x241F M1 L2
--         -- 0x2434 M2 L1
--         -- 0x2437 M2 L1
--     }
-- end

-- ---@param byte_data ByteData
-- ---@return GameMode
-- function get_game_mode(byte_data)
--     if (byte_data.is_pause_screen_open or byte_data.is_dialog_open or byte_data.is_movement_disabled) then
--         return GameMode.MENU
--     elseif ("BATTLE" == "--- TODO ---") then
--         if ("LEVEL_UP" == "--- TODO ---") then
--             return GameMode.LEVEL_UP
--         else
--             return GameMode.BATTLE
--         end
--     elseif ("MINIGAME" == "--- TODO ---") then
--         return GameMode.BATTLE
--     else
--         return GameMode.FIELD
--     end
-- end

-- ---@param byte_data ByteData
-- ---@return Player
-- function get_front_player(byte_data)
--     if (byte_data.front_player_index == 1) then
--         return player.MARIO
--     else
--         return player.LUIGI
--     end
-- end

-- ---@param byte_data ByteData
-- ---@return Player
-- function get_battle_player(byte_data)
--     if ("ACTUAL BATTLE" == "--- TODO ---") then
--         if ("MARIO'S TURN" == "--- TODO ---") then
--             return player.MARIO
--         else
--             return player.LUIGI
--         end
--     else
--         return player.MARIO
--     end
-- end

-- ---@class (exact) GameData
-- ---@field byte_data ByteData
-- ---@field mode GameMode
-- ---@field front_player Player
-- ---@field battle_player Player
-- ---@field inputs table<string, boolean>
-- ---@field gui_text GuiText
-- ---@field screen_height integer

-- ---@type GameData
-- GameData = {
--     byte_data = get_byte_data(),
--     mode = GameMode.MENU,
--     front_player = Player.MARIO,
--     battle_player = Player.MARIO,
--     inputs = {},
--     gui_text = {},
--     screen_height = 0
-- }

-- -@class (exact) InputLayout
-- -@field left string
-- -@field right string
-- -@field up string
-- -@field down string
-- -@field menu string
-- -@field menu_confirm string
-- -@field menu_cancel string
-- -@field menu_start string
-- -@field menu_L string
-- -@field menu_R string
-- -@field action_perform string
-- -@field action_cycle string
-- -@field lead_take string
-- -@field lead_give string

-- ---@class (exact) ConfigData
-- ---@field input_map table<Player,InputLayout>
-- ---@field allow_lead_take boolean
-- ---@field allow_lead_give boolean
-- ---@field log_inputs boolean
-- ---@field show_gui_rect boolean
-- ---@field show_mode boolean
-- ---@field show_front_player boolean
-- ---@field show_battle_player boolean

-- ---@param controller_name string
-- ---@param input_table InputLayout
-- ---@return InputLayout
-- function define_inputs(controller_name, input_table)
--     local assigned_input_table = {}
--     for k, v in pairs(input_table) do
--         assigned_input_table[k] = controller_name .. " " .. v
--     end
--     return assigned_input_table
-- end



-- ---@param game_data GameData
-- ---@return nil
-- function redraw_gui_text(game_data)
--     gui.use_surface("client")
--     gui.clearGraphics()
--     local top_offset = game_data.screen_height - 70
--     local left_offset = 20

--     local gui_text = game_data.gui_text

--     if (ConfigData.show_gui_rect) then
--         gui.drawBox(left_offset, top_offset + 3, left_offset + 73, top_offset + 28, "#00000000", "#AA000000")
--     end

--     if (gui_text.mode ~= nil) then
--         gui.drawString(left_offset, top_offset + 2, gui_text.mode, "#DD667777", "#00000000", 24, nil, "bold")
--     end

--     if (gui_text.front_player ~= nil) then
--         gui.drawString(left_offset + 30, top_offset + 2, gui_text.front_player, "#DD667777", "#00000000", 24, nil, "bold")
--     end

--     if (gui_text.battle_player ~= nil) then
--         gui.drawString(left_offset + 50, top_offset + 2, gui_text.battle_player, "#DD667777", "#00000000", 24, nil,
--             "bold")
--     end
-- end

-- ---@param config Config
-- ---@return nil
-- local function run_gameloop(config)
--     print(table_helper.dump(config))
--     while true do
--         emu.frameadvance()
--     end
-- local game_data = get_game_data()
-- redraw_gui_text(game_data)

-- while true do
--     local old_game_data = game_data
--     game_data = get_game_data()

--     if (ConfigData.log_inputs and (not table_helper.compare(game_data.inputs, old_game_data.inputs))) then
--         print("\nInputs:")
--         for key, _ in pairs(game_data.inputs) do
--             print(key)
--         end
--         print(">\n")
--     end

--     if (game_data.screen_height ~= old_game_data.screen_height or (not table_helper.compare(game_data.gui_text, old_game_data.gui_text))) then
--         redraw_gui_text(game_data)
--     end

--     joypad.set(get_input(game_data))
--     emu.frameadvance()
-- end
-- end


-- return game
