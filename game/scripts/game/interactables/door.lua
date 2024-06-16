local Peter = require "characters.players.peter"
local Timon = require "characters.players.timon"
local TileGroup = require "base.map.tilegroup"
local Input = require "base.input"
local Sprite = require "base.sprite"
local Player = require "characters.players.player"
local FlagManager = require "flagmanager"
local SFX = require "base.sfx"
local Entity = require "base.entity"

local Door = Entity:extend("Door")

Door.SFX = {
    open = SFX("sfx/interactables/door_open"),
    close = SFX("sfx/interactables/door_close")
}

function Door:new(...)
    Door.super.new(self, ...)
    self:setImage("interactables/door", true)

    self.offset.y = 13

    self.flipped = false

    self.triggerDistance = 150
    self.enterDistance = 50
    self.open = false
    self.solid = 2
    self.immovable = true
    self:addIgnoreCollision(TileGroup)

    self.allowsEntry = true

    self.cutsceneDoor = false
end

function Door:done()
    if self.single then
        self:setImage("interactables/door_single", true)
    end
    self.anim:set("neither")
    if not self.single then
        self.anim:getAnimation("close"):onComplete(function()
            self.open = false
        end)

        self.anim:getAnimation("open"):onFrame(5, function()
            self.hitbox.solid = false
        end)
    end

    if self.flipped then
        self.flip.x = true
        self.x = self.x - 20
        local side = self.mapLevel:add(Sprite(self.x - 29, self.y + self.offset.y, "interactables/door_right"))
        side.z = ZMAP.DoorSide
        side.flip.x = true
        self.side = side
    else
        local side = self.mapLevel:add(Sprite(self.x + 35, self.y + self.offset.y, "interactables/door_right"))
        side.z = ZMAP.DoorSide
        self.side = side
    end

    self.x = self.x + 0.001

    -- -- TODO: This could be done more efficiently
    self.hitbox:setBoundingBox()
    self.hitbox:setBoundingBox(true)
end

function Door:update(dt)
    Door.super.update(self, dt)
    -- if not self.open then
    self:handleOpening()

    if not self.anim:is("open") then
        self.hitbox.solid = true
    end
    -- end
end

function Door:destroy()
    Door.super.destroy(self)
    self.side:destroy()
end

function Door:onOverlap(i)
    if i.e:is(Player) then
        if self.single and i.e.inCutscene then
            return true
        end

        if (self.flipped and i.e:centerX() < self:left()) or (not self.flipped and i.e:centerX() > self:right()) then
            self.scene:onPlayerEnteringDoor(self, self.flipped)
        end

        if i.e.flip.x ~= self.flipped then
            self.scene:onReachingCheckpoint(self)
            return false
        end
    end

    return Door.super.onOverlap(self, i)
end

function Door:hasAccess()
    return FlagManager:get(Enums.Flag.hasAccessPass1) and not self.scene.noDoorAccess and self.allowsEntry
end

function Door:handleOpening()
    local peter = self.scene:findEntityOfType(Peter)
    local timon = self.scene:findEntityOfType(Timon)
    if not peter or not timon then
        return
    end

    local distancePeter = self:getDistanceX(peter)
    local distanceTimon = self:getDistanceX(timon)

    local distancePeterY = self:getDistanceY(peter)
    local distanceTimonY = self:getDistanceY(timon)

    local nearPeter = distancePeter < self.triggerDistance and distancePeterY < 200
    local nearTimon = distanceTimon < self.triggerDistance and distanceTimonY < 200

    if peter.teleporting then
        nearPeter = false
    end

    if timon.teleporting then
        nearTimon = false
    end

    if not nearPeter and not nearTimon then
        self.cutsceneDoor = false
    end

    local center_x_door = self:centerX()
    local center_x_peter = peter:centerX()
    local center_x_timon = timon:centerX()

    if (self.flipped and (center_x_door > center_x_peter or center_x_door > center_x_timon)) or
        (not self.flipped and (center_x_door < center_x_peter or center_x_door < center_x_timon)) then
        self.anim:set("open")
        return
    end

    if self.single then
        if nearPeter or nearTimon then
            self.anim:set("denied")
        else
            self.anim:set("neither")
        end
        return
    end

    if not self:hasAccess() then
        if nearPeter or nearTimon then
            if not self.anim:is("denied") then
                if self.anim:is("open") then
                    self.SFX.close:play("reverb")
                    self.anim:set("close")
                elseif self.anim:is("neither") or self.anim:is("peter") or self.anim:is("timon") then
                    self.anim:set("denied")
                end
            end
        else
            self.anim:set("neither")
        end

        return
    end

    if self.open then
        if self.cutsceneDoor or not nearPeter or not nearTimon or (self.scene.inCutscene and not self.openEvenInCutscene) then
            local frame
            if self.anim:is("open") then
                self.SFX.close:play("reverb")
                frame = self.anim:getFrame()
            end
            self.anim:set("close")
            if frame then
                self.anim:setFrame(_.max(1, self.anim:getFrameCount() - frame))
            end
            return
        else
            if distancePeter < self.enterDistance or distanceTimon < self.enterDistance then
                self.scene:forceEnterDoor(center_x_door < center_x_peter)
                self.hitbox.solid = false
            end
        end
    end

    if nearPeter and nearTimon then
        if (not self.cutsceneDoor and not self.scene.inCutscene) or self.openEvenInCutscene then
            local frame
            if not self.anim:is("open") and not self.scene.doorTransition then
                self.SFX.open:play("reverb")
            end

            if self.anim:is("close") then
                frame = self.anim:getFrame()
            end

            self.anim:set("open")

            if frame then
                self.anim:setFrame(_.max(1, self.anim:getFrameCount() - frame))
            end
            self.open = true
        end
    elseif not self.cutsceneDoor then
        if not nearPeter then
            if not nearTimon then
                self.anim:set("neither")
            else
                self.anim:set("timon")
            end
        else
            self.anim:set("peter")
        end
    else
        self.anim:set("neither")
    end
end

return Door
