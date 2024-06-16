local Point = require "base.point"
local Entity = require "base.entity"

local Interactable = Entity:extend("Interactable")

local function lazy()
    local Player = require "characters.players.player"
    local Clone = require "objects.clone"
    local Block = require "objects.block"
    local Horsey = require "bosses.horsey.horsey"
    Interactable:addExclusiveOverlap(Player, Clone, Block, Horsey)
    lazy = nil
end

function Interactable:new(...)
    Interactable.super.new(self, ...)

    if lazy then
        lazy()
    end

    self.on = false

    self.interactable = true

    self.inputInteractable = false

    self.stateChanger = false -- Can change the state of other interactables
    self.onByDefault = false

    self.solid = 0
    self.immovable = true

    self.animations = {
        on = "on",
        off = "off",
    }
end

function Interactable:postNew()
    Interactable.super.postNew(self)
    if not self.linePosition then
        self.linePosition = Point(self:center())
    end
end

function Interactable:done()
    Interactable.super.done(self)
    self.on = self.onByDefault
    if self.anim.hasAnimation then
        self.anim:set(self.on and self.animations.on or self.animations.off)
    end

    if self.connections then
        self.connectionEntities = {}
        for i, v in ipairs(self.connections) do
            local e = self.scene:findEntity(function(e)
                return e.mapEntityId == v.entityId
            end)

            if e then
                table.insert(self.connectionEntities, e)
            else
                warning("No entity found with id " .. v.entityId)
            end
        end
    end
end

function Interactable:update(dt)
    Interactable.super.update(self, dt)
end

function Interactable:draw()
    Interactable.super.draw(self)
end

function Interactable:onInteract()
    self:changeState(not self.on)
end

function Interactable:changeState(toState)
    if toState == nil then
        toState = not self.on
    elseif self.on == toState then
        return
    end

    self.on = toState

    self:triggerConnections()

    self:onStateChanged()
end

function Interactable:triggerConnections()
    if not self.stateChanger then
        return
    end

    for i, v in ipairs(self.connections) do
        local e = self.scene:findEntity(function(e) return e.mapEntityId == v.entityId end)
        if e then
            e:trigger(self.on)
        else
            warning("No entity found with id " .. v.entityId)
        end
    end

    if not self.addedToLineDrawer then
        self.addedToLineDrawer = true
        self.scene.lineDrawer:addInteractable(self)
    end
end

function Interactable:trigger(toState)
    if self.onByDefault then
        toState = not toState
    end

    if self.on == toState then
        return
    end

    self.on = toState
    self:onStateChanged()
end

function Interactable:onStateChanged()
    if self.anim.hasAnimation then
        self.anim:set(self.on and self.animations.on or self.animations.off)
    end

    local sound

    if self.sfx and not self.scene.doorTransition then
        if self.on and self.sfx.on then
            sound = self.scene.sfx:play("interactables/" .. self.sfx.on, "reverb")
        elseif not self.on and self.sfx.off then
            sound = self.scene.sfx:play("interactables/" .. self.sfx.off, "reverb")
        end
    end

    if sound then
        if self.scene.inWater then
            sound:setFilter({ type = "lowpass", highgain = .2 })
        else
            sound:setFilter()
        end
    end
end

function Interactable:isInDefaultState()
    return self.on == self.onByDefault
end

function Interactable:isOn()
    return self.on
end

function Interactable:isInputInteractable()
    return self.inputInteractable
end

function Interactable:drawDashedLine(x1, y1, x2, y2, dashLength, gapLength, offset)
    -- If x1 > x2, swap all values
    local reverse = false
    if x1 > x2 then
        reverse = true
        x1, x2 = x2, x1
        y1, y2 = y2, y1
    end

    -- Calculate distance between two points
    local dx = x2 - x1
    local dy = y2 - y1
    local dist = math.sqrt(dx * dx + dy * dy)

    -- Normalize
    dx = dx / dist
    dy = dy / dist

    local dashCount = math.floor((dist + offset) / (dashLength + gapLength))

    for i = 0, dashCount do
        local dashStart = i * (dashLength + gapLength) - (reverse and -offset or offset)
        local dashEnd = dashStart + dashLength

        -- Adjust for first and last dashes
        if i == 0 then
            dashStart = 0
        elseif i == dashCount then
            dashEnd = dist
        end

        local startX = x1 + dashStart * dx
        local startY = y1 + dashStart * dy
        local endX = x1 + dashEnd * dx
        local endY = y1 + dashEnd * dy

        if endX >= x1 and startX <= x2 then
            love.graphics.line(startX, startY, endX, endY)
        end
    end
end

return Interactable
