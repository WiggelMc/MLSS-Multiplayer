local player = require "game.player"

---@class DebugGuiClass
local debug_gui = {}

---@param x integer
---@param y integer
---@param column_values ([any,string])[]
---@param row_values (table<any,string>)[]
---@return nil
local function draw_table(x, y, column_values, row_values)
    -- TODO: Change Alignment Point to a corner, instead of center of topLeft text
    -- TODO: Make Alignment Point Flexible, to make corner Choosable (in config)
    -- TODO: Use Config to determine the Gui Size (Size [integer], Corner ["top_left", "top_right", "bottom_left", "bottom_right"]) (add enum type to config "string" vs {"A", "B", "C"})

    local header_offset = 15
    local row_offset = 40
    local column_offset = 80

    gui.drawBox(
        x - (column_offset / 2),
        y - (row_offset / 2),
        x + (column_offset * (#column_values - 1)) + (column_offset / 2),
        y + (row_offset * #row_values + header_offset) + (row_offset / 2),
        "#00000000", "#AA000000"
    )

    for column, column_value in ipairs(column_values) do
        gui.drawString(
            x + (column_offset * (column - 1)),
            y,
            column_value[2],
            "#DD88AAAA", "#00000000",
            20, nil, "bold",
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
                    16, nil, "bold",
                    "center", "center"
                )
            end
        end
    end
end

---@param control_state ControlState
---@param screen_height integer
---@return nil
function debug_gui.redraw(control_state, screen_height)
    gui.use_surface("client")
    gui.clearGraphics()
    local top_offset = screen_height - 70 - 100
    local left_offset = 20 + 100

    local column_values = {
        { player.MARIO, "Mario" },
        { player.LUIGI, "Luigi" }
    }

    local row_values = {
        { [player.MARIO] = "Dpad" },
        { [player.MARIO] = "A",   [player.LUIGI] = "B" },
        { [player.LUIGI] = "L/R" }
    }

    draw_table(left_offset, top_offset, column_values, row_values)

    -- local gui_text = game_data.gui_text

    -- if (ConfigData.show_gui_rect) then
    --     gui.drawBox(left_offset, top_offset + 3, left_offset + 73, top_offset + 28, "#00000000", "#AA000000")
    -- end

    -- if (gui_text.mode ~= nil) then
    --     gui.drawString(left_offset, top_offset + 2, gui_text.mode, "#DD667777", "#00000000", 24, nil, "bold")
    -- end

    -- if (gui_text.front_player ~= nil) then
    --     gui.drawString(left_offset + 30, top_offset + 2, gui_text.front_player, "#DD667777", "#00000000", 24, nil, "bold")
    -- end

    -- if (gui_text.battle_player ~= nil) then
    --     gui.drawString(left_offset + 50, top_offset + 2, gui_text.battle_player, "#DD667777", "#00000000", 24, nil,
    --         "bold")
    -- end
end

return debug_gui
