local Settings
local compareTables, copyTable, updateGameData, get_other_player, get_byte_data, get_game_mode, get_front_player, get_battle_player
local get_input, define_inputs, get_gui_text, redraw_gui_text, main, GameData, exit

---@enum GameMode
local GameMode = {
    MENU = "MODE_MENU",
    BATTLE = "MODE_BATTLE",
    LEVEL_UP = "MODE_LEVEL_UP",
    FIELD = "MODE_FIELD"
}

---@type table<GameMode, string>
local GameModeStrings = {
    [GameMode.MENU] = "M",
    [GameMode.BATTLE] = "B",
    [GameMode.LEVEL_UP] = "L",
    [GameMode.FIELD] = "F"
}

---@enum Player
local Player = {
    MARIO = "MARIO",
    LUIGI = "LUIGI"
}

---@type table<Player, string>
local PlayerStrings = {
    [Player.MARIO] = "M",
    [Player.LUIGI] = "L"
}

---@param tbl1 table
---@param tbl2 table
---@return boolean
function compareTables(tbl1, tbl2)
    if (tbl1 == tbl2) then
        return true
    elseif (tbl1 == nil or tbl2 == nil) then
        return false
    end

    local len1 = 0
    local len2 = 0
    for key, value in pairs(tbl1) do
        len1 = len1 + 1
        if (tbl2[key] ~= value) then
            return false
        end
    end
    for _, _ in pairs(tbl2) do
        len2 = len2 + 1
    end
    return len1 == len2
end

---@param tbl table
---@return table
function copyTable(tbl)
    local tbl_copy = {}
    for key, value in pairs(tbl) do
        tbl_copy[key] = value
    end
    return tbl_copy
end

---@return nil
function updateGameData()
    GameData.byte_data = get_byte_data()
    GameData.mode = get_game_mode()
    GameData.front_player = get_front_player()
    GameData.battle_player = get_battle_player()
    GameData.inputs = input.get()
    GameData.gui_text = get_gui_text()
    GameData.screen_height = client.screenheight()
end

---@param player Player
---@return Player
function get_other_player(player)
    if (player == Player.MARIO) then
        return Player.LUIGI
    else
        return Player.MARIO
    end
end

---@class (exact) ByteData
---@field is_pause_screen_open boolean
---@field is_dialog_open boolean
---@field is_movement_disabled boolean
---@field front_player_index integer

---@return ByteData
function get_byte_data()
    ---@type ByteData
    return {
        is_pause_screen_open = bit.check(memory.readbyte(0x0D5E, "IWRAM"), 0),
        is_dialog_open = bit.check(memory.readbyte(0x03D1, "IWRAM"), 4),       -- active in battle
        is_movement_disabled = bit.check(memory.readbyte(0x2451, "IWRAM"), 0), -- active in battle
        front_player_index = memory.readbyte(0x241C, "IWRAM")
        -- 0x241C M1 L2
        -- 0x241F M1 L2
        -- 0x2434 M2 L1
        -- 0x2437 M2 L1
    }
end

---@return GameMode
function get_game_mode()
    local flags = GameData.byte_data

    if (flags.is_pause_screen_open or flags.is_dialog_open or flags.is_movement_disabled) then
        return GameMode.MENU
    elseif ("BATTLE" == "--- TODO ---") then
        if ("LEVEL_UP" == "--- TODO ---") then
            return GameMode.LEVEL_UP
        else
            return GameMode.BATTLE
        end
    elseif ("MINIGAME" == "--- TODO ---") then
        return GameMode.BATTLE
    else
        return GameMode.FIELD
    end
end

---@return Player
function get_front_player()
    local flags = GameData.byte_data

    if (flags.front_player_index == 1) then
        return Player.MARIO
    else
        return Player.LUIGI
    end
end

---@return Player
function get_battle_player()
    if ("ACTUAL BATTLE" == "--- TODO ---") then
        if ("MARIO'S TURN" == "--- TODO ---") then
            return Player.MARIO
        else
            return Player.LUIGI
        end
    else
        return Player.MARIO
    end
end

---@class (exact) GameData
---@field byte_data ByteData
---@field mode GameMode
---@field front_player Player
---@field battle_player Player
---@field inputs table<string, boolean>
---@field gui_text GuiText
---@field screen_height integer

---@type GameData
local GameData = {
    byte_data = get_byte_data(),
    mode = get_game_mode(),
    front_player = get_front_player(),
    battle_player = get_battle_player(),
    inputs = {},
    gui_text = {},
    screen_height = 0
}

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

---@return GbaInput
function get_input()
    local game_mode = GameData.mode
    local joy_inputs = GameData.inputs
    local input_map = Settings.input_map

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

    local front_player = GameData.front_player
    local front_map = input_map[front_player]
    local back_player = get_other_player(front_player)
    local back_map = input_map[back_player]

    local battle_player = GameData.battle_player
    local battle_map = input_map[battle_player]

    local active_map
    if (game_mode == GameMode.MENU or game_mode == GameMode.FIELD) then
        active_map = front_map
    else
        active_map = battle_map
    end

    gba_inputs.Left = joy_inputs[active_map.left] or false
    gba_inputs.Right = joy_inputs[active_map.right] or false
    gba_inputs.Up = joy_inputs[active_map.up] or false
    gba_inputs.Down = joy_inputs[active_map.down] or false
    gba_inputs.Select = joy_inputs[active_map.menu] or false

    if (game_mode == GameMode.MENU or game_mode == GameMode.BATTLE or game_mode == GameMode.LEVEL_UP) then
        gba_inputs.L = joy_inputs[active_map.menu_L] or false
        gba_inputs.R = joy_inputs[active_map.menu_R] or false
        gba_inputs.Start = joy_inputs[active_map.menu_start] or false
    end

    if (game_mode == GameMode.MENU or game_mode == GameMode.LEVEL_UP) then
        gba_inputs.A = joy_inputs[active_map.menu_confirm] or false
        gba_inputs.B = joy_inputs[active_map.menu_cancel] or false
    elseif (game_mode == GameMode.BATTLE) then
        gba_inputs.A = joy_inputs[input_map[Player.MARIO].action_perform] or false
        gba_inputs.B = joy_inputs[input_map[Player.LUIGI].action_perform] or false
    elseif (game_mode == GameMode.FIELD) then
        gba_inputs.A = joy_inputs[front_map.action_perform] or false
        gba_inputs.B = joy_inputs[back_map.action_perform] or false
        gba_inputs.L = joy_inputs[back_map.action_cycle] or false
        gba_inputs.R = joy_inputs[front_map.action_cycle] or false
        gba_inputs.Start = (joy_inputs[front_map.lead_give] and Settings.allow_lead_give) or
            (joy_inputs[back_map.lead_take] and Settings.allow_lead_take) or false
    end

    return gba_inputs
end

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

---@class (exact) Settings
---@field input_map table<Player,InputLayout>
---@field allow_lead_take boolean
---@field allow_lead_give boolean
---@field log_inputs boolean
---@field show_gui_rect boolean
---@field show_mode boolean
---@field show_front_player boolean
---@field show_battle_player boolean

---@param controller_name string
---@param input_table InputLayout
---@return InputLayout
function define_inputs(controller_name, input_table)
    local assigned_input_table = {}
    for k, v in pairs(input_table) do
        assigned_input_table[k] = controller_name .. " " .. v
    end
    return assigned_input_table
end

---@class (exact) GuiText
---@field mode string?
---@field front_player string?
---@field battle_player string?

---@return GuiText
function get_gui_text()
    ---@type GuiText
    local gui_text = {}

    if (Settings.show_mode) then
        gui_text.mode = GameModeStrings[GameData.mode]
    end

    if (Settings.show_front_player) then
        gui_text.front_player = PlayerStrings[GameData.front_player]
    end

    if (Settings.show_battle_player) then
        gui_text.battle_player = PlayerStrings[GameData.battle_player]
    end

    return gui_text
end

---@return nil
function redraw_gui_text()
    gui.use_surface("client")
    gui.clearGraphics()
    local top_offset = GameData.screen_height - 70
    local left_offset = 20

    local gui_text = GameData.gui_text

    if (Settings.show_gui_rect) then
        gui.drawBox(left_offset, top_offset + 3, left_offset + 73, top_offset + 28, "#00000000", "#AA000000")
    end

    if (gui_text.mode ~= nil) then
        gui.drawString(left_offset, top_offset + 2, gui_text.mode, "#DD667777", "#00000000", 24, nil, "bold")
    end

    if (gui_text.front_player ~= nil) then
        gui.drawString(left_offset + 30, top_offset + 2, gui_text.front_player, "#DD667777", "#00000000", 24, nil, "bold")
    end

    if (gui_text.battle_player ~= nil) then
        gui.drawString(left_offset + 50, top_offset + 2, gui_text.battle_player, "#DD667777", "#00000000", 24, nil, "bold")
    end
end

---@param processID integer
---@return nil
function exit(processID)
    gui.use_surface("client")
    gui.clearGraphics()

    print("\nMLSS Multiplayer stopped (ID: " .. processID .. ") \n")
end

---@return nil
function main()
    math.randomseed(os.time())
    local processID = math.random(10000, 99999)
    print("\n\n\nMLSS Multiplayer started (ID: " .. processID .. ") \n")

    event.onexit(function()
        exit(processID)
    end)

    while true do
        local old_GameData = copyTable(GameData)
        updateGameData()

        if (Settings.log_inputs and (not compareTables(GameData.inputs, old_GameData.inputs))) then
            print("\nInputs:")
            for key, _ in pairs(GameData.inputs) do
                print(key)
            end
            print(">\n")
        end

        if (GameData.screen_height ~= old_GameData.screen_height or (not compareTables(GameData.gui_text, old_GameData.gui_text))) then
            redraw_gui_text()
        end

        joypad.set(get_input())
        emu.frameadvance()
    end
end




-- ##################################### --
-- #                                   # --
-- #          Configuration            # --
-- #                                   # --
-- ##################################### --




--- The Recommended Input Layout for X-Input compatible Controllers.
---@type InputLayout
local RecommendedXInputs = {
    left = "DpadLeft",
    right = "DpadRight",
    up = "DpadUp",
    down = "DpadDown",
    menu = "Back",
    menu_confirm = "A",
    menu_cancel = "X",
    menu_start = "Start",
    menu_L = "LeftShoulder",
    menu_R = "RightShoulder",
    action_perform = "A",
    action_cycle = "X",
    lead_take = "B",
    lead_give = "Y"
}

--- An alternative Input Layout for X-Input compatible Controllers,
--- which is closer to the original controls of the game.
---@type InputLayout
local ClassicXInputs = {
    left = "DpadLeft",
    right = "DpadRight",
    up = "DpadUp",
    down = "DpadDown",
    menu = "Back",
    menu_confirm = "A",
    menu_cancel = "X",
    menu_start = "Start",
    menu_L = "LeftShoulder",
    menu_R = "RightShoulder",
    action_perform = "A",
    action_cycle = "RightShoulder",
    lead_take = "Start",
    lead_give = "Start"
}

--- The Recommended Input Layout for the Mayflash N64 Controller Adapter for PC.
---@type InputLayout
local RecommendedN64Inputs = {
    left = "POV1L",          -- Dpad Left
    right = "POV1R",         -- Dpad Right
    up = "POV1U",            -- Dpad Up
    down = "POV1D",          -- Dpad Down
    menu = "B9",             -- Start
    menu_confirm = "B2",     -- A
    menu_cancel = "B3",      -- B
    menu_start = "Z-",       -- C Up
    menu_L = "B7",           -- L
    menu_R = "B8",           -- R
    action_perform = "B2",   -- A
    action_cycle = "B3",     -- B
    lead_take = "Z+",        -- C Down
    lead_give = "RotationZ+" -- C Left
}

--- An alternative Input Layout for the Mayflash N64 Controller Adapter for PC,
--- which is closer to the original controls of the game.
---@type InputLayout
local ClassicN64Inputs = {
    left = "POV1L",        -- Dpad Left
    right = "POV1R",       -- Dpad Right
    up = "POV1U",          -- Dpad Up
    down = "POV1D",        -- Dpad Down
    menu = "Z-",           -- C Up
    menu_confirm = "B2",   -- A
    menu_cancel = "B3",    -- B
    menu_start = "B9",     -- Start
    menu_L = "B7",         -- L
    menu_R = "B8",         -- R
    action_perform = "B2", -- A
    action_cycle = "B8",   -- R
    lead_take = "B9",      -- Start
    lead_give = "B9"       -- Start
}

--- An Example Layout listing the Controls.
---@type InputLayout
local ExampleInputs = {
    -- Directional Inputs (Dpad) (only for the Front Player or the current Player in Battle).
    left = "None",
    right = "None",
    up = "None",
    down = "None",

    -- Open the Menu (Select).
    menu = "None",

    -- Confirm (A) Button inside of Menus (this includes Dialog Boxes).
    menu_confirm = "None",

    -- Cancel (B) Button inside of Menus (this includes Dialog Boxes).
    menu_cancel = "None",

    -- More info (Start) inside of Menus (used mainly to see Controls in Minigames).
    menu_start = "None",

    -- Scroll Left (L) inside of Menus (this includes the difficulty selection in Battle).
    menu_L = "None",

    -- Scroll Right (R) inside of Menus (this includes the difficulty selection in Battle).
    menu_R = "None",

    -- Perform the current Action in the Overworld (A / B) (Also used as the Attack and Confirm button in Battle).
    action_perform = "None",

    -- Cycle through the available Actions in the Overworld (R / L).
    action_cycle = "None",

    -- Swap with the Front Player, if you are in the back (Start) (can be disabled in Settings).
    lead_take = "None",

    -- Swap with the Rear Player, if you are in the Front (Start) (can be disabled in Settings).
    lead_give = "None"
}

--- Configure the Settings for the Script.
--- Most Settings can be either `true` or `false`, if you want to change them, replace the existing value (eg. replace `false` with `true` or vice versa).
---@type Settings
Settings = {
    -- Configure Controls for either Player.
    --
    -- They are defined in the format `define_inputs(device_name, layout)`.
    --
    -- Layouts are defined above, you can modify those or define your own by copying an existing one and renaming it.
    -- If you need multiple devices for a single Player, assign the Layout directly (eg. `[Player.MARIO] = YourInputs`)
    -- and prepend the Inputs manually with the Device Name (eg. `left = "X1 DpadLeft"`).
    --
    -- If you need to find the Device Name or names for Buttons on your Controller, refer to the `log_inputs` Setting.
    input_map = {
        [Player.MARIO] = define_inputs("X1", RecommendedXInputs),
        [Player.LUIGI] = define_inputs("J2", RecommendedN64Inputs)
    },

    -- Allow the Rear Player to Swap.
    allow_lead_take = true,

    -- Allow the Front Player to Swap.
    allow_lead_give = true,

    -- Log all Buttons from Input Devices to the Console (useful for input configuration).
    -- They are displayed in the format `DeviceName InputName` (eg. `X1 DpadLeft` for the Button `DpadLeft` on Controller `X1`).
    log_inputs = false,

    -- Show rectangle around GUI Display.
    show_gui_rect = true,

    -- Show current Mode in GUI Display (on the left).
    show_mode = true,

    -- Show current Front Player in GUI Display (in the middle).
    show_front_player = true,

    -- Show current Player in Battle in GUI Display (on the right).
    show_battle_player = true
}

main()
