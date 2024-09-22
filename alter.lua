local Joe = require "joe"
local peachy = require "peachy"
local items = require "item"
local Self = {}

local sprite
local pixel

---@return Self
function Self.new(at)
  if not sprite then
    sprite = love.graphics.newImage("assets/alter.png")
    pixel = love.graphics.newImage("assets/pixel.png")
  end
  local self = setmetatable({}, { __index = Self })
  self.sprite = peachy.new("assets/alter.json", sprite)

  self.pos = at
  self.particles = love.graphics.newParticleSystem(pixel, 500)
  self.particles:setParticleLifetime(0.5, 2.0)
  self.particles:setEmissionArea("uniform", 5, 2)
  self.particles:setDirection(-math.pi / 2)
  self.particles:setLinearDamping(0.2, 0.2)
  self.particles:setSpeed(4.0, 8.0)
  self.particles:start()
  self:enable()

  return self
end

function Self:enable()
  self.item = Joe.random_from(items):init()
end

function Self:disable()
  self.item = nil
end

function Self:update(dt)
  if self.item == nil then
    self.particles:setEmissionRate(0)
    self.sprite:setTag("inactive")
  else
    self.particles:setEmissionRate(20)
    self.sprite:setTag("active")
  end
  self.particles:setPosition(self.pos.x + 8, self.pos.y + 11)
  self.sprite:update(dt)
  self.particles:update(dt)
end

function Self:draw()
  love.graphics.draw(self.particles, unpack(self.pos))
  self.sprite:draw(math.floor(self.pos.x), math.floor(self.pos.y))
  if self.item then
    self.item:draw(self.pos.x, self.pos.y - 6 + math.sin(love.timer.getTime()))
  end
end

return Self
