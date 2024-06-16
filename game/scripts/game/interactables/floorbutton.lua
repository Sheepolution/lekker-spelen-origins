-- local xool = require "libs.xool"
local Interactable = require("interactable", ...)

local FloorButton = Interactable:extend("FloorButton")

function FloorButton:new(...)
    FloorButton.super.new(self, ...)
    self:setImage("interactables/floor_button", true)

    self.solid = 0
    self.y = self.y + 4

    self.stateChanger = true

    self.wasPressed = false
    self.pressed = false
    self.isDown = xool.new()

    self.sfx = {
        on = "pressure_plate_press",
        off = "pressure_plate_release",
    }
end

function FloorButton:done()
    self.linePosition.y = self.y

    self.animations.on = "pressed" .. (self.type and ("_" .. self.type:lower()) or "")
    self.animations.off = "idle" .. (self.type and ("_" .. self.type:lower()) or "")

    FloorButton.super.done(self)
end

function FloorButton:update(dt)
    if self.isDown(false) then
        self:changeState(false)
    end

    FloorButton.super.update(self, dt)
end

function FloorButton:onOverlap(i)
    if i.e.tile then
        return false
    end

    if i.e.floorButtonPresser and i.e:centerY() < self:centerY() and not i.e.teleporting then
        if not self.type or i.e.tag == self.type or i.e.playerTag == self.type then
            self.pressed = true
            if not self.isDown(true) then
                self:changeState(true)
            end
        end
    end

    -- NOTE: If you change the return value you might need to fix something in Computer:startWaku()
end

return FloorButton
