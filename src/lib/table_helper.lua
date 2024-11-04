local string_helper = require "lib.string_helper"
---@class TableHelper
local table_helper = {}



---@param tbl table
---@return string
function table_helper.format_list(tbl)
    local result = "["
    local first_value = true

    for _, tbl_value in ipairs(tbl) do
        if first_value then
            result = result .. " " .. string_helper.format(tbl_value)
        else
            result = result .. ", " .. string_helper.format(tbl_value)
        end
        first_value = false
    end

    if first_value then
        return "[]"
    else
        return result .. " ]"
    end
end

---@param tbl table
---@param indent? integer
---@param base_nesting_level? integer
---@return string
function table_helper.dump(tbl, indent, base_nesting_level)
    indent = indent or 2
    base_nesting_level = base_nesting_level or 0

    local text = ""

    for key, value in pairs(tbl) do
        if (type(value) == "table") then
            text = text
                .. string.rep(" ", base_nesting_level * indent)
                .. string_helper.format(key)
                .. " = "
                .. "\n"
                .. table_helper.dump(value, indent, base_nesting_level + 1)
        else
            text = text
                .. string.rep(" ", base_nesting_level * indent)
                .. string_helper.format(key)
                .. " = "
                .. string_helper.format(value)
                .. "\n"
        end
    end
    return text
end

---@param tbl table
---@return boolean
function table_helper.is_empty(tbl)
    for _, _ in pairs(tbl) do
        return false
    end
    return true
end

---@param tbl1 table
---@param tbl2 table
---@return boolean
function table_helper.compare(tbl1, tbl2)
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
function table_helper.copy(tbl)
    local tbl_copy = {}
    for key, value in pairs(tbl) do
        tbl_copy[key] = value
    end
    return tbl_copy
end

---@param tbl table
---@param depth integer?
---@return table
function table_helper.deepcopy(tbl, depth)
    local tbl_copy = {}
    for key, value in pairs(tbl) do
        if (type(value) == "table") then
            if (depth == nil) then
                tbl_copy[key] = table_helper.deepcopy(value)
            elseif (depth > 1) then
                tbl_copy[key] = table_helper.deepcopy(value, depth - 1)
            else
                tbl_copy[key] = value
            end
        else
            tbl_copy[key] = value
        end
    end
    return tbl_copy
end

---@param tbl table
---@param value any
---@return boolean
function table_helper.contains(tbl, value)
    for _, tbl_value in pairs(tbl) do
        if (value == tbl_value) then
            return true
        end
    end
    return false
end

return table_helper
