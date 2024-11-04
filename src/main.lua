local config_file  = require "config.config_file"
local table_helper = require "lib.table_helper"
local input_gui    = require "game.input_gui"
local debug_window = require "game.debug_window"
local byte_data    = require "game.byte_data"

---@param config Config
---@param debug_window_obj? LuaCanvas
---@return nil
local function run_gameloop(config, debug_window_obj)
    print(table_helper.dump(config))

    while true do
        if (debug_window_obj ~= nil) then
            debug_window.redraw(debug_window_obj, config.debug, byte_data.read_byte_data())
        end
        input_gui.redraw(
            {
                primary = "MARIO",
                a_player = "Mario",
                face_button_control = "Split",
                menu_button_control = "Primary"
            },
            input_gui.get_display_data(),
            config.debug
        )
        emu.frameadvance()
    end
    --TODO: This should be in another File
end

---@param process_id integer
---@param debug_window_obj? LuaCanvas
---@return nil
local function exit(process_id, debug_window_obj)
    input_gui.clear()
    if (debug_window_obj ~= nil) then
        debug_window.close(debug_window_obj)
    end

    print("|>\n|>> MLSS Multiplayer stopped (ID: " .. process_id .. ")\n\n\n")
end

---@return nil
local function main()
    math.randomseed(os.time())
    local process_id = math.random(10000, 99999)
    print("\n\n\n|>> MLSS Multiplayer started (ID: " .. process_id .. ")\n|>")

    ---@type LuaCanvas?
    local debug_window_obj = nil

    event.onexit(function()
        exit(process_id, debug_window_obj)
    end)

    if (config_file.exists()) then
        local config, errors = config_file.load()
        if (config ~= nil) then
            if (config.debug.open_debug_window) then
                debug_window_obj = debug_window.open()
            end
            run_gameloop(config, debug_window_obj)
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
