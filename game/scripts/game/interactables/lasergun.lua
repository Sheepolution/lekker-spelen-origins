local Player = require "characters.players.player"
local Sprite = require "base.sprite"
local Interactable = require("interactable", ...)

local Laser = Interactable:extend("Laser")

Laser:addExclusiveOverlap(Player)

function Laser:new(...)
    Laser.super.new(self, ...)
    self:setImage("hazards/lasergun", true)
    self.solid = 0
    self.spriteLaser = Sprite(16, 7, "hazards/laser", true)
    self.spriteLaser.origin.x = 0
    self.spriteLaser.scale.x = 4
    self.hurtsPlayer = true
    self.teleportsPlayer = true
    self.onByDefault = true
    self.on = true
    self.hitsPlayerSFX = "hazards/laser_hit"
    self.z = ZMAP.IN_FRONT_OF_PLAYERS
end

function Laser:done()
    if self.height > self.width then
        self.x = self.x + 7
        self.angle = PI / 2
        self.offset.y = 3
        self.spriteLaser.angle = PI / 2
        self.spriteLaser.scale.x = self.height / 16 - 1
        self.spriteLaser:set(6, 10)
    else
        self.spriteLaser.scale.x = self.width / 16 - 1
    end

    if self.player then
        self.spriteLaser.anim:set("idle_" .. self.player:lower())
    end

    self.on = self.onByDefault

    self:onStateChanged()

    self:clearHitboxes()
    self:addHitbox()
end

function Laser:update(dt)
    Laser.super.update(self, dt)
    self.spriteLaser:update(dt)
end

function Laser:draw()
    self.spriteLaser:drawAsChild(self, nil, nil, true)
    Laser.super.draw(self)
end

function Laser:onStateChanged()
    self.spriteLaser.visible = self.on
    self.hurtsPlayer = self.on
end

return Laser
