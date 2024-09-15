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
local zeroInput = {
  up = 0,
  down = 0,
  left = 0,
  right = 0,
  a = 0,
  b = 0,
  start = 0,
  select = 0
}
local inputs = zeroInput

--- @param state { enter: (fun(): table), exit: (fun(table)), update: (fun(table, inputs: Input, dt: number)), draw: (fun(table))  }
--- @returns Instance
function GameState.new(state)
  return setmetatable(state
  , { __index = GameState })
end

local function check(prop, dt, current)
  if current then
    return math.max(inputs[prop], 0) + dt
  else
    if inputs[prop] > 0 then
      return -inputs[prop]
    else
      return 0
    end
  end
end

-- @param dt number
function GameState.update(dt)
  if not active then return end

  local joysticks = love.joystick.getJoysticks()
  local function joyIsDown(names)
    for _, j in pairs(joysticks) do
      if j:isGamepadDown(names) then return true end
    end
  end

  inputs = {
    up = check("up", dt, love.keyboard.isDown("up", "w") or joyIsDown("dpup")),
    down = check("down", dt, love.keyboard.isDown("down", "s") or joyIsDown("dpdown")),
    left = check("left", dt, love.keyboard.isDown("left", "a") or joyIsDown("dpleft")),
    right = check("right", dt, love.keyboard.isDown("right", "d") or joyIsDown("dpright")),
    a = check("a", dt, love.keyboard.isDown("j", "u", "n", "space") or joyIsDown("a")),
    b = check("b", dt, love.keyboard.isDown("i", "k", "m") or joyIsDown("b")),
    start = check("start", dt, love.keyboard.isDown("z") or joyIsDown("start")),
    select = check("select", dt, love.keyboard.isDown("x") or joyIsDown("guide")),
  }

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
  -- Don't carry inputs between states
  input = zeroInput
  active = new
  active.state = active.enter()
end

return GameState
