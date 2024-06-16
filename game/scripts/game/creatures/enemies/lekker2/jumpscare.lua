local Asset = require "base.asset"
local Sprite = require "base.sprite"

local Jumpscare = Sprite:extend("Lekker2")


function Jumpscare:new(...)
    Jumpscare.super.new(self, ...)
    self:setImage("creatures/enemies/lekker2/jumpscare_head")
    self.handLeft = Sprite(-331, 157, "creatures/enemies/lekker2/jumpscare_hand")
    self.handRight = Sprite(291, 157, "creatures/enemies/lekker2/jumpscare_hand")

    self.handLeft.flip.x = true
    self.z = -50

    self:centerX(WIDTH / 2)
    self.y = HEIGHT

    self:tween(.2, { y = 46 })

    self:shake(4, 2)
    self.handLeft:shake(4, 2.3)
    self.handRight:shake(4, 2.3)
    Asset.audio("sfx/enemies/lekker2_jumpscare"):play()
    self:delay(4, self.F:destroy())
end

function Jumpscare:update(dt)
    Jumpscare.super.update(self, dt)
    self.handLeft:update(dt)
    self.handRight:update(dt)
end

function Jumpscare:draw()
    Jumpscare.super.draw(self)
    self.handLeft:drawAsChild(self)
    self.handRight:drawAsChild(self)
end

return Jumpscare
