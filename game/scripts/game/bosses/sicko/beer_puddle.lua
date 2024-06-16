local Player = require "characters.players.player"
local Entity = require "base.entity"

local BeerPuddle = Entity:extend("BeerPuddle")

function BeerPuddle:new(x, y)
    BeerPuddle.super.new(self, x, y)
    self:setImage("bosses/sicko/projectiles/beer_puddle")
    self:centerY(y)

    self.solid = 0
    self.hitbox = self:addHitbox("solid", 0, 0, self.width, self.height)

    self.increaseTimer = step.during(.4)
    self.puddle = false

    self.drunking = true

    self:tween(.5, { alpha = 0 })
        :onstart(self.F({ drunking = false }))
        :oncomplete(self.F:destroy())
        :delay(5)

    self.z = 1
end

function BeerPuddle:update(dt)
    BeerPuddle.super.update(self, dt)

    if self.increaseTimer(dt) then
        self:increase(dt)
    end
end

function BeerPuddle:increase(dt)
    self.scale.x = self.scale.x + 10 * dt
    self.hitbox.width = self.width * self.scale.x * 0.7
    self.hitbox:setBoundingBox()
end

function BeerPuddle:onOverlap(i)
    if self.drunking then
        if i.e:is(Player) then
            i.e:becomeDrunk()
        end
    end
end

return BeerPuddle
