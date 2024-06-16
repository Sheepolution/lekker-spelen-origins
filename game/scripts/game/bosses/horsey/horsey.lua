local Input = require "base.input"
local Sprite = require "base.sprite"
local SFX = require "base.sfx"
local Entity = require "base.entity"

local Horsey = Entity:extend("Horsey")

Horsey.SFX = {
    hurt = SFX("sfx/bosses/horsey/horsey_hurt"),
    land = SFX("sfx/bosses/horsey/horsey_land"),
}

function Horsey:new(...)
    Horsey.super.new(self, ...)
    self:setImage("bosses/horsey/horsey", true)
    self.legs = Sprite(0, 0, "bosses/horsey/horsey_legs", true)
    self.legs.z = ZMAP.HorseyLegs
    self.y = self.y + 13

    self:addHitbox(0, 44, self.width * .5, self.height * .5)

    self.gravity = 1000
    self.drag.x = 100
    self.speed = 200

    self.anim:getAnimation("walk"):after("idle")
    self.anim:getAnimation("jump"):after("fall"):onFrame(4, function() self:jump() end)
    self.anim:getAnimation("land"):after("idle")
    self.anim:getAnimation("turn"):onComplete(function()
        self.flip.x = not self.flip.x
        self.readyForNextDirection = true
    end):after("idle")

    self.floorButtonPresser = true
    self.readyForNextDirection = true

    self.platformPosition = 6

    self.hurtsPlayer = true

    self.electrocuted = false
end

function Horsey:done()
    self.mapLevel:addEntity(self.legs, true)
    self.x = self.mapLevel.x + 740 - 118
end

function Horsey:update(dt)
    if Input:isPressed("l") then
        self:walkRight()
    elseif Input:isPressed("j") then
        self:walkLeft()
    elseif Input:isPressed("i") then
        self:startJump()
    end

    Horsey.super.update(self, dt)

    self.legs.anim:set(self.anim:get())
    self.legs.anim:setFrame(self.anim:getFrame())
    self.legs.flip.x = self.flip.x
    self.legs.x = self.x
    self.legs.y = self.y

    if self.x < self.mapLevel.x or self.x > self.mapLevel.x + self.mapLevel.width then
        warning("Horsey Boss jumped out of the screen!")
        self.x = self.mapLevel.x + 32
    end
end

function Horsey:draw()
    Horsey.super.draw(self)
end

function Horsey:walkRight()
    if self.electrocuted then return end
    if self.flip.x then
        self:turnAround()
        return
    end

    self.platformPosition = self.platformPosition + 1

    self.anim:set("walk", true)
    self.currentTween = self:tween(.77, { x = self.x + 118 })
        :ease("linear")
        :oncomplete(self.F({
            readyForNextDirection = true,
            currentTween = false,
        }))
end

function Horsey:walkLeft()
    if self.electrocuted then return end
    if not self.flip.x then
        self:turnAround()
        return
    end

    self.platformPosition = self.platformPosition - 1

    self.anim:set("walk", true)
    self.currentTween = self:tween(.77, { x = self.x - 118 })
        :ease("linear")
        :oncomplete(self.F({
            readyForNextDirection = true,
            currentTween = false,
        }))
end

function Horsey:turnAround()
    if self.electrocuted then return end
    self.anim:set("turn")
    -- readyForNextDirection is already set on animation complete in :new()
end

function Horsey:startJump()
    self.platformPosition = self.platformPosition + (2 * _.boolsign(not self.flip.x))
    self.anim:set("jump")
end

function Horsey:jump()
    self:tween(.5, { x = self.x + 236 * _.boolsign(not self.flip.x) })
        :ease("linear")
        :oncomplete(self.F({
            gravity = 5000,
            hurtsPlayer = true
        }))

    self.velocity.y = -500
    self.y = self.last.y
    self.jumping = true
    self.hurtsPlayer = false
end

function Horsey:onLanding()
    self.jumping = false
    self.gravity = 1000

    if not self.electrocuted then
        self.SFX.land:play("reverb")
        self.anim:set("land")
            :onComplete(self.F({
                readyForNextDirection = true,
            }))
        self.roomManager:onHorseyLanding()
    end
end

function Horsey:die()
    self.anim:set("dead")
    self.hurtsPlayer = false
    self.defeated = true
    self.offset.y = 32
end

function Horsey:onSeparate(e, info)
    Horsey.super.onSeparate(self, e, info)
    if e.tile and info.myBottom then
        if self.jumping then
            self:onLanding()
        end
    end
end

function Horsey:onDirection(direction)
    local p = self:calculateCurrentPosition()
    if p ~= self.platformPosition then
        self.platformPosition = p
    end

    self.readyForNextDirection = false
    self.lastAction = direction

    if direction == "right" then
        self:walkRight()
    elseif direction == "left" then
        self:walkLeft()
    elseif direction == "up" then
        self:startJump()
    end
end

function Horsey:isReadyForNextDirection()
    return self.readyForNextDirection
        and not self.electrocuted
        and not self.roomManager.electricityTurnedOn
end

function Horsey:canAcceptDirection(direction)
    if direction == "right" then
        return self.platformPosition < 7
    elseif direction == "left" then
        return self.platformPosition > 1
    elseif direction == "up" then
        local flip = self.flip.x
        if self.anim:is("turn") then
            flip = not flip
        end
        return (flip and self.platformPosition > 2) or (not flip and self.platformPosition < 6)
    end
end

function Horsey:onOverlap(i)
    if i.e.tag == "ElectricPlatform" then
        if i.e.on then
            self:electrify()
        end
    end

    Horsey.super.onOverlap(self, i)
end

function Horsey:electrify()
    if self.electrocuted then
        return
    end

    self.SFX.hurt:play("reverb")
    self.electrocuted = true

    if self.anim:is("jump") then
        self.platformPosition = self.platformPosition - (2 * _.boolsign(not self.flip.x))
    end

    if self.anim:is("turn") then
        self.flip.x = not self.flip.x
    end

    self.anim:set("electric")
    if self.currentTween then
        self.currentTween:pause()
    end
end

function Horsey:electrifyStop()
    if not self.electrocuted then return end
    self.roomManager:onHorseyElectrifiedDone()

    self.electrocuted = false

    if self.defeated then
        return
    end

    if self.currentTween then
        self.anim:set("walk")
        self.currentTween:resume()
    else
        self.anim:set("idle")
        self.readyForNextDirection = true
    end
end

function Horsey:getPreferredDirectionData()
    local data = {}
    local prefer = 85
    local normal = 50
    local dislike = 10

    if self.lastAction == "turn" then
        -- If Horsey just turned, we dislike him turning again straight away.
        data[self.flip.x and "right" or "left"] = dislike
    elseif self.lastAction == "jump" then
        -- If Horsey just jumped, we dislike him turning again straight away.
        data["up"] = prefer
    end

    -- We prefer Horsey walking towards the center
    if self.platformPosition < 4 then
        if self.platformPosition == 2 and not self.flip.x then
            -- If Horsey were to jump now, he would jump straight onto the button, which we like!
            data["up"] = prefer
        end

        -- We like Horsey walking towards the center
        if not data["right"] then
            data["right"] = prefer
        end

        -- We dislike Horsey walking away from the center
        if not data["left"] then
            data["left"] = dislike
        end
    elseif self.platformPosition > 3 then
        if self.platformPosition == 6 and self.flip.x then
            -- If Horsey were to jump now, he would jump straight onto the button, which we like!
            data["up"] = prefer
        end

        -- We like Horsey walking towards the center
        if not data["left"] then
            data["left"] = prefer
        end

        -- We dislike Horsey walking away from the center
        if not data["right"] then
            data["right"] = dislike
        end
    end

    local directions = { "left", "up", "right" }
    for i, v in ipairs(directions) do
        if not data[v] then
            data[v] = normal
        end
    end

    return data
end

function Horsey:calculateCurrentPosition()
    local x = self.x - self.mapLevel.x
    if x == 32 then
        return 1
    elseif x == 150 then
        return 2
    elseif x == 268 then
        return 3
    elseif x == 386 then
        return 4
    elseif x == 504 then
        return 5
    elseif x == 622 then
        return 6
    elseif x == 740 then
        return 7
    end

    -- Place Horsey based on its current platformPosition
    self.x = self.mapLevel.x + 32 + 118 * (self.platformPosition - 1)
    return self.platformPosition
end

function Horsey:destroy()
    Horsey.super.destroy(self)
    self.legs:destroy()
end

return Horsey
