local wavebreaker = require("wavebreaker")

-- TODO: implement general score tracking
-- TODO: implement choose game dialog
-- TODO: add some music

local GAME = "wavebreaker"

function love.load()
    if GAME == "wavebreaker" then
        CONTROLLER = wavebreaker
    end

    CONTROLLER.load()
end

function love.update(dt)
    CONTROLLER.update(dt)
end

function love.draw()
    CONTROLLER.draw()
end

function love.keypressed(key, scancode, isrepeat)
    CONTROLLER.keypressed(key, scancode, isrepeat)
end
