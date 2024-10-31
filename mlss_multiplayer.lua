local Settings

math.randomseed(os.time())
local ProcessID = math.random(10000, 99999)

local GameMode = {
    MENU = "MODE_MENU",
    BATTLE = "MODE_BATTLE",
    LEVEL_UP = "MODE_LEVEL_UP",
    FIELD = "MODE_FIELD"
}

local GameModeStrings = {
    [GameMode.MENU] = "M",
    [GameMode.BATTLE] = "B",
    [GameMode.LEVEL_UP] = "L",
    [GameMode.FIELD] = "F"
}

local Player = {
    MARIO = "MARIO",
    LUIGI = "LUIGI"
}

local PlayerStrings = {
    [Player.MARIO] = "M",
    [Player.LUIGI] = "L"
}

local GameData = {
    mode = nil,
    front_player = nil,
    battle_player = nil,
    inputs = {},
    gui_text = {},
    screen_height = nil
}

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

function copyTable(tbl)
    local tbl_copy = {}
    for key, value in pairs(tbl) do
        tbl_copy[key] = value
    end
    return tbl_copy
end

function updateGameData()
    GameData.mode = get_game_mode()
    GameData.front_player = get_front_player()
    GameData.battle_player = get_battle_player()
    GameData.inputs = input.get()
    GameData.gui_text = get_gui_text()
    GameData.screen_height = client.screenheight()
end

function get_other_player(player)
    if (player == Player.MARIO) then
        return Player.LUIGI
    else
        return Player.MARIO
    end
end

function get_game_mode()
    local game_paused_flag = bit.check(memory.readbyte(0x0D5E, "IWRAM"), 0)
    local textbox_flag = bit.check(memory.readbyte(0x03D1, "IWRAM"), 4)  --ALSO BATTLE
    local cutscene_flag = bit.check(memory.readbyte(0x2451, "IWRAM"), 0) --ALSO BATTLE

    if (game_paused_flag or textbox_flag or cutscene_flag) then
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

function get_front_player()
    local front_player_num = memory.readbyte(0x241C, "IWRAM")
    -- 0x241C M1 L2
    -- 0x241F M1 L2
    -- 0x2434 M2 L1
    -- 0x2437 M2 L1

    if (front_player_num == 1) then
        return Player.MARIO
    else
        return Player.LUIGI
    end
end

function get_battle_player()
    if ("MINIGAME" == "--- TODO ---") then
        return Player.MARIO
    else
        return Player.MARIO --TODO: Return current turn
    end
end

function get_input()
    local game_mode = GameData.mode
    local joy_inputs = GameData.inputs
    local input_map = Settings.input_map

    local gba_inputs = {
        ["Left"] = false,
        ["Right"] = false,
        ["Up"] = false,
        ["Down"] = false,
        ["A"] = false,
        ["B"] = false,
        ["L"] = false,
        ["R"] = false,
        ["Start"] = false,
        ["Select"] = false,
        ["Power"] = false
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

    gba_inputs["Left"] = joy_inputs[active_map.left] or false
    gba_inputs["Right"] = joy_inputs[active_map.right] or false
    gba_inputs["Up"] = joy_inputs[active_map.up] or false
    gba_inputs["Down"] = joy_inputs[active_map.down] or false
    gba_inputs["Select"] = joy_inputs[active_map.menu] or false

    if (game_mode == GameMode.MENU or game_mode == GameMode.BATTLE or game_mode == GameMode.LEVEL_UP) then
        gba_inputs["L"] = joy_inputs[active_map.menu_L] or false
        gba_inputs["R"] = joy_inputs[active_map.menu_R] or false
        gba_inputs["Start"] = joy_inputs[active_map.menu_start] or false
    end

    if (game_mode == GameMode.MENU or game_mode == GameMode.LEVEL_UP) then
        gba_inputs["A"] = joy_inputs[active_map.menu_confirm] or false
        gba_inputs["B"] = joy_inputs[active_map.menu_cancel] or false
    elseif (game_mode == GameMode.BATTLE) then
        gba_inputs["A"] = joy_inputs[input_map[Player.MARIO].action_perform] or false
        gba_inputs["B"] = joy_inputs[input_map[Player.LUIGI].action_perform] or false
    elseif (game_mode == GameMode.FIELD) then
        gba_inputs["A"] = joy_inputs[front_map.action_perform] or false
        gba_inputs["B"] = joy_inputs[back_map.action_perform] or false
        gba_inputs["L"] = joy_inputs[back_map.action_cycle] or false
        gba_inputs["R"] = joy_inputs[front_map.action_cycle] or false
        gba_inputs["Start"] = (joy_inputs[front_map.lead_give] and Settings.allow_lead_give) or
        (joy_inputs[back_map.lead_take] and Settings.allow_lead_take) or false
    end

    return gba_inputs
end

function define_inputs(controller_name, input_table)
    local assigned_input_table = {}
    for k, v in pairs(input_table) do
        assigned_input_table[k] = controller_name .. " " .. v
    end
    return assigned_input_table
end

function get_gui_text()
    local gui_text = {}

    if (Settings.show_mode) then
        gui_text["mode"] = GameModeStrings[GameData.mode]
    end

    if (Settings.show_front_player) then
        gui_text["front_player"] = PlayerStrings[GameData.front_player]
    end

    if (Settings.show_battle_player) then
        gui_text["battle_player"] = PlayerStrings[GameData.battle_player]
    end

    return gui_text
end

function redraw_gui_text()
    gui.use_surface("client")
    gui.clearGraphics()
    local top_offset = GameData.screen_height - 70
    local left_offset = 20

    local gui_text = GameData.gui_text
    local mode_text = gui_text["mode"]
    local front_player_text = gui_text["front_player"]
    local battle_player_text = gui_text["battle_player"]

    if (Settings.show_gui_rect) then
        gui.drawBox(left_offset, top_offset + 3, left_offset + 73, top_offset + 28, 0, "#AA000000")
    end

    if (mode_text ~= nil) then
        gui.drawString(left_offset, top_offset + 2, mode_text, "#DD667777", 0, 24, nil, "bold")
    end

    if (front_player_text ~= nil) then
        gui.drawString(left_offset + 30, top_offset + 2, front_player_text, "#DD667777", 0, 24, nil, "bold")
    end

    if (battle_player_text ~= nil) then
        gui.drawString(left_offset + 50, top_offset + 2, battle_player_text, "#DD667777", 0, 24, nil, "bold")
    end
end

function start_multiplayer()
    print("\n\n\nMLSS Multiplayer started (ID: " .. ProcessID .. ") \n")
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

event.onexit(function()
    gui.use_surface("client")
    gui.clearGraphics()

    print("\nMLSS Multiplayer stopped (ID: " .. ProcessID .. ") \n")
end)

-- ##################################### --
-- #                                   # --
-- #          Configuration            # --
-- #                                   # --
-- ##################################### --

local DefaultXInputs = {
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

local N64Inputs = {
    left = "POV1L",
    right = "POV1R",
    up = "POV1U",
    down = "POV1D",
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

Settings = {
    input_map = {
        [Player.MARIO] = define_inputs("X1", DefaultXInputs),
        [Player.LUIGI] = define_inputs("J2", N64Inputs)
    },
    allow_lead_take = true,
    allow_lead_give = true,
    log_inputs = false,
    show_gui_rect = true,
    show_mode = true,
    show_front_player = true,
    show_battle_player = true
}

start_multiplayer()
