local joe = require "joe"
local Vector = require "vector"
local inspect = require "inspect"
local peachy = require "peachy"
local json = require "peachy.lib.json"

local sprite
local sprite_data

---@class Player
local Player = {}


---@return Player
function Player.init()
  if not sprite then
    sprite = love.graphics.newImage("assets/player.png")
  end
  if not sprite_data then
    sprite_data = json.decode(love.filesystem.read("assets/player.json"))
  end
  local self = setmetatable({}, { __index = Player })
  self.sprite  = peachy.new(sprite_data, sprite, "idle")
  self.pos = Vector(0.0, 0.0)
  self.vel = Vector(0.0, 0.0)
  self.shoot_target = Vector(50, 50)
  self.shoot_speed = 100
  self.shot_life = 1.0
  self.shoot1 = false
  self.shoot2 = false
  self.shoot1_cooldown = 0.0
  self.shoot2_cooldown = 0.0
  return self
end

local speed = 40

---@param inputs Input
---@param dt number
function Player:update(inputs, dt)
  local movement_dir = (Vector.new(joe.iff(inputs.right > 0, speed, 0), 0)
    + Vector.new(joe.iff(inputs.left > 0, -speed, 0), 0)
    + Vector.new(0, joe.iff(inputs.down > 0, speed, 0))
    + Vector.new(0, joe.iff(inputs.up > 0, -speed, 0))
  )
  self.vel = self.vel + movement_dir * dt
  self.vel = self.vel * (0.1 ^ dt)
  self.pos = self.pos + self.vel * dt

  if inputs.a > 0.0 and self.shoot1_cooldown == 0.0 then
    self.shoot1 = true
    self.shoot1_cooldown = 0.2
  else
    self.shoot1 = false
  end

  self.shoot1_cooldown = math.max(0.0, self.shoot1_cooldown - dt)
  self.shoot2_cooldown = math.max(0.0, self.shoot2_cooldown - dt)
  self.sprite:update(dt)
end

function Player:draw()
  self.sprite:draw(joe.round(self.pos.x), joe.round(self.pos.y))
end

return Player
