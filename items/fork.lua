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
  local out = {}
  for _, s in pairs(shots) do
    local a, b, c = s:clone(), s:clone(), s:clone()
    local t = love.math.random() * 0.2 + 0.2
    a.vel = a.vel:clone():rotate(t)
    c.vel = c.vel:clone():rotate(-t)
    table.insert(out, a)
    table.insert(out, b)
    table.insert(out, c)
  end
  return out
end

return Self
