local Self = {}

---@return Self
function Self.init()
  local self = setmetatable({}, { __index = Self })
  self.sprite = love.graphics.newImage("assets/wave.png")
  return self
end

function Self:update(_dt)
end

function Self:draw(x, y)
  love.graphics.draw(self.sprite, x, y)
end

function Self:on_shoot(shots)
  for _, s in pairs(shots) do
    local t = 0
    table.insert(s.on_update, function(x, dt, actions)
      t = t + dt
      x.vel.y = x.vel.y + 2 * math.cos(10 * t)
      x.vel.x = x.vel.x - 2 * math.sin(10 * t)
    end)
  end
  return shots
end

return Self
