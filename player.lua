---@class Player
local Player = {}

---@return Player
function Player.init()
    local self = setmetatable({}, {__index = Player})
    self.t = 0.0
    return self
end

---@param dt number
function Player:update(dt)
    self.t = self.t + dt
end

return Player
