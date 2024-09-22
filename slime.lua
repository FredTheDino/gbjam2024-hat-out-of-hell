local peachy = require "peachy"
local Vec = require "vector"
local Joe = require "joe"

---@class Slime
local Slime = {}

local function jump_speed()
  return love.math.random(45, 60)
end

local RADIUS = 6

---@return Slime
function Slime.init(at)
  local self = setmetatable({}, { __index = Slime })
  self.sprite = love.graphics.newImage("assets/slime.png")
  self.anim = peachy.new("assets/slime.json", self.sprite, "idle")
  self:idle(1)
  self.dir = nil
  self.pos = at or Vec()
  self.vel = Vec()
  self.speed = jump_speed()
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

function Slime:center()
  return self.pos + self:radius() + Vec(1, 4)
end

function Slime:radius()
  return Vec(RADIUS, RADIUS)
end

function Slime:update(dt, target)
  self.anim:update(dt)
  self.dir = self.dir or (target - self.pos)
  if self.anim.tagName == "jump" and self.dir ~= nil then
    if 3 == self.anim.frameIndex and self.vel:magSq() == 0 then
      self.vel = self.dir:norm() * self.speed
    elseif 3 <= self.anim.frameIndex and self.anim.frameIndex <= 7 then
      self.vel = self.vel
    else
      self.vel = Vec()
    end
  else
    self.vel = Vec()
  end
  self.pos = self.pos + self.vel * dt
end

function Slime:draw()
  if self.gone then return end
  self.anim:draw(Joe.round(self.pos.x), Joe.round(self.pos.y))
end

return Slime
