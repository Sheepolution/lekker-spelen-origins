local SFX = require "base.sfx"
local Pickupable = require "pickupables.pickupable"

local Euro = Pickupable:extend("Euro")

Euro.multiple = 0

Euro.SFX = {
    coin = SFX("sfx/pickupables/coin8"),
    donation = SFX("sfx/pickupables/donation_coin")
}

function Euro:new(...)
    Euro.super.new(self, ...)
    self:setImage("pickupables/euro", true)
    self.mapDestructionType = Pickupable.mapDestructionType.Checkpoint
    self.sniffable = true
    -- self.sfx = "coin2"
end

function Euro:update(dt)
    Euro.super.update(self, dt)
end

function Euro:onPickedUp()
    Euro.super.onPickedUp(self)
    self.scene:onEuroPickedUp(self)
    local pitch = 1
    Euro.multiple = Euro.multiple + 1
    if Euro.multiple > 1 then
        pitch = pitch + (Euro.multiple - 1) / 12
    end
    local sound = Euro.SFX.coin:play("reverb")
    sound:setPitch(pitch)
    if self.scene.inWater then
        sound:setFilter({ type = "lowpass", highgain = .2 })
    else
        sound:setFilter()
    end

    if Euro.multipleDelay then
        Euro.multipleDelay:stop()
    end

    if Euro.multiple % 3 == 0 then
        local sound2 = Euro.SFX.donation:play()
        if sound2 and self.scene.inWater then
            sound2:setFilter({ type = "lowpass", highgain = .2 })
        else
            sound2:setFilter()
        end
    end

    Euro.multipleDelay = self.scene:delay(1, function()
        Euro.multiple = 0
    end)
end

return Euro
