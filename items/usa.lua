local Self = {}

---@return Self
function Self.init()
  local self = setmetatable({}, { __index = Self })
  self.sprite = love.graphics.newImage("assets/fridge.png")
  return self
end

function Self:update(_dt)
end

function Self:draw(x, y)
  love.graphics.draw(self.sprite, x, y)
end

function Self:on_shoot(shots)
  for _, s in pairs(shots) do
    s.radius = s.radius + 2
  end
  return shots
end

return Self
