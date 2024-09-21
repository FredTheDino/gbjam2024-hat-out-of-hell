---@class Fridge
local Fridge = {}

---@return Fridge
function Fridge.init()
  local self = setmetatable({}, { __index = Fridge })
  self.sprite = love.graphics.newImage("assets/fridge.png")
  return self
end

function Fridge:update(_dt)
end

function Fridge:draw(x, y)
  love.graphics.draw(self.sprite, x, y)
end

-- TODO: call this
function Fridge:on_shoot1(shot)
  table.insert(shot.on_hit, function()
    print("you just got fridged")
  end)
end

return Fridge
