local Enemy = require "creatures.enemy"

local Kinker = Enemy:extend("Kinker")

function Kinker:new(...)
    Kinker.super.new(self, ...)
    self:setImage("creatures/enemies/kinker", true)
    self.anim:set("idle")
    self.anim:getAnimation("jump"):onFrame(4, self.F:jump(300))

    self:addHitbox(0, 10, self.width * .75, self.height * .75)

    self.speed = 150
    self.walking = false
    self.bounce.x = 1
    self.useGravity = true
    self.gravity = 1300
    self.hurtsPlayer = true
    self.jumpable = true
end

function Kinker:done()
    Kinker.super.done(self)
    self.jumper = self.type == "Jumper"
end

function Kinker:update(dt)
    if self.dead or not self.scene then
        Kinker.super.update(self, dt)
        return
    end

    local nearestPlayer, distance = self.scene:findNearestPlayer(self)

    if self.jumper then
        self:lookAt(nearestPlayer, nil, true)
        if not self.jumping and not self.prepareJump then
            if distance < 300 then
                self.prepareJump = true
                self.anim:set("jump")
                self:delay(.3, self.F:jump())
                -- self.jumping = true
            elseif distance < 400 then
                self.anim:set("look")
            end
        end
    else
        if not self.walking then
            if distance < 300 then
                self.anim:set("walk")
                self:moveLeft()
                self.walking = true
            elseif distance < 400 then
                self.anim:set("look")
            end
        end
    end

    if self.jumping then
        if self.velocity.y > 0 then
            self.anim:set("fall")
        end
    end


    Kinker.super.update(self, dt)
end

function Kinker:jump()
    self.prepareJump = false
    self.velocity.y = -500
    self.y = self.y - 10
    self.jumping = true
    self:moveForwardHorizontally()
end

function Kinker:onSeparate(e, i)
    Kinker.super.onSeparate(self, e, i)
    if self.jumping then
        if e.tile then
            if i.myBottom then
                self.jumping = false
                self.anim:set("idle")
                self:stopMoving()
            end
        end
    end
end

function Kinker:kill()
    Kinker.super.kill(self)
    self:stopMoving()
    local s = _.scoin()
    self.velocity.x = 100 * s
    self.rotation = 2 * s
    self.velocity.y = -300
    self.gravity = 2500
    self.autoFlip.x = false
    self.anim:set("dead")
    self:delay(1, self.F:destroy())
end

return Kinker
