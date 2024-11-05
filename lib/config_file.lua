local table_helper  = require "table_helper"
local string_helper = require "string_helper"

---@class ConfigFileClass
local config_file   = {}


---@param file_name string
---@return boolean
function config_file.exists(file_name)
    local file = io.open(file_name, "r")
    if (file ~= nil) then
        file:close()
        return true
    else
        return false
    end
end

---@param file_name string
---@param text string
---@return nil
function config_file.generate_preset(file_name, text)
    if config_file.exists(file_name) then
        error("Config File already exists")
    end
    local file = io.open(file_name, "w")
    if file == nil then
        error("File could not be opened")
    end

    file:write(text)
    file:flush()
    file:close()
end

---@param line string
---@param f fun(head: string, tail: string): boolean
---@param buffer? string
---@return string, string?
local function capture_until(line, f, buffer)
    local buffer = buffer or ""
    local head, tail = string_helper.take_head(line)

    if (f(head, tail)) then
        return buffer, line
    elseif (head == "" or head == ";") then
        return buffer, nil
    elseif (head == "\\") then
        local head2, tail2 = string_helper.take_head(tail)
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
    local head, tail = string_helper.take_head(str)
    if (head == "") then
        return buffer
    elseif (head == "\\") then
        local head2, tail2 = string_helper.take_head(tail)
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
    local trimmed_line = string_helper.trim_front(line)
    local head, tail = string_helper.take_head(trimmed_line)

    if (head == ";" or head == "") then
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

        local head2, line2 = string_helper.take_head(line1)

        if (head2 ~= "]") then
            ---@type ParseResult
            return { type = "Error" }
        end

        local trimmed_line2 = string_helper.trim_front(line2)

        local next_char, _ = string_helper.take_head(trimmed_line2)
        if (next_char == "\n" or next_char == "\r" or next_char == ";" or next_char == "") then
            ---@type ParseResult
            return { type = "Section", name = unescape(string_helper.trim(section_name)) }
        else
            ---@type ParseResult
            return { type = "Error" }
        end
    else
        local key, line1 = capture_until(line, function(char)
            return char == "="
        end)

        if (line1 == nil) then
            ---@type ParseResult
            return { type = "Error" }
        end

        local _, line2 = string_helper.take_head(line1)
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
            key = unescape(string_helper.trim(key)),
            value = unescape(string_helper.trim(value))
        }
    end
end

---@param file_name string
---@param type_table table
---@param set_value fun(section: string, key: string, value: any): nil
---@return string[]?
function config_file.read(file_name, type_table, set_value)
    local file = io.open(file_name, "r")

    if (file == nil) then
        error("Config File does not exist")
    end

    ---@type string[]
    local errors = {}
    local line_num = 1
    ---@type string?
    local current_section = nil
    ---@type table<string,string>?
    local current_section_type_table = nil

    for line in file:lines() do
        local result = parse(line)

        if (result.type == "Error") then
            table.insert(errors, "Could not parse Line ["
                .. line_num
                .. "]: "
                .. string_helper.trim(line)
            )
        elseif (result.type == "Section") then
            current_section = result.name
            current_section_type_table = type_table[current_section]
        elseif (result.type == "Value") then
            if (current_section_type_table ~= nil and current_section ~= nil) then
                local value_type = current_section_type_table[result.key]
                current_section_type_table[result.key] = "set"

                if (value_type == nil) then
                    table.insert(errors, "Section \""
                        .. current_section
                        .. "\" does does not accept the Key \""
                        .. result.key
                        .. "\" ["
                        .. line_num
                        .. "]: "
                        .. string_helper.trim(line)
                    )
                elseif (value_type == "set") then
                    table.insert(errors, "The Key \""
                        .. result.key
                        .. "\" was set twice in Section \""
                        .. current_section
                        .. "\" ["
                        .. line_num
                        .. "]: "
                        .. string_helper.trim(line)
                    )
                elseif (value_type == "boolean") then
                    if (result.value == "true") then
                        set_value(current_section, result.key, true)
                    elseif (result.value == "false") then
                        set_value(current_section, result.key, false)
                    else
                        table.insert(errors, "The Key \""
                            .. result.key
                            .. "\" in Section \""
                            .. current_section
                            .. "\" only accepts the Values \"true\" or \"false\", but was provided \""
                            .. result.value
                            .. "\" ["
                            .. line_num
                            .. "]: "
                            .. string_helper.trim(line)
                        )
                    end
                elseif (value_type == "string") then
                    set_value(current_section, result.key, result.value)
                elseif (value_type == "number") then
                    local value = tonumber(result.value)
                    if (value ~= nil) then
                        set_value(current_section, result.key, value)
                    else
                        table.insert(errors, "The Key \""
                            .. result.key
                            .. "\" in Section \""
                            .. current_section
                            .. "\" only accepts integers, but was provided \""
                            .. result.value
                            .. "\" ["
                            .. line_num
                            .. "]: "
                            .. string_helper.trim(line)
                        )
                    end
                elseif (type(value_type) == "table") then
                    if (table_helper.contains(value_type, result.value)) then
                        set_value(current_section, result.key, result.value)
                    else
                        table.insert(errors, "The Key \""
                            .. result.key
                            .. "\" in Section \""
                            .. current_section
                            .. "\" only accepts any of "
                            .. table_helper.format_list(value_type)
                            .. ", but was provided \""
                            .. result.value
                            .. "\" ["
                            .. line_num
                            .. "]: "
                            .. string_helper.trim(line)
                        )
                    end
                end
            end
        end

        line_num = line_num + 1
    end

    file:close()

    for section, section_table in pairs(type_table) do
        for key, value in pairs(section_table) do
            if (value ~= "set") then
                table.insert(errors, "The Key \""
                    .. key
                    .. "\" in Section \""
                    .. section
                    .. "\" was not set"
                )
            end
        end
    end

    if (table_helper.is_empty(errors)) then
        return nil
    else
        return errors
    end
end

return config_file
