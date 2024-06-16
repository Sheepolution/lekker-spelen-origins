local BeerPuddle = require("beer_puddle", ...)
local SFX = require "base.sfx"
local Entity = require "base.entity"

local BeerSpill = Entity:extend("BeerSpill")

BeerSpill.sfx = SFX("sfx/bosses/sicko/spill", 1, { pitchRange = .2 })

function BeerSpill:new(x, y)
    BeerSpill.super.new(self, x, y)
    self:setImage("bosses/sicko/projectiles/beer")

    self.origin:set(0, 0)

    self.solid = 0
    self.hitbox = self:addHitbox("solid", 0, 0, self.width, 100, nil, false)

    self.increaseTimer = step.during(.8)
    self.puddle = false
    self.hurtsPlayer = true
    self.z = -4
end

function BeerSpill:update(dt)
    BeerSpill.super.update(self, dt)

    if self.puddle then
        self:decrease(dt)
    else
        if self.increaseTimer(dt) then
            self:increase(dt)
        else
            self.velocity.y = 1000
        end
    end
end

function BeerSpill:increase(dt)
    self.scale.y = self.scale.y + self.scale.y * dt * 5
    self.hitbox.height = self.height * self.scale.y
    self.hitbox:setBoundingBox()
    self.hitbox.changed = true
    self.moved = true
end

function BeerSpill:decrease(dt)
    local inverse = (self.maxScaleY + 13) - self.scale.y
    self.scale.y = self.scale.y - inverse * dt * 5
    self.hitbox.height = self.height * self.scale.y
    self.hitbox:setBoundingBox()
    self.hitbox.changed = true
    self.moved = true
    if self.scale.y <= 0 then
        self:destroy()
    end
end

function BeerSpill:onOverlap(i)
    if i.e.tile then
        if not self.puddle then
            self.sfx:play("reverb")
            self.puddle = true
            self.mapLevel:add(BeerPuddle(self:centerX(), i.theirHitbox.bb.top))
            self.y = i.theirHitbox.bb.top
            self.origin.y = self.height
            self.maxScaleY = self.scale.y
        end
    end
end

return BeerSpill
