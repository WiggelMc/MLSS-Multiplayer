---@class LogicHelperClass
local logic_helper = {}


---@generic T
---@param condition boolean
---@param true_value T
---@param false_value T
---@return T
function logic_helper.ternary(condition, true_value, false_value)
    if condition then
        return true_value
    else
        return false_value
    end
end

return logic_helper
