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

function Fridge:on_shoot(shots)
  for _, s in pairs(shots) do
    table.insert(s.on_hit, function(_, other)
      other.slow = other.slow + 1
    end)
  end
  return shots
end

return Fridge
