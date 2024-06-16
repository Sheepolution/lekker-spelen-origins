local Painting = require "decoration.horror.painting"
local Enum = require "libs.enum"
local Player = require "characters.players.player"
local Entity = require "base.entity"

local Pickupable = Entity:extend("Pickupable")

Pickupable:addExclusiveOverlap(Player, Painting)

Pickupable.mapDestructionType = Enum(
    "None",
    "Checkpoint",
    "Permanent"
)

function Pickupable:new(...)
    Pickupable.super.new(self, ...)
    self.pickupable = true
    self.holdable = false
    self.pickedUp = false
    self.z = ZMAP.Pickupable
    self.solid = 0
end

function Pickupable:postNew()
    self.mapPermanentDestruction = self.mapDestructionType == Pickupable.mapDestructionType.Permanent

    if self.holdable then
        self.border:set(1, 1)
        self.border.color = { 255, 255, 255 }
    else
        self:addBorder()
    end
    Pickupable.super.postNew(self)
end

function Pickupable:update(dt)
    if not self.pickedUp then
        self.offset.y = math.sin(self.lifespan * PI) * 5
    end

    Pickupable.super.update(self, dt)
end

function Pickupable:onOverlap(i)
    if i.e:is(Player) and (i.theirHitbox == i.e.hitboxMain or i.theirHitbox == i.e.hitboxPickup) and not i.e.teleporting then
        if not self.pickedUp and self.pickupable then
            self:onPickedUp(i.e)
        end
    end
end

function Pickupable:onPickedUp(e)
    if not self.holdable then
        self.z = ZMAP.PickedUpPickupable
        self.pickedUp = true
        self.scale:set(1.2)
        self:tween(self.offset, .3, { y = -15 }):ease("quintout")
        self:tween(self.scale, .3, { x = 0, y = 0 })
            :ease("quintin")
            :oncomplete(self.F:destroy())
    else
        if e.canHold then
            self.pickedUp = true
            self.offset:set(0, 0)
            self.z = 0
            self.border:set(0, 0)
            e:holdItem(self)
        end
    end

    if self.pickedUp then
        if self.sfx then
            local sound = self.scene.sfx:play("pickupables/" .. self.sfx)
            if sound then
                if self.scene.inWater then
                    sound:setFilter({ type = "lowpass", highgain = .2 })
                else
                    sound:setFilter()
                end
            end
        end
    end
end

function Pickupable:destroy()
    if self.mapDestructionType == Pickupable.mapDestructionType.Checkpoint
        or self.mapDestructionType == Pickupable.mapDestructionType.Permanent then
        self.scene:registerDestroyedPickupable(self)
    end

    Pickupable.super.destroy(self)
end

return Pickupable
