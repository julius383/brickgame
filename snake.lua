local M = {}

-- stylua: ignore start
local lume    = require("lume")
local class   = require("pl.class")
local array2d = require("pl.array2d")
local tablex  = require("pl.tablex")
local log     = require("log")
local util    = require("util")

-- stylua: ignore end

local ATE_FOOD = false

--- @class Snake
--- @field trail integer[][]
--- @field speed integer
--- @field interval integer
--- @field timer integer
--- @field direction integer[]
--- @field score integer
local Snake = class()

--- @param start_row integer
--- @param start_col integer
function Snake:_init(start_row, start_col)
  self.trail = { { start_row, start_col }, { start_row, start_col - 1 }, { start_row, start_col - 2 } }
  self.speed = 3 -- tiles per second
  self.interval = 1 / self.speed
  self.timer = 0
  self.direction = { 0,  1 }
  self.score = 0
end

function Snake:draw()
  for _, value in ipairs(self.trail) do
    local row, col = table.unpack(value)
    util.draw_block(row, col)
  end
end

function Snake:update(dt)
  -- log.info(string.format("trail \n%s", util.show_array(self.trail)))
  local head_row, head_col = table.unpack(self.trail[1])
  local rowv, colv = table.unpack(self.direction)
  local new_head = {
    (head_row + rowv) % (util.GRID_ROWS + 1),
    (head_col + colv) % (util.GRID_COLS + 1),
  }
  log.info(util.show_array(new_head))
  table.insert(self.trail, 1, new_head)
  if not ATE_FOOD then
    table.remove(self.trail, #self.trail)
  else
    -- eat food so grow
    ATE_FOOD = false
    self.score = self.score + 5
    util.GAME_LEVEL = math.floor(self.score / 10) + 1
  end
end


--- @class Mouse
--- @field postion integer[]
local Mouse = class()

function Mouse:_init()
  self.postion = {}
end

function Mouse:spawn(except)
  local row
  local col
  local stop = false
  while not stop do
    row = math.floor(lume.random(1, util.GRID_ROWS))
    col = math.floor(lume.random(1, util.GRID_COLS))
    for _, value in ipairs(except) do
      local arow, acol = table.unpack(value)
      if arow ~= row or acol ~= col then
        stop = true
        break
      end
    end
  end
  self.position = { row, col }
end

function Mouse:draw()
  local row, col = table.unpack(self.position)
  util.draw_block(row, col)
end

function M.load()
  SNAKE = Snake(math.floor(util.GRID_ROWS / 2), math.floor(util.GRID_COLS / 2))
  MOUSE = Mouse()
  MOUSE:spawn(SNAKE.trail)
end

function M.draw()
  love.graphics.setBackgroundColor(lume.color("#818b70"))
  SNAKE:draw()
  MOUSE:draw()
  util.draw_score(SNAKE.score, util.DWIDTH)
  if util.GAME_OVER then
    util.draw_gameover(util.DWIDTH, util.DHEIGHT)
    return
  end
  if not util.PLAYING then
    util.draw_paused(util.DWIDTH, util.DHEIGHT)
    return
  end
end

function M.update(dt)
  if util.GAME_OVER then
    return
  end
  if util.PLAYING then
    SNAKE.timer = SNAKE.timer + dt
    -- FIXME: jitter when level changes and speed adjusted
    while SNAKE.timer >= (SNAKE.interval - (0.5 * util.GAME_LEVEL)) do
      SNAKE.timer = SNAKE.timer - SNAKE.interval
      SNAKE:update()
      if tablex.compare(SNAKE.trail[1], MOUSE.position, "==") then
        ATE_FOOD = true
        MOUSE:spawn(SNAKE.trail)
      end
    end
  else
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
    SNAKE.direction = { 0, 1 }
  end
  if key == "left" or key == "D" then
    SNAKE.direction = { 0, -1 }
  end
  if key == "up" or key == "W" then
    SNAKE.direction = { -1, 0 }
  end
  if key == "down" or key == "S" then
    SNAKE.direction = { 1, 0 }
  end
end

return M
