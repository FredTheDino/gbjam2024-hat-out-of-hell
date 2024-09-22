local Self = {}
Self.__index = Self

local Joe = require "joe"

function Self.new(at, vel, lifetime, radius, on_hit)
  return setmetatable({
    pos = Joe.clone(at),
    vel = Joe.clone(vel),
    alive = lifetime,
    radius = radius or 2,
    on_hit = Joe.clone(on_hit) or { function(_, other)
      other:hit()
    end },
    has_hit = false,
  }, Self)
end

function Self:clone()
  return self.new(self.pos, self.vel, self.alive, self.radius, self.on_hit)
end

function Self:update(dt)
  self.pos = self.pos + self.vel * dt
  self.alive = self.alive - dt
end

function Self:hit(other, actions)
  for _, f in pairs(self.on_hit) do
    f(self, other, actions)
  end
end

function Self:keep()
  return self.alive > 0 and not self.has_hit
end

function Self:draw()
  if not self:keep() then return end
  love.graphics.circle("fill",
    math.floor(self.pos.x),
    math.floor(self.pos.y),
    self.radius
  )
end

return Self
