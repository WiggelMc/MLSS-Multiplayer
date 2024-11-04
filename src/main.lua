local config_file  = require "config.config_file"
local table_helper = require "lib.table_helper"
local input_gui    = require "game.input_gui"
local debug_window = require "game.debug_window"
local byte_data    = require "game.byte_data"
local input_map    = require "game.input_map"
local input_logic  = require "game.input_logic"

---@param config Config
---@param window? LuaCanvas
---@return nil
local function run_gameloop(config, window)
    print(table_helper.dump(config))

    while true do
        local bytes = byte_data.read_byte_data()
        if (window ~= nil) then
            debug_window.redraw(window, config.debug, bytes)
        end

        local control_state = input_logic.get_control_state(bytes)
        local display_data = input_gui.get_display_data()
        input_gui.redraw(
            control_state,
            display_data,
            config.debug
        )
        joypad.set(input_map.get_gba_input(control_state, config.gameplay, input.get()))
        emu.frameadvance()
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
