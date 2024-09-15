local joe = require "joe"

---@class Player
local Player = {}


---@return Player
function Player.init()
  local self = setmetatable({}, { __index = Player })
  self.x = 0.0
  self.y = 0.0
  return self
end

local speed = 10

---@param inputs Input
---@param dt number
function Player:update(inputs, dt)
  self.x = self.x + (joe.iff(inputs.right > 0, speed, 0) - joe.iff(inputs.left > 0, speed, 0)) * dt
  self.y = self.y + (joe.iff(inputs.down > 0, speed, 0) - joe.iff(inputs.up > 0, speed, 0)) * dt
end

local size = 10

function Player:draw()
  love.graphics.rectangle("fill", self.x - size / 2, self.y - size / 2, size, size)
end

return Player
