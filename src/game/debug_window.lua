local string_helper = require "lib.string_helper"
---@class DebugWindowClass
local debug_window = {}


---@param window LuaCanvas
---@return nil
function debug_window.clear(window)
    window.Clear("#181818")
end

---@return LuaCanvas
function debug_window.open()
    ---@type LuaCanvas
    local window = gui.createcanvas(640, 480)
    window.SetTitle("Debug Window")
    debug_window.clear(window)
    return window
end

---@param window LuaCanvas
---@param debug_config DebugConfig
---@param data ByteData
---@return nil
function debug_window.redraw(window, debug_config, data)
    local font_size = math.floor(24.0 * debug_config.debug_window_scale)
    local row_offset = 40.0 * debug_config.debug_window_scale
    local border_size = 5

    debug_window.clear(window)

    local row = 1
    for key, value in pairs(data) do
        ---@type luacolor
        local font_color
        if (row % 2 == 0) then
            font_color = "#FFBBFFCC"
        else
            font_color = "#FFDDDDFF"
        end
        window.DrawText(
            border_size,
            border_size + (row_offset * row) - (row_offset / 2),
            key .. ": " .. string_helper.format_binary(value),
            font_color, "#00000000",
            font_size, nil, "bold",
            "left", "center"
        )
        row = row + 1
    end
    window.Refresh()
end

---@param window LuaCanvas
---@return nil
function debug_window.close(window)
    window["Close"]()
end

return debug_window
