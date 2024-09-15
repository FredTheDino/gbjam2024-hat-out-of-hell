local GameState = {}

-- interface GameState:
--  enter :: () -> state
--  exit :: (state) -> ()
--  update :: (state, inputs, dt) -> ()
--  draw :: (state) -> ()
local active = nil
local inputs = nil

function GameState.new(enter, exit, update, draw)
  return setmetatable({
    enter = enter,
    exit = exit,
    update = update,
    draw = draw,
    --
    state = nil,
  }, { __index = GameState })
end

function GameState.update(dt)
  if not active then return end
  active:update(active.state, inputs, dt)
end

function GameState.draw()
  if not active then return end
  active:draw(active.state)
end

function GameState.change(new)
  if active then
    active.exit(active.state)
  end
  new.state = new.enter()
  active = new
end
