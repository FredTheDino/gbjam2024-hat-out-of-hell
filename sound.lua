local Sound = {}

local sounds

function Sound.load()
  sounds = {
    hit = love.audio.newSource("assets/hitHurt-1.wav", "static"),
    hurt = love.audio.newSource("assets/hitHurt.wav", "static"),
    jump = love.audio.newSource("assets/jump.wav", "static"),
    shoot = love.audio.newSource("assets/laserShoot.wav", "static"),
    pickup = love.audio.newSource("assets/powerUp.wav", "static")
  }
end

function Sound.shoot()
  sounds.shoot:setPitch(math.random() * 0.2 + 0.95)
  sounds.shoot:setVolume(math.random() * 0.1 + 0.1)
  sounds.shoot:play()
end

function Sound.pickup()
  sounds.shoot:setPitch(math.random() * 0.1 + 0.95)
  sounds.pickup:setVolume(math.random() * 0.2 + 0.5)
  sounds.pickup:play()
end

function Sound.hit()
  sounds.shoot:setPitch(math.random() * 0.1 + 0.95)
  sounds.hit:setVolume(math.random() * 0.05 + 0.05)
  sounds.hit:play()
end

function Sound.hurt()
  sounds.shoot:setPitch(math.random() * 0.1 + 0.95)
  sounds.hurt:setVolume(math.random() * 0.2 + 0.5)
  sounds.hurt:play()
end

function Sound.jump()
  sounds.shoot:setPitch(math.random() * 0.1 + 0.95)
  sounds.jump:setVolume(math.random() * 0.02 + 0.02)
  sounds.jump:play()
end

return Sound
