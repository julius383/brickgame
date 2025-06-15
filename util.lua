local M = {}

local lume    = require("lume")
local stringx = require("pl.stringx")

local FONT = love.graphics.newFont("fonts/bedstead-condensed.otf", 60)

M.CELL_SIZE = 40
M.SPACING = 6
M.PLAYING = true
M.GAME_OVER = false
M.GAME_LEVEL = 1

M.DWIDTH, M.DHEIGHT = 400, 800
M.GRID_COLS = M.DWIDTH / M.CELL_SIZE
M.GRID_ROWS = M.DHEIGHT / M.CELL_SIZE



--- @param hex string
--- @param value number?
--- @return integer[]
function M.hex2color(hex, value)
    return {
        tonumber(string.sub(hex, 2, 3), 16) / 256,
        tonumber(string.sub(hex, 4, 5), 16) / 256,
        tonumber(string.sub(hex, 6, 7), 16) / 256,
        value or 1,
    }
end

---@param r integer grid row
---@param c integer grid col
---@param size number
---@param spacing number
function M.draw_block(r, c, size, spacing)
    local x = (c - 1) * M.CELL_SIZE
    local y =  (r - 1) * M.CELL_SIZE
    size = size or M.CELL_SIZE
    spacing = spacing or M.SPACING
    love.graphics.setColor(lume.color("#222222"))
    love.graphics.rectangle("line", x, y, size, size)
    love.graphics.rectangle(
        "fill",
        x + spacing,
        y + spacing,
        size - spacing * 2,
        size - spacing * 2
    )
end

function M.draw_score(score, begin)
    local text = love.graphics.newText(FONT, string.format("SCORE: \n%d", score))
    local textx = begin + 20
    local texty = 10
    love.graphics.setColor(lume.color("#818b70"))
    love.graphics.setLineWidth(4)
    love.graphics.rectangle("fill",textx - 10, texty - 10, text:getWidth() + 10, text:getHeight() + 10)
    love.graphics.setColor(lume.color("#222222"))
    love.graphics.draw (text, textx, texty)


    textx = begin + 20
    texty = 20 + text:getHeight()
    text = love.graphics.newText(FONT, string.format("\n\nLevel: \n%d", M.GAME_LEVEL))
    love.graphics.setColor(lume.color("#222222"))
    love.graphics.draw (text, textx, texty)
end


function M.draw_gameover(game_width, game_height)
    love.graphics.setBackgroundColor(lume.color("#818b70"))
    local text = love.graphics.newText(FONT, "GAME OVER")
    local textx = math.floor(game_width / 2) - math.floor(text:getWidth()) / 2
    local texty = math.floor(game_height / 2)
    love.graphics.setColor(lume.color("#818b70"))
    love.graphics.rectangle("fill",textx - 10, texty - 10, text:getWidth() + 10, text:getHeight() + 10)
    love.graphics.setColor(lume.color("#222222"))
    love.graphics.draw (text, textx, texty)
end



function M.draw_paused(game_width, game_height)
    -- love.graphics.setBackgroundColor(lume.color("#818b70"))

    local text = love.graphics.newText(FONT, "PAUSED")
    local textx = math.floor(game_width / 2) - math.floor(text:getWidth()) / 2
    local texty = math.floor(game_height / 2)
    love.graphics.setColor(lume.color("#818b70"))
    love.graphics.rectangle("fill",textx - 10, texty - 10, text:getWidth() + 10, text:getHeight() + 10)
    love.graphics.setColor(lume.color("#222222"))
    love.graphics.draw (text, textx, texty)
end


function M.show_array(t, depth)
    local depth = depth or 0
    local s = stringx.indent(string.format("%s\n", t), depth * 4)
    for index, value in ipairs(t) do
        if type(value) == "table" then
            s = s .. M.show_array(value, depth + 1) .. "\n"
        else
            s = s .. stringx.indent(string.format("%d = %s", index, value), depth * 4) .. "\n"
        end
    end
    return s
end

return M
