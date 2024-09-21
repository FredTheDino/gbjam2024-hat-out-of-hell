local peachy = require "peachy"
local Vector = require "vector"

---@class Slime
local Slime = {}

---@return Slime
function Slime.init(x, y)
  local self = setmetatable({}, { __index = Slime })
  self.sprite = love.graphics.newImage("assets/slime.png")
  self.anim = peachy.new("assets/slime.json", self.sprite, "idle")
  self.pos = Vector.new(x, y)
  return self
end

function Slime:update(dt)
  self.anim:update(dt)
end

function Slime:draw()
  self.anim:draw(self.pos.x, self.pos.y)
end

return Slime
