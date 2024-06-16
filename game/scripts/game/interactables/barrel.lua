local Sprite = require "base.sprite"
local SFX = require "base.sfx"
local Interactable = require "interactables.interactable"

local Barrel = Interactable:extend("Barrel")

Barrel.SFX = {
    shoot = SFX("sfx/interactables/barrel_shoot", 5, { pitchRange = .2 }),
}

function Barrel:new(...)
    Barrel.super.new(self, ...)
    self:setImage("interactables/barrel", true)

    self.imagePlayers = Sprite(0, 0, "interactables/barrel_players", true)
    self.imagePlayers.anim:set("none")

    self.hitbox = self:addHitbox(0, 0, 60, 60)

    self.players = list()

    self.solid = 0

    self.autoShootDelay = step.once(.1)
    self.autoShootDelay:finish(true)

    self:setStart()

    self.playerCanEnterDelay = {
        Peter = step.after(.4),
        Timon = step.after(.4),
    }
end

function Barrel:done()
    Barrel.super.done(self)
    if self.blast then
        self.animations.on = "blast"
        if self.on then
            self.anim:set("blast")
        end
    end

    self.angle = _.directionToAngle(Enums.Direction[self.direction])
    self.angleOffset = PI / 2

    if self.path then
        if self.triggerType ~= "Move" then
            local tween
            tween = function()
                self:tween(self.pathDuration / 2, { x = self.path.x, y = self.path.y })
                    :ease("quadinout")
                    :after(self.pathDuration / 2, { x = self.start.x, y = self.start.y })
                    :ease("quadinout")
                    :oncomplete(function()
                        tween()
                    end)
            end
            tween()
        end
    end

    if self.rotationDelay and self.rotationDelay > 0 then
        self.rotationDelay = step.every(self.rotationDelay)
    else
        self.rotationDelay = nil
    end
end

function Barrel:update(dt)
    Barrel.super.update(self, dt)
    if self.autoShootDelay(dt) then
        self:shoot()
    end

    self.playerCanEnterDelay.Peter(dt)
    self.playerCanEnterDelay.Timon(dt)

    self.linePosition:set(self:center())

    if self.rotationDelay and self.rotationDelay(dt) then
        self.angle = self.angle + PI * .25
    end
end

function Barrel:draw()
    Barrel.super.draw(self)
    self.imagePlayers:drawAsChild(self, true, nil, true)
end

function Barrel:onOverlap(i)
    if i.e.playerEntity and not i.e.teleporting then
        if not self.players:contains(i.e) and self.playerCanEnterDelay[i.e.tag](0) then
            self:addPlayer(i.e)
        end
    end
end

function Barrel:addPlayer(player)
    player:goIntoBarrel(self)
    self.players:add(player)

    if #self.players == 2 then
        self.imagePlayers.anim:set("peter_timon")
    else
        self.imagePlayers.anim:set(self.players:first().tag:lower())
    end

    if self.blast then
        self.autoShootDelay()
    end
end

function Barrel:shoot()
    if #self.players == 0 then return end
    self.players:shootFromBarrel(self)
    self.imagePlayers.anim:set("none")

    if self.on then
        self.SFX.shoot:play("reverb")
    end

    for i, v in ipairs(self.players) do
        self.playerCanEnterDelay[v.tag]()
    end

    self:delay(.2, function()
        self.players:clear()
    end)
end

function Barrel:trigger(toState)
    if self.triggerType == "Rotate" then
        self.angle = self.angle + PI * .5
    elseif self.triggerType == "Move" then
        if self.moveTween then
            return
        end

        local x, y
        if self.atPath then
            x, y = self.start.x, self.start.y
        else
            x, y = self.path.x, self.path.y
        end

        self.moveTween = self:tween(self.pathDuration / 2, { x = x, y = y })
            :ease("quadinout")
            :oncomplete(function()
                self.atPath = not self.atPath
                self.moveTween = nil
            end)
    else
        Barrel.super.trigger(self, toState)
    end
end

return Barrel
