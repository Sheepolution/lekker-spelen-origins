local TileGroup = require "base.map.tilegroup"
local Point = require "base.point"
local Interactable = require("interactable", ...)

local Gate = Interactable:extend("Gate")

local function lazy()
    local Enemy = require "creatures.enemy"
    local Laser = require "projectiles.laser"
    Gate:addExclusiveOverlap(Enemy, Laser)
    lazy = nil
end

Gate:addIgnoreOverlap(TileGroup)

function Gate:new(...)
    Gate.super.new(self, ...)

    if lazy then
        lazy()
    end

    self:setImage("interactables/gate", true)
    self.solid = 2

    self.anim:getAnimation("down"):onFrame(3, function()
        self.solid = 2
        self.gateDown = true
    end)

    self.anim:getAnimation("up"):onFrame(5, function()
        self.solid = 0
        self.gateDown = false
    end)

    self.y = self.y + 8
    self.flip.x = _.coin()

    if self.flip.x then
        self.x = self.x - 4
    else
        self.x = self.x - 6
    end

    self.unsafeForPlayer = true

    self:addHitbox(1, 0, 32, self.height)

    self.linePosition = Point(self:center())
    self.linePosition.y = self.y

    self.animations.on = "up"
    self.animations.off = "down"

    self.sfx = {
        on = "gate_open",
        off = "gate_close",
    }
end

function Gate:onOverlap(i)
    if not self.gateDown then
        return false
    end

    return Gate.super.onOverlap(self, i)
end

return Gate
