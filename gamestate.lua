local GameState = {}

--- interface GameState:
---  enter :: () -> state
---  exit :: (state) -> ()
---  update :: (state, inputs, dt) -> ()
---  draw :: (state) -> ()
---@class Instance
local active = {
  enter = function() return {} end,
  exit = function(_) end,
  update = function(_, _, _) end,
  draw = function(_) end,
  state = {}
}

---@class Input
local inputs = {
  up = 0,
  down = 0,
  left = 0,
  right = 0,
  a = 0,
  b = 0,
  start = 0,
  select = 0
}

--- @param state { enter: (fun(): table), exit: (fun(table)), update: (fun(table, inputs: Input, dt: number)), draw: (fun(table))  }
--- @returns Instance
function GameState.new(state)
  return setmetatable(state
  , { __index = GameState })
end

-- @param dt number
function GameState.update(dt)
  if not active then return end
  active.update(active.state, inputs, dt)
end

function GameState.draw()
  if not active then return end
  active.draw(active.state)
end

--- @param new Instance
function GameState.change(new)
  if active then
    active.exit(active.state)
  end
  active = new
  active.state = active.enter()
end

return GameState
