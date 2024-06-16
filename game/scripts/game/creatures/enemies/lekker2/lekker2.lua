local Player = require "characters.players.player"
local Jumpscare = require("jumpscare", ...)
local Enemy = require "creatures.enemy"

local Lekker2 = Enemy:extend("Lekker2")

function Lekker2:new(...)
    Lekker2.super.new(self, ...)
    self:setImage("creatures/enemies/lekker2/lekker2", true)
    self.anim:set("sleep")

    self.gravity = 1000

    self.timer = 0
    self.jumpscared = false
    self.active = true

    self.flip.x = _.coin()

    self:addHitbox(0, 8, self.width * .75, self.height * .75)
    self.offset.y = -1
    self.bounce.x = 1
end

function Lekker2:done()
    Lekker2.super.done(self)

    if self.trigger then
        self.active = false
        self.visible = false
        self.triggered = {}
    end
end

function Lekker2:update(dt)
    Lekker2.super.update(self, dt)

    local players = { self.scene.timon, self.scene.peter }

    if not self.awake then
        for i, v in ipairs(players) do
            if not self.active then
                if v.x > self.trigger.x then
                    self.triggered[v.tag] = true
                    if self.triggered.Peter and self.triggered.Timon then
                        self.active = true
                        self.visible = true
                    end
                end
            end

            if self.active and v:isRunning() and self:getDistance(v) < 25 then
                self:attack()
            end

            if self.active and v.flashlight and v.flashlight.visible then
                local t = { x = v.flashlight.x + v.flashlight.offset.x, y = v.flashlight.y + v.flashlight.offset.y }
                local distance = self:getDistance(t)
                if distance < 110 then
                    self.timer = self.timer + dt
                    if self.timer > .5 then
                        self:attack()
                    end
                end
            end
        end
    end
end

function Lekker2:onOverlap(i)
    if not self.jumpscared and self.active and self.awake then
        if i.e:is(Player) then
            self.scene:addOverlay(Jumpscare())
            self.jumpscared = true
            self:stopMoving()
            self:delay(2, i.e.F:die())
            self.anim:set("idle")

            local players = { self.scene.timon, self.scene.peter }
            for __, e in ipairs(players) do
                e.inControl = false
                e:stopMoving("x")
                e.lastInputDirection = nil
                e.movementDirection = nil
            end
        elseif i.e.solid == 2 then
            if i.myLeft or i.myRight then
            end
        end
    end

    return Lekker2.super.onOverlap(self, i)
end

function Lekker2:attack()
    self.anim:set("awake")
    self.awake = true
    self:delay(.25, function()
        if self.jumpscared then return end
        self.anim:set("walk")
        local player = self.scene:findNearestPlayer(self)
        self:lookAt(player)
        self:moveForwardHorizontally(400)
    end)

    self:delay(2, function()
        if not self.jumpscared then
            self:stopMoving()
            self.awake = false
            self.anim:set("sleep")
        end
    end)
end

return Lekker2
