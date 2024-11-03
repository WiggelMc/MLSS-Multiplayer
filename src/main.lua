local config_file = require "config.config_file"
local table_helper = require "lib.table_helper"

---@param config Config
---@return nil
local function run_gameloop(config)
    print(table_helper.dump(config))
    while true do
        emu.frameadvance()
    end
    --TODO: This should be in another File
end

---@param process_id integer
---@return nil
local function exit(process_id)
    gui.use_surface("client")
    gui.clearGraphics()

    print("|>\n|>> MLSS Multiplayer stopped (ID: " .. process_id .. ")\n\n\n")
end

---@return nil
local function main()
    math.randomseed(os.time())
    local process_id = math.random(10000, 99999)
    print("\n\n\n|>> MLSS Multiplayer started (ID: " .. process_id .. ")\n|>")

    event.onexit(function()
        exit(process_id)
    end)

    if (config_file.exists()) then
        local config, errors = config_file.load()
        if (config ~= nil) then
            run_gameloop(config)
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
