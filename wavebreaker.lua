local M = {}

-- stylua: ignore start
local lume     = require("lume")
local class    = require("pl.class")
local array2d  = require("pl.array2d")
local tablex   = require("pl.tablex")
local log      = require("log")
local operator = require("pl/operator")
-- local Timer = require("lib.timer")
local util     = require("util")
-- stylua: ignore end

--- @class Wave
--- @field columns integer
--- @field rows integer
--- @field board integer[][]
local Wave = class()

--- @class Breaker
--- @field position table
local Breaker = class()

--- @class Projectile
--- @field position table
local Bullet = class()

--- @param rows integer
--- @param columns integer
function Wave:_init(rows, columns)
    self.columns = columns
    self.rows = rows
    self.board = {}
    self.speed = 0.25    -- tiles per second
    self.interval = 1 / self.speed
    self.timer = 0
    self.score = 0
end

function Wave:advance()
    -- TODO: adjust advancement speed based on score thresholds
    if #self.board < (self.rows  - 2) then
        local new_line = tablex.new(self.columns, 1)
        local num_holes = lume.random(1, math.ceil(self.columns * 0.5))
        for _ = 1, num_holes do
            local m = math.random(self.columns)
            new_line[m] = 0
        end
        table.insert(self.board, 1, new_line)
    else
        util.GAME_OVER = true
    end
    array2d.write(self.board)
end

function Wave:clear_line()
    local to_remove = {}
    for _, line in ipairs(self.board) do
        if tablex.reduce('+',line) == self.columns then
            table.insert(to_remove, line)
        end
    end
    if next(to_remove) ~= nil then
        -- score calculation (10 * (to_remove.size )) + abs(self.board.size - self.rows)
        self.score = self.score + (10 * #to_remove + math.abs(self.rows - #self.board))
        util.GAME_LEVEL = math.floor(self.score / 100) + 1
    end
    while next(to_remove) ~= nil do
        local v = table.remove(to_remove)
        local i = tablex.find(self.board, v)
        table.remove(self.board, i)
    end
end

function Wave:draw()
    love.graphics.setColor(lume.color("#222222"))
    love.graphics.rectangle("line", 0, 0, util.DWIDTH, util.DHEIGHT)
    for row = 1, #self.board do
        for col = 1, self.columns do
            local v = self.board[row][col]
            if v == 1 then
                util.draw_block(row, col)
            end
        end
    end
end

function Bullet:_init(s_row, s_column)
    self.pos = { row = s_row, column = s_column }
end

function Bullet:draw()
    local row = self.pos.row
    local col = self.pos.column

    util.draw_block(row, col) -- center block
end

function Breaker:_init()
    self.pos = {}
    self.pos.row = util.GRID_ROWS
    self.pos.column = math.floor(util.GRID_COLS / 2)
    self.bullets = {}
    self.timer = 0
    self.speed = 4      -- tile per second
    self.interval = 1 / self.speed
end

function Breaker:__tostring()
    local s =
        string.format("row = %d, column = %d", self.pos.row, self.pos.column)
    return s
end

function Breaker:draw()
    local rrow = self.pos.row
    local rcol = self.pos.column

    util.draw_block(rrow, rcol) -- center block
    util.draw_block(rrow - 1, rcol) -- turret
    util.draw_block(rrow, rcol - 1) -- left wing
    util.draw_block(rrow, rcol + 1) -- right wing
    for _, bullet in ipairs(self.bullets) do
        bullet:draw()
    end
end


function Breaker:fire()
    local b_row = self.pos.row
    local b_col = self.pos.column
    local proj = Bullet(b_row - 1, b_col)
    table.insert(self.bullets, 1, proj)
end

--- @param wave Wave
--- @param breaker Breaker
local function collide(wave, breaker)
    local bullets = breaker.bullets
    local to_remove = {}
    for _, bullet in ipairs(bullets) do
        local board = wave.board
        local b_row = bullet.pos.row
        local b_col = bullet.pos.column
        local next_pos = nil
        if board[b_row - 1] ~= nil then
            next_pos =  board[b_row - 1][b_col]
        end
        if next_pos == nil or next_pos == 0 then    -- bullet unobstructed
            bullet.pos.row = b_row - 1
        else
            if b_row - 1 == #board then     -- create new wave front
                local new_line = tablex.new(wave.columns, 0)
                new_line[b_col] = 1
                table.insert(wave.board, new_line)
                array2d.write(wave.board)
            else
                wave.board[b_row][b_col] = 1
            end
            table.insert(to_remove, bullet)
        end
    end
    while next(to_remove) ~= nil do
        local v = table.remove(to_remove)
        local i = tablex.find(bullets, v)
        table.remove(breaker.bullets, i)
    end
end


function M.load()
    WAVE = Wave(util.GRID_ROWS, util.GRID_COLS)
    BREAKER = Breaker()
end

---@param dt number time since the last update in seconds
function M.update(dt)
    if util.GAME_OVER then
        return
    end
    if util.PLAYING then
        BREAKER.timer = BREAKER.timer + dt
        while BREAKER.timer >= (BREAKER.interval - (0.05 * util.GAME_LEVEL)) do
            BREAKER.timer = BREAKER.timer - BREAKER.interval
            collide(WAVE, BREAKER)
        end
        WAVE:clear_line()
        WAVE.timer = WAVE.timer + dt
        while WAVE.timer >= (WAVE.interval - (0.05 * util.GAME_LEVEL)) do
            WAVE.timer = WAVE.timer - WAVE.interval
            WAVE:advance()
        end
    else
        return
    end
end

function M.draw()
    love.graphics.setBackgroundColor(lume.color("#818b70"))
    WAVE:draw()
    BREAKER:draw()
    util.draw_score(WAVE.score, util.DWIDTH)
    if util.GAME_OVER then
        util.draw_gameover(util.DWIDTH, util.DHEIGHT)
        return
    end
    if not util.PLAYING then
        util.draw_paused(util.DWIDTH, util.DHEIGHT)
        return
    end
end

---@param key string
---@param scancode string
---@param isrepeat boolean
function M.keypressed(key, scancode, isrepeat)
    if key == "q" then
        love.event.quit()
    end
    if key == "space" then
        util.PLAYING = not util.PLAYING
    end
    if key == "right" or key == "A" then
        -- GRID_COLS - 1 so breaker can move to last column
        BREAKER.pos.column =
            lume.clamp(BREAKER.pos.column + 1, 1, util.GRID_COLS)
    end
    if key == "left"or key == "D"  then
        -- BREAKER.pos.column - 1 so breaker can move to last column
        BREAKER.pos.column = lume.clamp(BREAKER.pos.column - 1, 1, util.GRID_COLS)
    end
    if key == "up" or key == "W" then
        BREAKER:fire()
    end
end


return M
