local HCbox = require "base.hcbox"
local SFX = require "base.sfx"
local Entity = require "base.entity"

local Star = Entity:extend("Star")

Star.SFX = {
    picked_up = SFX("sfx/minigames/ufo/star", 2),
    all = SFX("sfx/minigames/ufo/star_all", 1),
}

function Star:new(...)
    Star.super.new(self, ...)
    self:setImage("minigames/ufo/star", true)
    self.pickedUp = false
    self.bounce:set(1, 1)
    self.start = {
        x = self.x,
        y = self.y
    }
end

function Star:done()
    if self.moveHorizontally then
        self:moveRight()
    end

    if self.moveVertically then
        self:moveDown()
    end
    self.hcbox = HCbox(self, self.scene.HC, HCbox.Shape.Circle, self.x, self.y, self.width / 2)
end

function Star:update(dt)
    Star.super.update(self, dt)
    self.hcbox:update(dt)
end

function Star:pickUp()
    if self.pickedUp then return end
    if self.scene.starsPickedUp == 4 then
        self.SFX.all:play()
    else
        self.SFX.picked_up:play():setPitch(.8 + self.scene.starsPickedUp / 10)
    end
    self.scene:onPickingUpStar()
    self.pickedUp = true
    self.scaleTween = self:tween(self.scale, .3, { x = 0, y = 0 })
        :oncomplete(self.F({ visible = false, scaleTween = false }))
end

function Star:onRaceReset()
    self.pickedUp = false
    self.visible = true
    self.scale:set(1, 1)
    if self.scaleTween then
        self.scaleTween:stop()
    end

    self.anim:set("idle")
end

function Star:onRaceStart()
    self.x = self.start.x
    self.y = self.start.y

    if self.moveHorizontally then
        self:moveRight()
    end

    if self.moveVertically then
        self:moveDown()
    end
end

return Star
