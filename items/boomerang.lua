local Self = {}

---@return Self
function Self.init()
  local self = setmetatable({}, { __index = Self })
  self.sprite = love.graphics.newImage("assets/boomerang.png")
  return self
end

function Self:update(_dt)
end

function Self:draw(x, y)
  love.graphics.draw(self.sprite, x, y)
end

function Self:on_shoot(shots)
  for _, s in pairs(shots) do
    table.insert(s.on_update, function(x, dt, actions)
      if x._boomerang_time == nil then x._boomerang_time = 0.5 end
      x._boomerang_time = x._boomerang_time - dt
      if x._boomerang_time < 0 then
        x.vel:rotate(dt)
      end
    end)
  end
  return shots
end

return Self
