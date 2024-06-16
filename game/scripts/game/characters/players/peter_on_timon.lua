local Peter = require "characters.players.peter"
local Timon = require "characters.players.timon"
local Player = require("player", ...)

local PeterOnTimon = Player:extend("Timon")

function PeterOnTimon:new(...)
    PeterOnTimon.super.new(self, ...)
    self:setImage("characters/players/peter_on_timon", true)

    self.defaultSpeed = 140
    self.runSpeed = 300
    self.speed = self.defaultSpeed
    self.pushSpeed = self.defaultSpeed * 0.5

    self.canCrawl = false
    self.canPush = true
    self.canSniff = false
    self.canCrouch = true

    self.hitboxStand = self:addHitbox("body", 0, 20, 60, 42)
    self.hitboxCrouch = self:addHitbox("crouch", 0, 30, 60, 22)
    self.hitboxCrouch.solid = false
    self.hitboxSwim = self:addHitbox("swim", 0, 14, 60, 22)
    self.hitboxSwim.solid = false

    self.hitboxMain = self.hitboxStand

    self.hitboxBlockPush = self:addHitbox("block_push", 0, 0, 78, 25)

    self.hitboxes = {
        stand = self.hitboxMain,
        crouch = self.hitboxCrouch,
        run = self.hitboxStand,
        jump = self.hitboxStand,
        swim = self.hitboxSwim
    }

    self.isTimon = true

    self.jumpPower = 520
    self.jumpPowerDefault = self.jumpPower

    self.sniffRadius = 0
    self.sniffRadiusMax = 500
    self.sniffOffset = {
        x = 43,
        y = 18
    }

    self.keys = {
        {
            left = { "c1_left_left" },
            right = { "c1_left_right" },
            down = { "c1_left_down", "c1_leftshoulder", "c1_leftstick" },
            up = { "c1_left_up" },
            jump = { "z", "s", "c2_a" },
            run = { "c1_x", "c1_triggerleft" },
            ability = {},
            interact = { "c1_y" },
            sniff = {},
            standstill = {},
        },
        {
            left = { "left", "c2_left_left" },
            right = { "right", "c2_left_right" },
            down = { "down", "c2_left_down", "c2_leftshoulder", "c2_leftstick" },
            up = { "up", "c2_left_up" },
            jump = { "c1_a" },
            run = { "a", "x", "c2_x", "c2_triggerleft" },
            ability = {},
            interact = { "e", "d", "c2_y" },
            sniff = {},
            standstill = {},
        }
    }

    if DEBUG then
        self.keys = {
            {
                left = { "left", "a", "c1_left_left" },
                right = { "right", "d", "c1_left_right" },
                down = { "down", "s", "c1_left_down", "c1_leftshoulder", "c1_leftstick" },
                up = { "up", "w", "c1_left_up" },
                jump = { "up", "w", "c2_a" },
                run = { "lshift", "c1_x", "c1_triggerleft" },
                ability = {},
                interact = { "t", "c1_y" },
                sniff = {},
                standstill = {},
            },
            {
                left = { "left", "a", "c2_left_left" },
                right = { "right", "d", "c2_left_right" },
                down = { "down", "s", "c2_left_down", "c2_leftshoulder", "c2_leftstick" },
                up = { "up", "w", "c2_left_up" },
                jump = { "up", "w", "c1_a" },
                run = { "lshift", "c2_x", "c2_triggerleft" },
                ability = {},
                interact = { "t", "c2_y" },
                sniff = {},
                standstill = {},
            }
        }
    end

    self.abilityColor = { 94 / 255, 174 / 255, 244 / 255 }
    self.teleportEffect.color = self.abilityColor


    self.separatePriority:set(100, 100)
end

function PeterOnTimon:postNew()
    PeterOnTimon.super.postNew(self)
    self.indicator.x = 30
    self.indicator.y = -44
    self.indicator.anim:set("exclamation_timon")
end

function PeterOnTimon:update(dt)
    PeterOnTimon.super.update(self, dt)

    if self.toBeDestroyed then
        self:destroy()
    end

    if self.hurting then
        self.runSpeed = self.defaultSpeed + 40
    else
        local centaur = self.scene:findEntityWithTag("Centaur")
        if centaur then
            if self:getDistanceX(centaur) < 400 then
                self.runSpeed = 350
            else
                self.runSpeed = 300
            end
        end
    end
end

function PeterOnTimon:onOverlap(i)
    if i.e.tag == "Centaur" then
        self:die()
    end

    return PeterOnTimon.super.onOverlap(self, i)
end

function PeterOnTimon:loseHealth()

end

function PeterOnTimon:die()
    if self.toBeDestroyed then return end

    local peter = Peter()
    local timon = Timon()
    self.toBeDestroyed = true

    peter:center(self:center())
    timon:center(self:center())

    peter.died = true
    timon.died = true

    self:delay(.1, function()
        peter.visible = false
        timon.visible = false
    end)

    self.scene.peter = peter
    self.scene.timon = timon

    self.scene:add(peter)
    self.scene:add(timon)
end

return PeterOnTimon
