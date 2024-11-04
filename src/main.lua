local config_file  = require "config.config_file"
local table_helper = require "lib.table_helper"
local input_gui    = require "game.input_gui"
local debug_window = require "game.debug_window"
local byte_data    = require "game.byte_data"
local input_map    = require "game.input_map"
local input_logic  = require "game.input_logic"

---@class (exact) GameData
---@field byte_data ByteData
---@field control_state ControlState
---@field display_data DisplayData
---@field input_data table<string, boolean>


---@return GameData
local function get_game_data()
    local bytes = byte_data.read_byte_data()
    ---@type GameData
    return {
        byte_data = bytes,
        control_state = input_logic.get_control_state(bytes),
        display_data = input_gui.get_display_data(),
        input_data = input.get()
    }
end

---@param config Config
---@param window? LuaCanvas
---@return nil
local function run_gameloop(config, window)
    if (config.debug.log_config) then
        print("\nConfig:\n")
        print(table_helper.dump(config, 2, 1))
        print("")
    end

    ---@type ({} | GameData)
    local old_game_data = {}
    local game_data = get_game_data()

    while true do
        if (window ~= nil and not table_helper.compare(old_game_data.byte_data, game_data.byte_data)) then
            debug_window.redraw(window, config.debug, game_data.byte_data)
        end

        if (not table_helper.compare(old_game_data.control_state, game_data.control_state)
                or not table_helper.compare(old_game_data.display_data, game_data.display_data)) then
            input_gui.redraw(
                game_data.control_state,
                game_data.display_data,
                config.debug
            )
        end

        if (config.debug.log_inputs and not table_helper.compare(old_game_data.input_data, game_data.input_data)) then
            print("\nInputs:")
            for key, _ in pairs(game_data.input_data) do
                print("  " .. key)
            end
            print(">\n")
        end

        joypad.set(input_map.get_gba_input(game_data.control_state, config.gameplay, game_data.input_data))
        emu.frameadvance()

        old_game_data = game_data
        game_data = get_game_data()
    end
end

---@param process_id integer
---@param window? LuaCanvas
---@return nil
local function exit(process_id, window)
    input_gui.clear()
    if (window ~= nil) then
        debug_window.close(window)
    end

    print("|>\n|>> MLSS Multiplayer stopped (ID: " .. process_id .. ")\n\n\n")
end

---@return nil
local function main()
    math.randomseed(os.time())
    local process_id = math.random(10000, 99999)
    print("\n\n\n|>> MLSS Multiplayer started (ID: " .. process_id .. ")\n|>")

    ---@type LuaCanvas?
    local window = nil

    event.onexit(function()
        exit(process_id, window)
    end)

    if (config_file.exists()) then
        local config, errors = config_file.load()
        if (config ~= nil) then
            if (config.debug.open_debug_window) then
                window = debug_window.open()
            end
            run_gameloop(config, window)
        else
            errors = errors or {}
            print("\n\n" .. #errors .. " Errors loading Config File:\n\n")
            for _, error in ipairs(errors) do
                print(error)
                print("")
            end
            print("")
        end
    else
        config_file.generate_preset()
        print("\nThe Config File was generated (" .. config_file.file_name .. ").\n")
        print("It can be found in the same Directory as the Script.")
        print("Reload the Script to start playing.\n")
    end
end

main()
