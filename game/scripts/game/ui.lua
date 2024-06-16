local Text = require "base.text"
local Sprite = require "base.sprite"
local Save = require "base.save"
local Scene = require "base.scene"

local UI = Scene:extend("UI")

UI.hideY = -70
UI.showY = 0

function UI:new()
    UI.super.new(self, 0, 0, WIDTH, 100)

    self:setBackgroundAlpha(0)

    self.peter = self:add(Sprite(8, 8, "ui/peter", true))
    self.timon = self:add(Sprite(WIDTH - 52, 8, "ui/timon", true))
    self.timon.flip.x = true
    self.peter.anim:set("normal")
    self.timon.anim:set("normal")

    self.peter:addBorder(nil, false)
    self.timon:addBorder(nil, false)

    self.heartsPeterCurrent = list()
    self.heartsTimonCurrent = list()

    self.heartsPeterMax = list()
    self.heartsTimonMax = list()

    self.heartLists = {
        peter = {
            current = self.heartsPeterCurrent,
            max = self.heartsPeterMax
        },
        timon = {
            current = self.heartsTimonCurrent,
            max = self.heartsTimonMax
        }
    }

    self.euro = self:add(Sprite(WIDTH / 2 - 40, 8, "pickupables/euro", true))
    self.euro:addBorder(nil, false)
    self.euroText = self:add(Text(WIDTH / 2, 8, "0", 32))
    self.euroText.border:set(1, 1)

    -- self.euroUpTimeout = step.once(5)

    -- FINAL: UI.hideY
    self.y = UI.hideY
end

function UI:update(dt)
    -- if self.euroUpTimeout(dt) then
    --     self.euroTweenUp = self:tween(.5, { euroY = UI.hideY })
    --         :oncomplete(function() self.euroTweenUp = nil end)
    -- end

    UI.super.update(self, dt)
end

function UI:draw()
    if not self.visible then return end
    UI.super.draw(self)
end

function UI:init()
    self:initHealth()
    self:updateEuros(Save:get("game.euro"))
end

function UI:initHealth()
    self.heartLists.peter.max:destroy()
    self.heartLists.timon.max:destroy()
    self.heartLists.peter.max:clear()
    self.heartLists.timon.max:clear()

    self.heartLists.peter.current:destroy()
    self.heartLists.timon.current:destroy()
    self.heartLists.peter.current:clear()
    self.heartLists.timon.current:clear()

    self.health = Save:get("game.health")

    for player, v in pairs(self.health) do
        for i = 1, v.max do
            self:addHeartMax(player, true)
        end

        for i = 1, v.current do
            self:addHeart(player, true)
        end

        if v.current == 2 and v.max > 2 then
            self[player].anim:set("nervous")
        elseif v.max == 1 then
            self[player].anim:set("scared")
        else
            self[player].anim:set("normal")
        end
    end
end

function UI:updateHealth(player)
    local current = self.health[player].current

    self.health[player].current = Save:get("game.health." .. player).current

    local amount = self.health[player].current

    if amount == current then
        return
    end

    local diff = current - amount

    if diff > 0 then
        for i = 0, diff - 1 do
            self:delay(i * .2, function()
                self:removeHeart(player)
            end)
        end
    else
        for i = 0, _.abs(diff) - 1 do
            -- self:delay(i * .2, function()
            self:addHeart(player)
            -- end)
        end
    end

    if amount == 2 and self.health[player].max > 2 then
        self[player].anim:set("nervous")
    elseif amount == 1 then
        self[player].anim:set("scared")
    else
        self[player].anim:set("normal")
    end
end

function UI:updateHealthMax(player)
    local current = self.health[player].max

    self.health[player].max = Save:get("game.health." .. player).max

    local amount = self.health[player].max

    if amount == current then
        return
    end

    local diff = current - amount

    for i = 0, _.abs(diff) - 1 do
        self:addHeartMax(player)
    end

    if amount == 2 and self.health[player].max > 2 then
        self[player].anim:set("nervous")
    elseif amount == 1 then
        self[player].anim:set("scared")
    else
        self[player].anim:set("normal")
    end
end

function UI:addHeart(player, instant)
    local heart = self:add(Sprite(0, 8, "ui/heart_" .. player, true))
    heart.x = player == "peter"
        and (45 + #self.heartLists.peter.current * 34)
        or (WIDTH - 112 - #self.heartLists.timon.current * 34)

    heart:addBorder(nil, false)
    heart.anim:set("idle")

    if not instant then
        heart.scale:set(0, 0)
        self:tween(heart.scale, .3, { x = 1, y = 1 })
    end

    self.heartLists[player].current:add(heart)
end

function UI:addHeartMax(player, instant)
    local heart = self:add(Sprite(0, 8, "ui/heart_" .. player, true))
    heart.x = player == "peter"
        and (45 + #self.heartLists.peter.max * 34)
        or (WIDTH - 112 - #self.heartLists.timon.max * 34)

    heart.anim:set("idle")
    heart.alpha = .4

    if not instant then
        heart.scale:set(0, 0)
        self:tween(heart.scale, .3, { x = 1, y = 1 })
    end

    self.heartLists[player].max:add(heart)
end

function UI:removeHeart(player)
    local heart = self.heartLists[player].current:last()
    if not heart then return end
    heart.anim:set("explode"):onComplete(function()
        self.heartLists[player].current:remove_value(heart)
        heart:destroy()
    end)
end

function UI:updateEuros(amount)
    self.euroText:write(amount)
    -- self:showEuros()
end

function UI:showEuros()
    -- if self.euroTweenUp then
    --     self.euroTweenUp:stop()
    -- end

    -- if self.euroTweenDown then
    --     self.euroUpTimeout()
    --     return
    -- end

    -- self.euroTweenDown = self:tween(.1, { euroY = 0 })
    --     :oncomplete(function() self.euroTweenDown = nil end)

    -- self.euroUpTimeout()
end

function UI:show()
    self.y = UI.hideY
    self:tween(.5, { y = 0 })
end

function UI:hide()
    self.y = UI.showY
    self:tween(.5, { y = -70 })
end

return UI
