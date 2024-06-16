local HCbox = require "base.hcbox"
local Entity = require "base.entity"

local Door = Entity:extend("Door")

function Door:new(...)
    Door.super.new(self, ...)
    self:setImage("minigames/ufo/door", true)
    self.anim:set("closed")
    self.anim:getAnimation("open")
        :onFrame(2, function()
            self.isDangerous = false
        end)

    self.isDangerous = true
end

function Door:done()
    if self.vertical then
        self.origin:set(0)
        self.angle = PI / 2
        self.x = self.x + 64
        self.flip.y = true
        self.hcbox = HCbox(self, self.scene.HC, HCbox.Shape.Rectangle, self.x, self.y,
            self.height,
            self.width)
    else
        self.hcbox = HCbox(self, self.scene.HC, HCbox.Shape.Rectangle, self.x, self.y,
            self.width,
            self.height)
    end
end

function Door:open()
    self.anim:set("open")
end

function Door:onRaceReset()
    self.anim:set("closed")
    self.isDangerous = true
end

return Door
