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
    table.insert(s.on_hit, function(a, _, actions)
      local copy = a:clone()
      copy.pos = a.pos
      copy.vel.x = copy.vel.x
      actions.shoot(copy)
    end)
  end
  return shots
end

return Self
