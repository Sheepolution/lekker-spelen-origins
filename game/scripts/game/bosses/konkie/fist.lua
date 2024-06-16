local SFX = require "base.sfx"
local Enemy = require "creatures.enemy"

local Fist = Enemy:extend("Fist")

Fist.SFX = {
    slam = SFX("sfx/bosses/konkie/fist_slam", 1, { pitchRange = .1 }),
}

function Fist:new(konkie, x, y, left)
    Fist.super.new(self)
    self:setImage("bosses/konkie/fist")
    if left then
        self.leftFist = true
        self.flip.x = true
    end

    self.y = y
    self.offsetXStart = x
    self.offsetX = x

    self:setStart()

    self.konkie = konkie

    self.autoFlip.x = false

    self.moveDelay = step.every(1, 3)
    self.z = ZMAP.DoorSide - 1

    self.slamming = false
    self.solid = 0
    self.health = nil

    self:addHitbox(self.width * .7, self.height * .9)
end

function Fist:update(dt)
    self:centerX(self.konkie:centerX() + self.offsetX)
    if self.moveDelay(dt) then
    end
    Fist.super.update(self, dt)
    self.hurtsPlayer = self.y > self.last.y
end

function Fist:slam(speed)
    self.slamming = true
    speed = speed or 1
    self:tween(.2 / speed, { y = self.start.y - 20 })
        :after(.2 / speed, { y = self.start.y + 90 }):ease("quintin")
        :oncomplete(function()
            self.SFX.slam:play("reverb")
            self.scene:shake(5, .3)
            self.scene:rumble(2, .2)
        end)
        :after(.2, { y = self.start.y }):delay(.5 / speed)
end

function Fist:moveToPlayer(pcx, konkieToX)
    local cx = konkieToX + self.offsetXStart
    local dx = cx - pcx
    self:tween(.5, { offsetX = self.offsetXStart - dx })
        :ease("quadout")
        :oncomplete(function()
            self:slam(2)
        end)
end

function Fist:moveBackToStart()
    self:tween(.5, { offsetX = self.offsetXStart })
end

function Fist:moveToTheSide(direction)
    self:tween(.5, { offsetX = self.offsetXStart + 70 * direction })
end

function Fist:moveABit(direction)
    self:tween(.2, { offsetX = self.offsetX + 28 * direction })
end

return Fist
