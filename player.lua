local Joe = require "joe"
local Vec = require "vector"
local inspect = require "inspect"
local peachy = require "peachy"
local json = require "peachy.lib.json"
local Shot = require "shot"

local sprite
local pixel
local sprite_data

---@class Player
local Player = {}


---@return Player
function Player.init(at)
  if not sprite then
    sprite = love.graphics.newImage("assets/player.png")
    pixel = love.graphics.newImage("assets/pixel.png")
  end
  if not sprite_data then
    sprite_data = json.decode(love.filesystem.read("assets/player.json"))
  end
  local self = setmetatable({}, { __index = Player })
  self.sprite = peachy.new(sprite_data, sprite, "idle")
  self.pos = at or Vec(0.0, 0.0)
  self.vel = Vec(0.0, 0.0)
  self.shoot_target = Vec(50, 50)
  self.shoot_speed = 100
  self.shot_life = 1.0
  self.shoot1 = false
  self.shoot2 = false
  self.shoot1_cooldown = 0.0
  self.shoot2_cooldown = 0.0
  self.hit_cooldown = 0.0
  self.hp = 2
  self.items = {}

  self.particles = love.graphics.newParticleSystem(pixel, 500)
  self.particles:setParticleLifetime(0.5, 1.0)
  self.particles:setEmissionArea("uniform", 8, 8)
  self.particles:setDirection(math.pi / 2)
  self.particles:setLinearDamping(0.2, 1.0)
  self.particles:setSpeed(2.0, 4.0)
  self.particles:start()

  return self
end

local SPEED = 200
local DRAG = 0.01
local SIZE = 16

---@param inputs Input
---@param dt number
function Player:update(inputs, dt, shots)
  self.particles:setEmissionRate(self.hp * 10)
  self.sprite:update(dt)
  self.particles:update(dt)
  self.particles:setPosition(self.pos.x + 8, self.pos.y + 8)

  if self.sprite.tagName == "death" then return end

  local movement_dir = (Vec(Joe.iff(inputs.right > 0, SPEED, 0), 0)
    + Vec(Joe.iff(inputs.left > 0, -SPEED, 0), 0)
    + Vec(0, Joe.iff(inputs.down > 0, SPEED, 0))
    + Vec(0, Joe.iff(inputs.up > 0, -SPEED, 0))
  )
  self.vel = self.vel + movement_dir * dt
  self.vel = self.vel * (DRAG ^ dt)
  self.pos = self.pos + self.vel * dt

  if math.abs(self.vel.x) > 0.1 then
    self.face_left = self.vel.x < 0
  end
  if inputs.a == 1.0 and self.shoot1_cooldown == 0.0 then
    self.shoot1_cooldown = 0.2
    self.sprite:setTag("shoot") -- alt: "shoot-strong"
    self.sprite:onLoop(function()
      self.sprite:setTag("idle")
      self.sprite:onLoop(function() end)
    end)
    local to_insert = { Shot.new(
      self.pos + Vec(Joe.iff(self.face_left, 4, SIZE - 6), 9),
      Vec(Joe.iff(self.face_left, -1, 1), 0) * self.shoot_speed,
      self.shot_life
    ) }
    for _, item in pairs(self.items) do
      to_insert = item:on_shoot(to_insert)
    end
    for _, shot in pairs(to_insert) do
      table.insert(shots, shot)
    end
  end

  self.hit_cooldown = math.max(0.0, self.hit_cooldown - dt)
  self.shoot1_cooldown = math.max(0.0, self.shoot1_cooldown - dt)
  self.shoot2_cooldown = math.max(0.0, self.shoot2_cooldown - dt)
end

function Player:draw()
  love.graphics.draw(self.particles, 0, 0)
  if self.dead then return end

  if self.face_left then
    self.sprite:draw(SIZE + Joe.round(self.pos.x), Joe.round(self.pos.y), 0, -1)
  else
    self.sprite:draw(Joe.round(self.pos.x), Joe.round(self.pos.y), 0, 1)
  end
end

function Player:center()
  return self.pos + Vec(SIZE, SIZE) * 0.5
end

function Player:check_hit(other)
  if self.sprite.tagName == "death" then return end
  if self.sprite.tagName == "hit" then return end
  local r2 = other:radius().x ^ 2 + (SIZE - 4) ^ 2
  local d = self:center() - other:center()
  if d:magSq() < r2 then
    self.vel = d:norm() * SPEED
    self.hp = self.hp - 1
    if self.hp > 0 then
      self.sprite:setTag("hit")
      self.sprite:onLoop(function()
        self.sprite:setTag("idle")
      end)
    else
      self.sprite:setTag("death")
      self.sprite:onLoop(function()
        self.sprite:stop()
        self.dead = true
      end)
    end
  end
end

return Player
