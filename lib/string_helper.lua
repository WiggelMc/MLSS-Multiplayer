---@class StringHelperClass
local string_helper = {}


---@param value any
---@return string
function string_helper.format(value)
    if (type(value) ~= "string") then
        return tostring(value)
    else
        return "\"" .. tostring(value) .. "\""
    end
end

---@param value any
---@return string
function string_helper.format_binary(value)
    if (type(value) == "boolean") then
        if value then
            return "~1"
        else
            return "~0"
        end
    elseif (type(value) == "number") then
        return string.format("0x%02X", value)
    else
        return string_helper.format(value)
    end
end

---@param str string
---@return string
function string_helper.trim_front(str)
    local result = string.gsub(str, "^%s*(.-)$", "%1")
    return result or ""
end

---@param str string
---@return string
function string_helper.trim(str)
    local result = string.gsub(str, "^%s*(.-)%s*$", "%1")
    return result or ""
end

---@param str string
---@return string, string
function string_helper.take_head(str)
    return string.sub(str, 1, 1), string.sub(str, 2)
end

return string_helper
