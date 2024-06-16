local Sprite = require "base.sprite"
local Input = require "base.input"
local Save = require "base.save"
local Entity = require "base.entity"
local SFX = require "base.sfx"

local Player = Entity:extend("Player")

Player.keys = {
    {
        right = { "right", "c1_dpright", "c1_left_right" },
        cry = { "c1_a", "c1_x", "c1_b", "c1_y" },
    },
    {
        right = { "right", "c2_dpright", "c2_left_right" },
        cry = { "space", "e", "x", "a", "c2_a", "c2_x", "c2_b", "c2_y" },
    }
}

function Player:new(x, y, player)
    Player.super.new(self, x, y)

    self.SFX = {
        SFX("sfx/roof/" .. player .. "_cry1", 1, { pitchRange = .1 }),
        SFX("sfx/roof/" .. player .. "_cry2", 1, { pitchRange = .1 }),
    }

    self:setImage("minigames/roof/sad_" .. player, true)
    self.imageLightningLeft = Sprite(0, 0, "minigames/roof/sad_" .. player .. "_lightning_left", true)
    self.imageLightningLeft.alpha = 0

    self.imageLightningRight = Sprite(0, 0, "minigames/roof/sad_" .. player .. "_lightning_right", true)
    self.imageLightningRight.alpha = 0

    self.shadowLong = Sprite(-238, 148, "minigames/roof/shadow_long")
    self.shadowLong.defaultAlpha = .8
    self.shadowLong.alpha = 0

    if player == "timon" then
        self.shadowLong.visible = false
    end

    self.gravity = 400
    self.offset.y = 30

    self.walkOffset = self:addOffset()

    self.step = 0
    self.stepping = false

    self.player = player

    if player == "timon" then
        self.offset.x = -50
    end

    self.timer = 1

    self.cryCounter = 0

    self.cryRandom = _.chance_auto(.5)
    self.inControl = true
end

function Player:update(dt)
    local controllerId = Save:get("settings.controls." .. self.player .. ".player1") and 1 or 2

    if self.inControl then
        if Input:isPressed(self.keys[controllerId].cry) then
            if not self.anim:is("cry") then
                self:delay(.25, function()
                    if self.cryRandom() then
                        self.SFX[1]:play()
                    else
                        self.SFX[2]:play()
                    end
                end)
            end

            self.stepping = false
            self.velocity.x = 0
            self.anim:set("cry")
            self.walkOffset.y = 0
        end

        if not self.stepping then
            if Input:isPressed(self.keys[controllerId].right) then
                if not self.anim:is("cry") then
                    self.stepping = true
                    self.step = self.step + 1
                    self.velocity.x = 100
                    self.timer = 1
                    self:delay(2.1, function()
                        if not self.anim:is("cry") then
                            self.stepping = false
                            self:stopMoving()
                            self.walkOffset.y = 0
                            if self.step % 3 == 0 then
                                self:delay(.25, function()
                                    if self.cryRandom() then
                                        self.SFX[1]:play()
                                    else
                                        self.SFX[2]:play()
                                    end
                                end)
                                self.anim:set("cry")
                                self.cryCounter = self.cryCounter + 1
                                if self.cryCounter > 2 then
                                    self.scene:showFlashback()
                                end
                            end
                        end
                    end)
                end
            end
        end
    end

    if self:isMoving("x") then
        self.timer = self.timer + dt
        self.walkOffset.y = -_.absincos(self.timer * PI * 3.7) * 6
    end

    self.imageLightningLeft.anim:set(self.anim:get())
    self.imageLightningRight.anim:set(self.anim:get())

    self.imageLightningLeft:update(dt)
    self.imageLightningRight:update(dt)
    Player.super.update(self, dt)
end

function Player:draw()
    self.shadowLong:drawAsChild(self)
    Player.super.draw(self)
    self.imageLightningLeft:drawAsChild(self, nil, nil, true)
    self.imageLightningRight:drawAsChild(self, nil, nil, true)
end

function Player:onLightning(left)
    local lightning = left and self.imageLightningLeft or self.imageLightningRight
    lightning.alpha = 1

    self.shadowLong.alpha = self.shadowLong.defaultAlpha
    self.shadowLong.flip.x = left
    self.shadowLong.x = left and _.abs(self.shadowLong.x) or -_.abs(self.shadowLong.x)

    self:tween(self.shadowLong, .5, { alpha = 0 }):delay(.2)
    self:tween(lightning, .5, { alpha = 0 }):delay(.2)
end

return Player
