local Interactable = require("interactable", ...)

local Switch = Interactable:extend("Switch")

function Switch:new(...)
    Switch.super.new(self, ...)
    self:setImage("interactables/switch", true)

    self.y = self.y - 6
    self.solid = 0
    self.immovable = true

    self.inputInteractable = true
    self.stateChanger = true

    self.sfx = {
        on = "lever_activate",
        off = "lever_deactivate",
    }
end

return Switch
