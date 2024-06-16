local Player = require "characters.players.player"
local Painting = require "decoration.horror.painting"

local Appie = Painting:extend("Appie")

function Appie:new(...)
    Appie.super.new(self, ...)
    self:setImage("decoration/horror/painting_appie", true)
    self.anim:set("idle")
    self.z = ZMAP.TOP
    self.pendulum = false

    self:addHitbox("solid", self.width * .5, self.height * .5)
end

function Appie:update(dt)
    if self.keycard and self.keycard.pickedUp then
        self:onKeycardPickedUp()
    end

    Appie.super.update(self, dt)
end

function Appie:onOverlap(i)
    if not self.keycard then
        if i.e.tag == "Keycard" then
            self.keycard = i.e
        end
    end

    return Appie.super.onOverlap(self, i)
end

function Appie:onKeycardPickedUp()
    self.keycard = nil
    self.anim:set("sad")
end

return Appie
