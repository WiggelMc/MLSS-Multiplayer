---@class StringHelper
local string_helper = {}

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
