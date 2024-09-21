local peachy = require "peachy"
local Vector = require "vector"
local Joe = require "joe"

---@class Slime
local Slime = {}

---@return Slime
function Slime.init(x, y)
  local self = setmetatable({}, { __index = Slime })
  self.sprite = love.graphics.newImage("assets/slime.png")
  self.anim = peachy.new("assets/slime.json", self.sprite, "idle")
  self:idle(1)
  self.dir = nil
  self.pos = Vector.new(x, y)
  self.vel = Vector.new()
  self.gone = false
  return self
end

function Slime:idle(n)
  self.anim:setTag("idle")
  self.anim:onLoop(function()
    if n <= 0 then self:jump(n) else self:idle(n - 1) end
  end)
end

function Slime:jump()
  if self.dir == nil then return self:idle() end
  self.dir = nil
  self.anim:setTag("jump")
  self.anim:onLoop(function()
    self:idle(math.floor(love.math.random(1, 3)))
  end)
end

function Slime:kill()
  self.anim:setTag("death")
  self.anim:onLoop(function() self.gone = true end)
end

JUMP_SPEED = 50

function Slime:update(dt, target)
  self.anim:update(dt)
  self.dir = self.dir or (target - self.pos)
  self.vel = Vector.new()
  if self.anim.tagName == "jump" and self.dir ~= nil then
    if 3 <= self.anim.frameIndex and self.anim.frameIndex <= 7 then
      self.vel = self.dir:norm() * JUMP_SPEED
    end
  end
  self.pos = self.pos + self.vel * dt
end

function Slime:draw()
  if self.gone then return end
  self.anim:draw(Joe.round(self.pos.x), Joe.round(self.pos.y))
end

return Slime
