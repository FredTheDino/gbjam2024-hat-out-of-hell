local Joe = require "joe"
local Vec = require "vector"
local inspect = require "inspect"
local peachy = require "peachy"
local json = require "peachy.lib.json"

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
  self.items = {}

  self.particles = love.graphics.newParticleSystem(pixel, 500)
  self.particles:setParticleLifetime(0.5, 1.0)
  self.particles:setEmissionRate(16.0)
  self.particles:setEmissionArea("uniform", 8, 8)
  self.particles:setDirection(math.pi / 2)
  self.particles:setLinearDamping(0.2, 1.0)
  self.particles:setSpeed(2.0, 4.0)
  self.particles:start()

  return self
end

local SPEED = 200
local DRAG = 0.01

---@param inputs Input
---@param dt number
function Player:update(inputs, dt)
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
    self.shoot1 = true
    self.shoot1_cooldown = 0.2
    self.sprite:setTag("shoot") -- alt: "shoot-strong"
    self.sprite:onLoop(function()
      self.sprite:setTag("idle")
      self.sprite:onLoop(function() end)
    end)
  else
    self.shoot1 = false
  end

  self.shoot1_cooldown = math.max(0.0, self.shoot1_cooldown - dt)
  self.shoot2_cooldown = math.max(0.0, self.shoot2_cooldown - dt)
  self.sprite:update(dt)
  self.particles:setPosition(self.pos.x + 8, self.pos.y + 8)
  self.particles:update(dt)
end

function Player:draw()
  love.graphics.draw(self.particles, 0, 0)

  if self.face_left then
    self.sprite:draw(16 + Joe.round(self.pos.x), Joe.round(self.pos.y), 0, -1)
  else
    self.sprite:draw(Joe.round(self.pos.x), Joe.round(self.pos.y), 0, 1)
  end
end

function Player:shoot(items, shots)
  if self.shoot1 then
    local shot = {
      pos = self.pos + Vec(
        Joe.iff(self.face_left, 4, 16 - 6),
        9
      ),
      vel = Vec(Joe.iff(self.face_left, -1, 1), 0) * self.shoot_speed,
      alive = self.shot_life,
      on_hit = {},
      has_hit = false,
    }
    table.insert(shots, shot)
    for _, item in pairs(items) do
      if item.on_shoot1 then
        item:on_shoot1(shot)
      end
    end
  end
end

return Player
