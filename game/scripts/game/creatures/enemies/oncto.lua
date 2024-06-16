local Enemy = require "creatures.enemy"

local Oncto = Enemy:extend("Oncto")

function Oncto:new(...)
    Oncto.super.new(self, ...)
    self:setImage("creatures/enemies/oncto", true)

    self.anim:set("idle")

    self.jumpCooldown = step.during(1.5)
    self:addHitbox(40, 90)

    self.hurtsPlayer = true

    self.maxVelocity.y = 300
    self.drag.x = 50
end

function Oncto:done()
    Oncto.super.done(self)
    self.x = self.x - self.width / 2
    self.y = self.y - self.height / 2

    if self.path and #self.path > 0 then
        self.speed = 170
        self.solid = 0

        local tween
        local current = 1
        function tween()
            local next_point = self.path[_.mod(current, #self.path)]
            local distance = _.distance(self.x, self.y, next_point.x - self.width / 2, next_point.y - self.height / 2)
            local duration = distance / self.speed

            self:tween(duration, { x = next_point.x - self.width / 2, y = next_point.y - self.height / 2 }):oncomplete(
                tween):ease("linear")
            current = current + 1
            if current > #self.path then
                table.reverse(self.path)
                current = 1
            end
        end

        self.pathTween = tween
        self:clearHitboxes()
        self:addHitbox(100, 100)
    else
        self.path = nil
        self.gravity = 300
    end

    self.flip.x = true

    self.seenPlayers = {}
end

function Oncto:update(dt)
    if self.path and #self.path > 0 then
        local players = self.scene:getPlayers(self)
        local player, distance = players:find_min(function(e)
            return _.distance(e:centerX(), e:centerY(), self.trigger.x, self.trigger.y)
        end)

        if distance < 100 then
            self.seenPlayers[player.tag:lower()] = true
            if self.seenPlayers.peter and self.seenPlayers.timon then
                if not self.inTween then
                    self.inTween = true
                    self.anim:set("spin")
                    self.pathTween()
                end
            end
        end
    else
        local player, distance = self.scene:findNearestPlayer(self)
        if distance < 300 then
            if player:centerY() < self:centerY() + 100 then
                if not self.jumpCooldown(dt) then
                    self:jump(player)
                end
            end
        end
    end

    Oncto.super.update(self, dt)
end

function Oncto:jump(player)
    self.anim:set("up")
    self.velocity.y = -300
    self.jumpCooldown()
    self:lookAt(player)
    self:moveForwardHorizontally()
    for j = 1, 4 do
        self:emit("bubble", 0, 10, 20)
    end
end

return Oncto
