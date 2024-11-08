local config_file = require "config_file"


local config_file_name = "ram_export.ini"

local config_preset_text = [[
; Format: bucket_name = input
[Buckets]

1 = Keypad1
2 = Keypad2
]]

---@param bucket_name string
---@return nil
local function export_ram(bucket_name)
    bucket_name = string.gsub(bucket_name, "%.", "")

    local id = math.random(100, 999)
    local timestamp = os.date("%Y_%m_%d_t%H_%M_%S", os.time())
    local filename = "../data/generated/" .. bucket_name .. "/ram_" .. timestamp .. "_i" .. id

    local iwram_bytes = memory.read_bytes_as_array(0x0000, 0x7FFF, "IWRAM")
    local ewram_bytes = memory.read_bytes_as_array(0x0000, 0x03FFFF, "EWRAM")

    client.screenshot(filename .. ".png")
    savestate.save(filename .. ".State", true)
    local iwram_file = io.open(filename .. ".iw.bin", "wb")
    local ewram_file = io.open(filename .. ".ew.bin", "wb")

    if (iwram_file == nil or ewram_file == nil) then
        print("Error: File could not be created (" .. filename .. ")")
        gui.addmessage("ERROR: [" .. bucket_name .. "] File could not be created: " .. bucket_name)
        return
    end

    iwram_file:write(string.char(table.unpack(iwram_bytes)))
    ewram_file:write(string.char(table.unpack(ewram_bytes)))
    gui.addmessage("[" .. bucket_name .. "] Saved File in /" .. bucket_name .. "/")

    iwram_file:flush()
    iwram_file:close()
    ewram_file:flush()
    ewram_file:close()
end

---@return nil
local function main()
    math.randomseed(os.time())

    ---@type table<string, string>
    local config = {}

    if (config_file.exists(config_file_name)) then
        local function set_config_value(section, key, value)
            config[value] = key
        end
        config_file.read(config_file_name, {}, { "Buckets" }, set_config_value)
    else
        config_file.generate_preset(config_file_name, config_preset_text)
        print("Config File generated")
        return
    end

    print("Ram Export started")
    event.onexit(function()
        print("Ram Export stopped")
    end)

    local function get_bucket_inputs()
        local bucket_inputs = {}
        for key, _ in pairs(input.get()) do
            local bucket_name = config[key]
            if (bucket_name ~= nil) then
                bucket_inputs[bucket_name] = true
            end
        end
        return bucket_inputs
    end

    local old_inputs = {}
    local inputs = get_bucket_inputs()

    while true do
        for bucket_name, _ in pairs(inputs) do
            if (not old_inputs[bucket_name]) then
                export_ram(bucket_name)
            end
        end

        emu.frameadvance()

        old_inputs = inputs
        inputs = get_bucket_inputs()
    end
end

main()
