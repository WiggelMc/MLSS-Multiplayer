local player = require "game.player"

---@class DebugGuiClass
local debug_gui = {}


---@class (exact) DisplayData
---@field screen_width integer
---@field screen_height integer


---@return DisplayData
function debug_gui.get_display_data()
    ---@type DisplayData
    return {
        screen_width = client.screenwidth(),
        screen_height = client.screenheight()
    }
end

---@param x integer
---@param y integer
---@param column_values ([any,string])[]
---@param row_values (table<any,string>)[]
---@param size number
---@param anchor HudPosition
---@return nil
local function draw_table(x, y, column_values, row_values, size, anchor)
    size = size * 0.9

    local header_offset = 15.0 * size
    local row_offset = 40.0 * size
    local column_offset = 80.0 * size
    local header_font = math.floor(20.0 * size)
    local normal_font = math.floor(16.0 * size)

    x = x + (column_offset / 2)
    y = y + (row_offset / 2)

    if (anchor == "top_right" or anchor == "bottom_right") then
        x = x - (column_offset * #column_values)
    end

    if (anchor == "bottom_left" or anchor == "bottom_right") then
        y = y - ((row_offset * (#row_values + 1)) + header_offset)
    end

    gui.drawBox(
        x - (column_offset / 2),
        y - (row_offset / 2),
        x + (column_offset * (#column_values - 1)) + (column_offset / 2),
        y + (row_offset * #row_values) + header_offset + (row_offset / 2),
        "#00000000", "#DD000000"
    )

    for column, column_value in ipairs(column_values) do
        gui.drawString(
            x + (column_offset * (column - 1)),
            y,
            column_value[2],
            "#DD88AAAA", "#00000000",
            header_font, nil, "bold",
            "center", "center"
        )
    end

    for row, row_value in ipairs(row_values) do
        for column, column_value in ipairs(column_values) do
            local item_value = row_value[column_value[1]]
            if (item_value ~= nil) then
                gui.drawString(
                    x + (column_offset * (column - 1)),
                    y + (row_offset * row) + header_offset, item_value,
                    "#DD667777", "#00000000",
                    normal_font, nil, "bold",
                    "center", "center"
                )
            end
        end
    end
end

---@param control_state ControlState
---@param display_data DisplayData
---@param debug_config DebugConfig
---@return nil
function debug_gui.redraw(control_state, display_data, debug_config)
    gui.use_surface("client")
    gui.clearGraphics()

    if (not debug_config.show_hud) then
        return
    end

    local border_size = 4

    ---@type integer
    local top_offset
    if (debug_config.hud_position == "top_left" or debug_config.hud_position == "top_right") then
        top_offset = border_size
    else
        top_offset = display_data.screen_height - border_size
    end

    ---@type integer
    local left_offset
    if (debug_config.hud_position == "top_left" or debug_config.hud_position == "bottom_left") then
        left_offset = border_size
    else
        left_offset = display_data.screen_width - border_size
    end

    local column_values = {
        { player.MARIO, "Mario" },
        { player.LUIGI, "Luigi" }
    }

    local row_values = {}    
    table.insert(row_values, { [control_state.primary] = "Dpad" })

    ---@type Player
    local a_player
    if (control_state.a_player == "Mario") then
        a_player = player.MARIO
    else -- "Primary"
        a_player = control_state.primary
    end

    if (control_state.face_button_control == "Primary") then
        table.insert(row_values, { [a_player] = "A/B" })
    else -- "Split"
        table.insert(row_values, { [a_player] = "A", [player.get_other(a_player)] = "B" })
    end

    if (control_state.menu_button_control == "Primary") then
        table.insert(row_values, { [a_player] = "L/R" })
    else -- "Split"
        table.insert(row_values, { [a_player] = "R", [player.get_other(a_player)] = "L" })
    end

    draw_table(left_offset, top_offset, column_values, row_values, debug_config.hud_size, debug_config.hud_position)
end

return debug_gui
