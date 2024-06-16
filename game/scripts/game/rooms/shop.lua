local Colors = require "base.colors"
local Save = require "base.save"
local Input = require "base.input"
local Sprite = require "base.sprite"
local Scene = require "base.scene"

local Shop = Scene:extend("Shop")

local SFX = require "base.sfx"

Shop.keys = {
    {
        left = { "c1_left_left", "c1_dpleft" },
        right = { "c1_left_right", "c1_dpright" },
        confirm = { "c1_a" },
        back = { "c1_b", "c1_back", "c1_y" }
    },
    {
        left = { "left", "c2_left_left", "c2_dpleft" },
        right = { "right", "c2_left_right", "c2_dpright" },
        confirm = { "z", "s", "c2_a" },
        back = { "x", "a", "backspace", "c2_b", "c2_back", "c2_y" }
    },
}

if DEBUG then
    Shop.keys = {
        {
            left = { "left", "c1_left_left", "c1_dpleft" },
            right = { "right", "c1_left_right", "c1_dpright" },
            confirm = { "space", "c1_a" },
            back = { "backspace", "c1_b", "c1_back", "c1_y" }
        },
        {
            left = { "a", "c2_left_left", "c2_dpleft" },
            right = { "d", "c2_left_right", "c2_dpright" },
            confirm = { "r", "c2_a" },
            back = { "t", "c2_b", "c2_back", "c2_y" }
        },
    }
end

Shop.SFX = {
    greeting = {
        SFX("sfx/shop/greeting1"),
        SFX("sfx/shop/greeting2"),
        SFX("sfx/shop/greeting3"),
    },
    happy = {
        SFX("sfx/shop/happy3"),
        SFX("sfx/shop/happy2"),
        SFX("sfx/shop/happy4"),
        SFX("sfx/shop/happy5"),
        SFX("sfx/shop/happy1"),
        SFX("sfx/shop/happy6"),
        SFX("sfx/shop/happy7"),
    },
    pay = SFX("sfx/shop/pay")
}

function Shop:new()
    Shop.super.new(self, 0, 0, 960, 600)
    self:setBackgroundImage("shop/background")
    self.price = 10

    -- self.darkness = self:add(Rect(0, 0, WIDTH, HEIGHT))
    -- self.darkness:setColor(0, 0, 0)
    -- self.darkness.alpha = .8

    self.gier = self:add(Sprite(147, 105, "shop/gier", true))
    self.gier.anim:set("default")
    self.gier:centerX(WIDTH / 2)

    self.peter = self:add(Sprite(0, 0, "shop/peter", true))
    self.peter.z = -10
    self.timon = self:add(Sprite(0, 0, "shop/timon", true))
    self.timon.z = -10
    self.peter.anim:set("default")
    self.timon.anim:set("default")

    self.peter:centerX(140)
    self.timon:centerX(WIDTH - 170)

    self.peter:bottom(HEIGHT + 60)
    self.timon:bottom(HEIGHT + 60)

    self.arrowPeter = self:add(Sprite(WIDTH / 2, 514, "shop/arrow_peter"))
    self.arrowPeter:centerX(WIDTH / 2)
    self.arrowPeter.z = -20

    self.arrowTimon = self:add(Sprite(WIDTH / 2, 558, "shop/arrow_timon"))
    self.arrowTimon:centerX(WIDTH / 2)
    self.arrowTimon.flip.x = true
    self.arrowTimon.z = -20

    self.peterArrowValue = -1
    self.timonArrowValue = 1

    self.happyIndex = math.random(1, #Shop.SFX.happy)

    self.goBackDelay = step.after(1)

    self.eatng = false
end

function Shop:done()
    self.scene:startCutscene("meeting_gier")
    if not self.scene.cutscene then
        _.pick(self.SFX.greeting):play("reverb")
        self.y = -60
    else
        self.arrowPeter.visible = false
        self.arrowTimon.visible = false
    end
end

function Shop:update(dt)
    self:handleInput(dt)
    Shop.super.update(self, dt)
    -- Placement.update(self.peter, dt)
end

function Shop:handleInput(dt)
    if self.scene.cutscene then
        return
    end

    local controller_id_peter = Save:get("settings.controls.peter.player1") and 1 or 2
    local controller_id_timon = controller_id_peter == 1 and 2 or 1

    if self.goBackDelay(dt) then
        if Input:isPressed(self.keys[controller_id_peter].back) or Input:isPressed(self.keys[controller_id_timon].back) then
            self:exitShop()
            return
        end
    end

    if self.eating then return end

    if not self:hasEnoughMoney() then
        return
    end

    if Input:isPressed(self.keys[controller_id_peter].left) then
        self.arrowPeter.flip.x = false
        self.peterArrowValue = -1
        self:unconfirmArrow(self.arrowPeter)
    elseif Input:isPressed(self.keys[controller_id_peter].right) then
        self.arrowPeter.flip.x = true
        self.peterArrowValue = 1
        self:unconfirmArrow(self.arrowPeter)
    end

    if Input:isPressed(self.keys[controller_id_timon].left) then
        self.arrowTimon.flip.x = false
        self.timonArrowValue = -1
        self:unconfirmArrow(self.arrowTimon)
    elseif Input:isPressed(self.keys[controller_id_timon].right) then
        self.arrowTimon.flip.x = true
        self.timonArrowValue = 1
        self:unconfirmArrow(self.arrowTimon)
    end

    if Input:isPressed(self.keys[controller_id_peter].confirm) then
        self:confirmArrow(self.arrowPeter)
    end

    if Input:isPressed(self.keys[controller_id_timon].confirm) then
        self:confirmArrow(self.arrowTimon)
    end

    if self.eating then return end

    local value = self.peterArrowValue + self.timonArrowValue
    self.peter.anim:set(value == -2 and "happy" or (value == 0 and "default" or "mad"))
    self.timon.anim:set(value == 2 and "happy" or (value == 0 and "default" or "mad"))


    self.gier.anim:set(value == 0 and "default" or "nervous")
    if _.abs(value) == 2 then
        self.gier.flip.x = value == -2
    end
end

function Shop:hasEnoughMoney()
    local euro = Save:get("game.euro")
    return euro >= self.price
end

function Shop:readyToBuyFlappie()
    local player = self:getBuyingPlayer()
    return player and self:hasEnoughMoney()
end

function Shop:buyFlappie()
    local player = self:getBuyingPlayer()
    local euro = Save:get("game.euro")
    local health_max = Save:get("game.health." .. player .. ".max")

    self.SFX.pay:play("reverb")

    self.SFX.happy[self.happyIndex]:play("reverb")
    self.happyIndex = _.mod(self.happyIndex + 1, #Shop.SFX.happy)

    Save:set("game.euro", euro - self.price)
    Save:set("game.health." .. player .. ".current", health_max + 1)
    Save:set("game.health." .. player .. ".max", health_max + 1)
    self.scene.ui:updateEuros(euro - self.price)
    self.scene.ui:updateHealthMax(player, health_max + 1)
    self.scene.ui:updateHealth(player, health_max + 1)

    self.scene[player].healthMax = self.scene[player].healthMax + 1
    self.scene[player].health = self.scene[player].healthMax

    self.eating = true

    self[player].anim:set("eat")
    local other_player = player == "peter" and "timon" or "peter"
    self[other_player].anim:set("sad")
    self.gier.anim:set("happy_" .. (player == "peter" and "right" or "left"))
    self.gier.flip.x = false
    self:delay(3, self.F:backToNeutral())
    Save:save()
end

function Shop:confirmArrow(arrow)
    arrow.alpha = 1
    arrow.border:set(1)
    arrow.confirmed = true
    self:onArrowConfirmed()
end

function Shop:onArrowConfirmed()
    if self.arrowPeter.confirmed and self.arrowTimon.confirmed and self:getBuyingPlayer() then
        local player = self:getBuyingPlayer()
        local health_max = Save:get("game.health." .. player .. ".max")
        if health_max < 11 then
            self:buyFlappie()
        end
    end
end

function Shop:unconfirmArrow(arrow)
    -- arrow.alpha = .5
    arrow.border:set(0)
    arrow.confirmed = false
end

function Shop:backToNeutral()
    self.eating = false

    self.arrowPeter.flip.x = false
    self.peterArrowValue = -1
    self:unconfirmArrow(self.arrowPeter)

    self.arrowTimon.flip.x = true
    self.timonArrowValue = 1
    self:unconfirmArrow(self.arrowTimon)

    self.gier.anim:set("default")
    self.peter.anim:set("default")
    self.timon.anim:set("default")
end

function Shop:getBuyingPlayer()
    local value = self.peterArrowValue + self.timonArrowValue
    return value == -2 and "peter" or (value == 2 and "timon" or nil)
end

function Shop:exitShop()
    self.goBackDelay()
    self.scene:findEntityWithTag("Gier").goInDelay()
    self.scene:fadeOut(0.5, function()
        self:destroy()
        self.scene:getPlayers()(function(e) e.inControl = true end)
        self.scene:fadeIn(0.5, nil, false)
        self.scene.music:setVolume(1 - self.lastMusicVolume)
        self.scene.music:resume()
        self.outside.music:setVolume(self.lastMusicVolume)
        self.outside.insideShop = false
    end, false)
end

function Shop:moveUp()
    self.arrowPeter.visible = true
    self.arrowTimon.visible = true
    self:tween(1, { y = -60 })
end

return Shop
