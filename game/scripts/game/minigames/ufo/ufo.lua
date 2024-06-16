local Input = require "base.input"
local Sprite = require "base.sprite"
local HCbox = require "base.hcbox"
local Save = require "base.save"
local SFX = require "base.sfx"
local Entity = require "base.entity"

local Ufo = Entity:extend("Ufo")

Ufo.SFX = {
    crash = {
        SFX("sfx/minigames/ufo/crash3", 1),
        -- SFX("sfx/minigames/ufo/crash1", 1, { pitchRange = .1 }),
        -- SFX("sfx/minigames/ufo/crash2", 1, { pitchRange = .1 }),
    }
}

function Ufo:new(...)
    Ufo.super.new(self, ...)
    self:setImage("minigames/ufo/ufo", true)
    self.anim:set("neither")

    self.controls = {
        [true] = {
            left = { "c1_left_left" },
            right = { "c1_left_right" },
            up = { "up", "c2_left_up" },
            down = { "down", "c2_left_down" },
        },
        [false] = {
            left = { "left", "c2_left_left" },
            right = { "right", "c2_left_right" },
            up = { "c1_left_up" },
            down = { "c1_left_down" },
        }
    }

    if DEBUG then
        self.controls = {
            [true] = {
                left = { "left", "c1_left_left" },
                right = { "right", "c1_left_right" },
                up = { "up", "w", "c2_left_up" },
                down = { "down", "s", "c2_left_down" },
            },
            [false] = {
                left = { "left", "c2_left_left" },
                right = { "right", "c2_left_right" },
                up = { "up", "c1_left_up" },
                down = { "down", "c1_left_down" },
            }
        }
    end

    self.autoFlip.x = false

    self.speed = 150

    self.drag:set(self.speed)
    self.maxVelocity:set(self.speed)

    self.redBar = Sprite(-1, 1, "minigames/ufo/red_bar", true)
    self.redBar.anim:getAnimation("idle"):setSpeed(function()
        -- return (self.velocity.x / self.maxVelocity.x) * 12
        return (self.accel.x / self.maxVelocity.x) * 12
    end)

    self.blueBar = Sprite(0, -1, "minigames/ufo/blue_bar", true)
    self.blueBar.anim:getAnimation("idle"):setSpeed(function()
        return (self.accel.y / self.maxVelocity.y) * 12
    end)

    self.red = false

    self.x = self.x + 16
    self.y = self.y + 16

    self.start = {
        x = self.x,
        y = self.y,
    }

    self:addHitbox(self.width * .68, self.height * .68)

    self.bounce:set(.5)
    self.inControl = false
    self.z = -1
end

function Ufo:done()
    self.hcbox = HCbox(self, self.scene.HC, HCbox.Shape.Circle, self.x, self.y, self.width / 2)
    self.hcboxDanger = HCbox(self, self.scene.HC, HCbox.Shape.Circle, self.x, self.y, self.width / 2 + 7)
end

local timer = 0

function Ufo:update(dt)
    local controls = self.controls[Save:get("settings.controls.peter.player1")]

    self.accel.x = 0
    self.accel.y = 0

    -- local axis_1_x, axis_1_y = Input:getGamepadAxes(1, "left")
    -- local axis_2_x, axis_2_y = Input:getGamepadAxes(2, "left")

    if not self.died and self.inControl then
        local peter, timon = false, false

        if Input:isDown(controls.left) then
            peter = true
            self:accelLeft(self.speed * 1)
        elseif Input:isDown(controls.right) then
            peter = true
            self:accelRight(self.speed * 1)
        end

        if Input:isDown(controls.up) then
            timon = true
            self:accelUp(self.speed * 1)
        elseif Input:isDown(controls.down) then
            timon = true
            self:accelDown(self.speed * 1)
        end

        -- if axis_1_x and _.abs(axis_1_x) > .2 then
        --     peter = true
        --     self:accelRight(self.speed * axis_1_x)
        -- end

        -- if axis_2_x and _.abs(axis_2_y) > .2 then
        --     timon = true
        --     self:accelDown(self.speed * axis_2_y)
        -- end

        if peter and timon then
            self.anim:set("both")
        elseif peter then
            self.anim:set("peter")
        elseif timon then
            self.anim:set("timon")
        else
            self.anim:set("neither")
        end
    end

    -- timer = timer + dt
    -- while timer > 1 / 60 do
    Ufo.super.update(self, dt)
    --     timer = timer - 1 / 60
    -- end

    self.redBar:update(dt)
    self.blueBar:update(dt)

    self.hcbox:update(dt)
    self.hcboxDanger:update(dt)

    local collisions = self.scene.HC:collisions(self.hcboxDanger:getCollider())

    self.inDanger = false
    for k, v in pairs(collisions) do
        if k ~= self.hcbox:getCollider() then
            local parent = k.hcbox.parent
            if parent.isDangerous or (parent.tile and parent.enum == "Dangerous") then
                self.inDanger = true
            end
        end
    end

    collisions = self.scene.HC:collisions(self.hcbox:getCollider())

    for k, v in pairs(collisions) do
        if k ~= self.hcboxDanger:getCollider() then
            self:onOverlapHC(k.hcbox.parent)
        end
    end
end

function Ufo:draw()
    Ufo.super.draw(self)
    self.redBar.offset:set(self.offset:get())
    self.redBar:drawAsChild(self)
    self.blueBar.offset:set(self.offset:get())
    self.blueBar:drawAsChild(self)
end

function Ufo:onOverlapHC(e)
    if self.died then return end
    if self.scene.finished then return end

    if (e.tile and e.enum == "Dangerous") or e.isDangerous then
        self:die()
    end

    if e.tag == "StartFinish" then
        if e.finish then
            self:onFinish()
        else
            self.scene:startRace()
        end
    end

    if e.tag == "Star" then
        e:pickUp()
    end
end

function Ufo:onFinish()
    self.scene:onFinish()
    self.drag:set(self.speed / 2)
end

function Ufo:die()
    if self.died then return end

    self:shake(1, .3, nil, true)
    Input:rumble(1, .5, .3)
    Input:rumble(2, .5, .3)

    self.died = true
    self:stopMoving()
    self.anim:set("dead")
    self.scene:increaseDeathCounters()
    self:delay(2, function()
        self.scene:resetRace()
    end)

    _.pick(self.SFX.crash):play()
    self.scene.music:stop()
end

function Ufo:respawn()
    self.x = self.start.x
    self.y = self.start.y
    self.died = false
    self.anim:set("neither")
end

return Ufo
