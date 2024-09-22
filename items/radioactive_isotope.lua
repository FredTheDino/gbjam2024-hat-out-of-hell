local Self = {}

---@return Self
function Self.init()
  local self = setmetatable({}, { __index = Self })
  self.sprite = love.graphics.newImage("assets/radioactive_isotope.png")
  return self
end

function Self:update(_dt)
end

function Self:draw(x, y)
  love.graphics.draw(self.sprite, x, y)
end

function Self:on_shoot(shots)
  for _, s in pairs(shots) do
    local alive = s.alive
    table.insert(s.on_update, function(x, dt, actions)
      if x._radioactive_isotope == nil then x._radioactive_isotope = love.math.random() * x.alive * 3 end
      x._radioactive_isotope = x._radioactive_isotope - dt
      if x._radioactive_isotope < 0 then
        local copy = x:clone()
        copy.vel = copy.vel:random() * x.vel:getmag()
        copy.alive = alive / 2
        copy._radioactive_isotope = 1000000
        actions.shoot(copy)

        local copy = x:clone()
        copy.vel = copy.vel:random() * x.vel:getmag()
        copy.alive = alive / 2
        copy._radioactive_isotope = 1000000
        actions.shoot(copy)

        x.alive = 0
      end
    end)
  end
  return shots
end

return Self
