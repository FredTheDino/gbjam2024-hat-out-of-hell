local Self = {}
local Joe = require "joe"

---@return Self
function Self.init()
  local self = setmetatable({}, { __index = Self })
  self.sprite = love.graphics.newImage("assets/fridge.png")
  self.on_pickup = function(_, player)
    if #player.items > 0 then
      local other = player.items[#player.items]
      self.on_pickup = other.on_pickup
      if self.on_pickup then other:on_pickup(player) end
      self.on_shoot = other.on_shoot
    end
  end
  return self
end

function Self:update(_dt)
end

function Self:draw(x, y)
  love.graphics.draw(self.sprite, x, y)
end

return Self
