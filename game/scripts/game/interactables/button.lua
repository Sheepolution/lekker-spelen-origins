local Interactable = require("interactable", ...)

local Button = Interactable:extend("Button")

function Button:new(...)
    Button.super.new(self, ...)
    self:setImage("interactables/button", true)
    self.y = self.y - 6
    self.inputInteractable = true
    self.stateChanger = true

    self.solid = 0
    self.immovable = true

    self.pressCooldown = step.during(.1)
    self.pressCooldown:finish()

    self.sfx = {
        on = "button_press",
    }
end

function Button:done()
    Button.super.done(self)
end

function Button:update(dt)
    Button.super.update(self, dt)
    self.pressCooldown(dt)
end

function Button:onInteract(...)
    if not self.pressCooldown(0) then
        self.on = true
        self:onStateChanged()
        self:triggerConnections()
        self.pressCooldown()
    end
end

return Button
