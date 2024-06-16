local Sprite = require "base.sprite"
local Text = require "base.text"
local SFX = require "base.sfx"
local Interactable = require("interactable", ...)

local Telegate = Interactable:extend("Telegate")

Telegate.SFX = {
    teleportIn = SFX("sfx/interactables/telegate_in", 1),
    teleportOut = SFX("sfx/interactables/telegate_out", 1),
}

function Telegate:new(...)
    Telegate.super.new(self, ...)
    self:setImage("interactables/telegate/telegate", true)
    self.anim:set("off")
    self.solid = false
    self.immovable = true
    self.y = self.y - 5

    self.inputInteractable = true

    self.rings = list()

    self.insideRingBackground = self.rings:add(Sprite(0, 0, "interactables/telegate/inside_background"))
    self.insideRingTwo = self.rings:add(Sprite(0, -4, "interactables/telegate/inside_ring2"))
    self.insideRingThree = self.rings:add(Sprite(0, -3, "interactables/telegate/inside_ring3"))
    self.insideRingFour = self.rings:add(Sprite(0, -3, "interactables/telegate/inside_ring4"))

    self.insideRings = list({ self.insideRingBackground, self.insideRingTwo, self.insideRingThree, self.insideRingFour })
    self.insideRings:foreach(function(e)
        e.visible = false
    end)

    self.ringThree = self.rings:add(Sprite(-2, -3, "interactables/telegate/ring3", true))
    self.ringTwo = self.rings:add(Sprite(-2, -4, "interactables/telegate/ring2", true))
    self.ringOne = self.rings:add(Sprite(-1, -6, "interactables/telegate/ring1", true))
    self.ringOne.origin.x = self.ringOne.origin.x + 1
    self.ringOne.origin.y = self.ringOne.origin.y + 1
    self.ringTwo.origin.x = self.ringTwo.origin.x + 1
    self.ringTwo.origin.y = self.ringTwo.origin.y + 1
    self.ringThree.origin.x = self.ringThree.origin.x + 1
    self.ringThree.origin.y = self.ringThree.origin.y + 1

    self.outerRings = list({ self.ringThree, self.ringTwo, self.ringOne })

    self.outerRings:foreach(function(e)
        e.anim:set("off")
    end)

    self.ringOne.visible = true
    self.ringTwo.visible = true
    self.ringThree.visible = true

    self.bothPlayersNear = false
    self.warpTimer = 0
end

function Telegate:done()
    Telegate.super.done(self)
    if self.on or self.scene:isTelegateActive(self) then
        self:turnOn(true)
    end

    self.lightSource = self.scene:addLightSource(self, 100, 100)
end

function Telegate:update(dt)
    self.rings:update(dt)

    if self.on then
        local players = self.scene:getPlayers()
        if not self.warpingPlayers then
            self.bothPlayersNear = players:all(function(e)
                return self:getDistance(e) < 100
            end)
        end

        self.border:set(self:canWarpPlayers() and 1 or 0)
    end

    Telegate.super.update(self, dt)
end

function Telegate:draw()
    self.rings:drawAsChild(self)
    Telegate.super.draw(self)
end

function Telegate:onStateChanged()
    if self.on then
        self:turnOn()
    else
        self:turnOff()
    end
end

function Telegate:onInteract()
    if self:canWarpPlayers() then
        self:warpPlayersIn()
    end
end

function Telegate:canWarpPlayers()
    return self.on and self.bothPlayersNear and not self.warpingPlayers and not self.scene.inCutscene
        and self.scene.timon.inControl and not self.scene.timon.inCutscene
end

function Telegate:warpPlayersIn()
    self.warpingPlayers = true

    self:delay(1, function()
        self.scene:fadeOut(1)
    end)

    self.SFX.teleportIn:play("reverb")

    local players = self.scene:getPlayers()
    players:foreach(function(e, i)
        e:onWarpIn(i)
        self:tween(e.scale, 2, { x = 0, y = 0 })
        local tween = self:tween(e, 2, { x = self:centerX() - e.width / 2, y = self:centerY() - e.height / 2 - 10 })
        if i == 1 then
            tween:oncomplete(function()
                self.scene:warpToLevel(self.warpsTo)
            end)
        end
    end)
end

function Telegate:warpPlayersOut(callback)
    self:turnOn(true)
    self.warpingPlayers = true

    self.SFX.teleportOut:play("reverb")

    local players = self.scene:getPlayers()
    players:foreach(function(e, i)
        -- Turn this into a tween coming from center
        -- TODO: Are the 2 lines below necessary?
        e:centerX(self:centerX())
        e:centerY(self:centerY() - 10)
        e.flip.x = false

        -- Tween
        self:tween(e, 2, { x = self:centerX() - e.width / 2 - 60 + i * 40, y = self:centerY() - e.height / 2 - 10 })

        e.rotation = -e.rotation

        local tween = self:tween(e.scale, 2, { x = 1, y = 1 }):ease("quartin")
        tween:oncomplete(function()
            e.angle = 0
            e.rotation = 0
            e.useGravity = true
            if i == 1 then
                if not self.onByDefault then
                    self:turnOff()
                end
                self.warpingPlayers = false
                callback()
            end
        end)
    end)
end

function Telegate:turnOn(instant)
    self.on = true
    self.anim:set("on")
    self.outerRings:foreach(function(e)
        e.anim:set("on")
    end)

    if instant then
        self.ringOne.rotation = 1
        self.ringTwo.rotation = -2
        self.ringThree.rotation = 4
    else
        self.ringOne:tween(2, { rotation = 1 })
        self.ringTwo:tween(2, { rotation = -2 })
        self.ringThree:tween(2, { rotation = 4 })
        self.scene:saveTelegateActive(self)
    end

    self.insideRingTwo.rotation = 3
    self.insideRingThree.rotation = -4
    self.insideRingFour.rotation = 5

    self.insideRings:foreach(function(e)
        e.visible = true
        if instant then
            e.alpha = 1
        else
            e.alpha = 0
            self:tween(e, 2, { alpha = 1 }):delay(1)
        end
    end)
end

function Telegate:turnOff()
    self.on = false
    self.border:set(0)
    self.anim:set("off")
    self.outerRings:foreach(function(e)
        e.anim:set("off")
    end)

    self.ringOne:tween(2, { rotation = 0 })
    self.ringTwo:tween(2, { rotation = 0 })
    self.ringThree:tween(2, { rotation = 0 })

    self.insideRings:foreach(function(e)
        self:tween(e, .3, { alpha = 0 })
    end)
end

return Telegate
