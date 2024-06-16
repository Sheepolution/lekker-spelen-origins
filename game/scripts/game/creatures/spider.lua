local Entity = require "base.entity"

local Spider = Entity:extend("Spider")

function Spider:new(...)
    Spider.super.new(self, ...)
    self:setImage("creatures/spider", true)
    self.anim:set("idle")

    self.walking = false
    self.gravity = 1000

    self.bounce.x = 1
    self.bounceAccel.x = 1
    self.maxVelocity:set(_.random(400, 800), 1000)
    self.z = ZMAP.IN_FRONT_OF_PLAYERS
end

function Spider:update(dt)
    Spider.super.update(self, dt)

    if not self.walking then
        local players = self.scene:getPlayers()

        for i, v in ipairs(players) do
            if self:getDistance(v) < 40 then
                self:walk()
            end

            if v.flashlight then
                local t = { x = v.flashlight.x + v.flashlight.offset.x, y = v.flashlight.y + v.flashlight.offset.y }
                local distance = self:getDistance(t)
                if distance < 110 then
                    self:walk()
                end
            end
        end
    end
end

function Spider:walk()
    self.walking = true
    self:delay(_.random(.5, .8), function()
        self.anim:set("walk")
        local speed = _.random(100, 550) * 10
        self.accel.x = speed * _.scoin()

        if _.chance(10) then
            self:delay(_.random(.1, .3), function()
                self.y = self.y - 2
                self.velocity.y = -400
            end)
        end

        self:tween(.5, { alpha = 0 }):delay(3)
            :oncomplete(self.F:destroy())
    end)
end

return Spider
