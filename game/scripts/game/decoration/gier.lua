local Interactable = require "interactables.interactable"
local Shop = require "rooms.shop"
local Input = require "base.input"
local Music = require "base.music"
local Sprite = require "base.sprite"

local Gier = Interactable:extend("Gier")

function Gier:new(...)
    Gier.super.new(self, ...)
    self:setImage("decoration/gier")
    self.inputInteractable = true
    self.music = Music("music", "shop")
    self.audioDistance = 600
    self.goInDelay = step.after(1)
    self.character = Sprite(15, -5, "decoration/gier_character", true)
    self.z = 101
end

function Gier:update(dt)
    self.character:update(dt)
    if not self.insideShop and not self.scene.inCutscene then
        local player, distance = self.scene:findNearestPlayer(self)
        if distance < self.audioDistance then
            self.music:play("shop")
            local default_mine = self.music:getDefaultVolume()
            local volume_mine = default_mine * (1 - distance / self.audioDistance)
                * (1 - _.clamp(self:getDistanceY(player) / 250, 0, 1))
            self.music:setVolume(volume_mine)

            local default_scene = self.scene.music:getDefaultVolume()
            local volume_scene = default_scene - volume_mine
            self.scene.music:setVolume(volume_scene)
        else
            self.music:setVolume(0)
            self.scene.music:setVolume(1)
        end

        if player.inControl then
            if self.goInDelay(dt) then
                self.border:set(0, 0)
                if distance < 200 then
                    local players = self.scene:getPlayers()

                    if self:getDistance(players[1]) < 200 and self:getDistance(players[2]) < 200 then
                        if self:overlapsY(players[1]) and self:overlapsY(players[2]) then
                            self.border:set(1, 1)
                            if Input:isPressed(players[1].keys[players[1].controllerId].interact) or Input:isPressed(players[2].keys[players[2].controllerId].interact) then
                                self:enterShop()
                            end
                        end
                    end
                end
            end
        end
    end

    Gier.super.update(self, dt)
end

function Gier:draw()
    Gier.super.draw(self)
    self.character:drawAsChild(self)
end

function Gier:enterShop()
    local shop = Shop()
    shop.outside = self
    shop.lastMusicVolume = self.music:getVolume()
    self.insideShop = true
    self.goInDelay()
    self.scene:getPlayers()(function(e)
        e.inControl = false
        e.movementDirection = nil
        e.lastInputDirection = nil
        e:stopMoving("x")
    end)
    self.scene:fadeOut(0.5, function()
        self.scene:addOverlay(shop)
        self.scene:fadeIn(0.5, nil, false)
        self.music:setVolume(1)
        self.scene.music:setVolume(0)
    end, false)
end

function Gier:onOverlap(i)
    if i.e.playerEntity then
        self.scene.ui:showEuros()
    end
end

function Gier:onInteract()
    -- self:enterShop()
end

return Gier
