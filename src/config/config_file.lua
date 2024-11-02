local config_preset = require "config.config_preset"
---@class ConfigFileClass
local config_file = {}

---@class (exact) Config
---@field gameplay GameplayConfig
---@field debug DebugConfig

---@class (exact) GameplayConfig
---@field input_layouts table<Player,InputLayout>
---@field allow_lead_take boolean
---@field allow_lead_give boolean

---@class (exact) DebugConfig
---@field log_inputs boolean
---@field show_gui_rect boolean
---@field show_mode boolean
---@field show_front_player boolean
---@field show_battle_player boolean


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

config_file.file_name = "mlss_multiplayer.ini"

---@return boolean
function config_file.exists()
    local file = io.open(config_file.file_name, "r")
    if (file ~= nil) then
        file:close()
        return true
    else
        return false
    end
end

---@return nil
function config_file.generate_preset()
    if config_file.exists() then
        error("Config File already exists")
    end
    local file = io.open(config_file.file_name, "w")
    if file == nil then
        error("File could not be opened")
    end

    file:write(config_preset.text)
    file:flush()
    file:close()
end

---@param str string
---@return string
local function trim_front(str)
    local result = string.gsub(str, "^%s+(.-)$", "%1")
    return result
end

---@param str string
---@return string
local function trim(str)
    local result = string.gsub(str, "^%s+(.-)%s+$", "%1")
    return result
end


---@param str string
---@return string, string
local function take_head(str)
    return string.sub(str, 1, 1), string.sub(str, 2)
end


---@param line string
---@param f fun(head: string, tail: string): boolean
---@param buffer? string
---@return string, string?
local function capture_until(line, f, buffer)
    local buffer = buffer or ""
    local head, tail = take_head(line)

    if (f(head, tail)) then
        return buffer, line
    elseif (head == "" or head == ";") then
        return buffer, nil
    elseif (head == "\\") then
        local head2, tail2 = take_head(tail)
        return capture_until(tail2, f, buffer .. head .. head2)
    else
        return capture_until(tail, f, buffer .. head)
    end
end

---@param str string
---@param buffer string?
---@return string
local function unescape(str, buffer)
    buffer = buffer or ""
    local head, tail = take_head(str)
    if (head == "") then
        return buffer
    elseif (head == "\\") then
        local head2, tail2 = take_head(tail)
        if (head2 == "s") then
            return unescape(tail2, buffer .. " ")
        elseif (head2 == "t") then
            return unescape(tail2, buffer .. "\t")
        else
            return unescape(tail2, buffer .. head2)
        end
    else
        return unescape(tail, buffer .. head)
    end
end

---@alias ParseResult
---| {type: "Error"} 
---| {type: "Empty"} 
---| {type: "Section", name: string} 
---| {type: "Value", key: string, value: string})

---@param line string
---@return ParseResult
local function parse(line)
    local trimmed_line = trim_front(line)
    local head, tail = take_head(trimmed_line)

    if (head == ";") then
        ---@type ParseResult
        return { type = "Empty" }
    elseif (head == "[") then
        local section_name, line1 = capture_until(tail, function(char)
            return char == "]" or char == "[" or char == "="
        end)

        if (line1 == nil) then
            ---@type ParseResult
            return { type = "Error" }
        end

        local head2, line2 = take_head(line1)

        if (head2 ~= "]") then
            ---@type ParseResult
            return { type = "Error" }
        end

        local trimmed_line2 = trim_front(line2)

        local next_char, _ = take_head(trimmed_line2)
        if (next_char == "\n" or next_char == "\r" or next_char == ";" or next_char == "") then
            ---@type ParseResult
            return { type = "Section", name = unescape(trim(section_name)) }
        else
            ---@type ParseResult
            return { type = "Error" }
        end
    else
        local key, line1 = capture_until(tail, function(char)
            return char == "="
        end)
        
        if (line1 == nil) then
            ---@type ParseResult
            return { type = "Error" }
        end

        local _, line2 = take_head(line1)
        local value, rest = capture_until(line2, function(char)
            return char == "=" or char == "[" or char == "]"
        end)

        if (rest ~= nil) then
            ---@type ParseResult
            return { type = "Error" }
        end

        ---@type ParseResult
        return {
            type = "Value",
            key = unescape(trim(key)),
            value = unescape(trim(value))
        }
    end
end


---@return Config?, string[]?
function config_file.load()
    local file = io.open(config_file.file_name, "r")

    if (file == nil) then
        error("Config File does not exist")
    end

    local config = {}
    local errors = {}
    local line_num = 1
    ---@type string?
    local current_section = nil

    for line in file:lines() do
        for character in string.gmatch(line, ".") do
            local result = parse(line)
            if (result.type == "Error") then
                table.insert(errors, "[Could not parse Line " .. line_num .. "]: " .. line)
            elseif (result.type == "Section") then
                current_section = result.name
            elseif (result.type == "Value") then
                -- TODO: Parse Keys
                -- detect missing
                -- detect duplicate
            end

            line_num = line_num + 1
        end
    end

    io.close(file)
end

return config_file
