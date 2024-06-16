local Text = require "base.text"
local Scene = require "base.scene"
local Save = require "base.save"
local tips = require "data.tips"

local DeathScreen = Scene:extend("DeathScreen")

function DeathScreen:new(...)
    DeathScreen.super.new(self, ...)
    self.dyingPlayers = list()
    self:setBackgroundColor(12, 12, 12, 0)

    self.visible = false

    self.textDeathCounterWord = self:add(Text(WIDTH / 2, 10, "DEATH COUNTER", "bebas", 64))
    self.textDeathCounterWord.alpha = 0
    self.textDeathCounterWord:setAlign("center", 1000)
    self.textDeathCounterList = list()
    self.textDeathCounterCurrentList = list()

    for i = 1, 2 do
        local amount     = _.random(18, 28, true)
        local current    = self:add(Text(WIDTH / 2, 100, amount, "bebas", 64))
        local counter    = self:add(Text(WIDTH / 2, -100, amount + 1, "bebas", 64))
        counter.velocity = 500
        counter.gravity  = 2000
        counter.visible  = false
        counter:setAlign("center", 100)
        current.alpha = 0
        current:setAlign("center", 100)

        self.textDeathCounterList:add(counter)
        self.textDeathCounterCurrentList:add(current)
    end

    self.textTip = self:add(Text(WIDTH / 2, HEIGHT - 100, "tip: Je kan bukken onder Horsey", "bebas", 32))
    self.textTip:setAlign("center", WIDTH)
    self.textTip.alpha = 0
end

function DeathScreen:update(dt)
    if not self.visible then return end
    DeathScreen.super.update(self, dt)
    self.dyingPlayers:update(dt)

    for i, text in ipairs(self.textDeathCounterList) do
        if text.visible then
            text.velocity = text.velocity + text.gravity * dt
            text.y = text.y + text.velocity * dt
            if text.y > 100 then
                self.textDeathCounterCurrentList[i].visible = false
                text.y = 100
                text.velocity = -text.velocity * .3
                if text.velocity > -10 then
                    text.velocity = 0
                end
            end
        end
    end
end

function DeathScreen:draw()
    if not self.visible then
        return
    end

    DeathScreen.super.draw(self)
    self.dyingPlayers:draw()
end

function DeathScreen:onPlayerDying(player1, player2)
    self.visible = true
    self.dyingPlayers:clear()
    self.backgroundAlpha = 0
    self.textDeathCounterWord.alpha = 0
    self.textTip.alpha = 0
    self.dyingPlayers:add(player1)
    self.textDeathCounterList(function(e) e.visible = false end)
    self.textDeathCounterCurrentList(function(e) e.visible = false end)

    if player2 then
        self.dyingPlayers:add(player2)
    end

    self.dyingPlayers:die()

    for i, v in ipairs(self.dyingPlayers) do
        local camX, camY = self.scene.camera:toScreen(v.x, v.y)
        v.x, v.y = camX, camY

        local toX = WIDTH / 2 - v.width / 2 - 10

        if #self.dyingPlayers == 2 then
            toX = WIDTH / 2 - v.width / 2 - 300 + 200 * i
        end

        self:tween(v, .5, {
            x = toX,
            y = HEIGHT / 2 - v.height / 2
        }):ease("quintout")

        self:tween(v.scale, .5, { x = 2, y = 2 })
            :ease("quintout")

        local text = self.textDeathCounterList[i]

        text.y = -100
        text.velocity = 0
        text.visible = false
        text:write(Save:get("game.deaths." .. v.tag:lower()))

        if #self.dyingPlayers == 2 then
            text.gravity = 2000 + _.random(-400, 400)
            text.x = WIDTH / 2 - 200 / 2 + 200 * (i - 1)
        else
            text.gravity = 2000
            text.x = WIDTH / 2
        end

        self:delay(2, function()
            text.visible = true
        end)

        local current = self.textDeathCounterCurrentList[i]
        current.visible = true
        current.alpha = 0
        current.x = text.x
        current:write(Save:get("game.deaths." .. v.tag:lower()) - 1)

        self:tween(current, .5, { alpha = 1 }):delay(1.3)
    end

    self:tween(self.textDeathCounterWord, .5, { alpha = 1 }):delay(1.3)
    self:tween(self.textTip, .5, { alpha = 1 }):delay(1.3)
    self:tween(.5, { backgroundAlpha = 1 })

    local level = self.scene.map:getCurrentLevel()
    local tipList = tips[level.id]
    if tipList then
        self.textTip:write("Tip: " .. _.pick(tipList))
    else
        self.textTip:write("")
    end
end

function DeathScreen:getFadeDelay()
    return 5
end

return DeathScreen
