local joe = require "joe"
local Vector = require "vector"

---@class Player
local Player = {}


---@return Player
function Player.init()
  local self = setmetatable({}, { __index = Player })
  self.pos = Vector(0.0, 0.0)
  self.shoot_target = Vector(50, 50)
  self.shoot_speed = 100
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
  self.pos.x = self.pos.x + (joe.iff(inputs.right > 0, speed, 0) - joe.iff(inputs.left > 0, speed, 0)) * dt
  self.pos.y = self.pos.y + (joe.iff(inputs.down > 0, speed, 0) - joe.iff(inputs.up > 0, speed, 0)) * dt

  if inputs.a > 0.0 and self.shoot1_cooldown == 0.0 then
    self.shoot1 = true
    self.shoot1_cooldown = 0.2
  else
    self.shoot1 = false
  end

  self.shoot1_cooldown = math.max(0.0, self.shoot1_cooldown - dt)
  self.shoot2_cooldown = math.max(0.0, self.shoot2_cooldown - dt)
end

local size = 20

function Player:draw()
  love.graphics.rectangle("fill", self.pos.x - size / 2, self.pos.y - size / 2, size, size)
end

return Player
