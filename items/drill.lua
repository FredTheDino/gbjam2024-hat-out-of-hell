local Self = {}

---@return Self
function Self.init()
  local self = setmetatable({}, { __index = Self })
  self.sprite = love.graphics.newImage("assets/drill.png")
  return self
end

function Self:update(_dt)
end

function Self:draw(x, y)
  love.graphics.draw(self.sprite, x, y)
end

function Self:on_shoot(shots)
  for _, s in pairs(shots) do
    local copy = s:clone()
    table.insert(s.on_hit, function(a, _, actions)
      copy.pos = s.pos
      copy.vel.y = love.math.random(-2, 2)
      actions.shoot(copy)
    end)
  end
  return shots
end

return Self
