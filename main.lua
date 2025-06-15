local wavebreaker = require("wavebreaker")
local snake = require("snake")
local lume = require("lume")
local util = require("util")

-- TODO: implement choose game dialog
-- TODO: add some music

local GAME = "wavebreaker"

function love.load()
    if GAME == "wavebreaker" then
        CONTROLLER = wavebreaker
    elseif GAME == "snake" then
        CONTROLLER = snake
    end

    CONTROLLER.load()
end

function love.update(dt)
    CONTROLLER.update(dt)
end

function love.draw()
    love.graphics.setColor(lume.color("#222222"))
    love.graphics.rectangle("line", 0, 0, util.DWIDTH, util.DHEIGHT)
    CONTROLLER.draw()
end

function love.keypressed(key, scancode, isrepeat)
    CONTROLLER.keypressed(key, scancode, isrepeat)
end
