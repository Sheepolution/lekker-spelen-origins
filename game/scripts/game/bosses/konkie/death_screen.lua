local Konkie = require "bosses.konkie.konkie"
local Text = require "base.text"
local Sprite = require "base.sprite"
local Scene = require "base.scene"
local Save = require "base.save"

local DeathScreen = Scene:extend("DeathScreen")

local quotes = {
    [Konkie.MS.Fists] = {
        "Dit is pas een vuistgevecht",
        "Platinum? Ik sla jullie plat!",
        "Dat was een wereldrecord voor slechtste poging!",
    },
    [Konkie.MS.QuestionMarks] = {
        "Waarom staan alle letters ondersteboven?!",
        "Waar zijn de plaatjes?!",
        "Ik hoef niet te kunnen lezen om jullie een lesje te leren!",
    },
    [Konkie.MS.Barrels] = {
        "Niet aan die bananen zitten!",
        "Jullie zijn misschien geen loodgieters, maar leggen wel dat loodje!",
        "Die dingen wegen een ton!",
    },
}

function DeathScreen:new()
    DeathScreen.super.new(self, 0, 0, 433, 489)
    self:setBackgroundImage("bosses/konkie/deathscreen")
    self:setBackgroundAlpha(0)
    self:center(WIDTH / 2, HEIGHT / 2)

    self.timon = self:addOverlay(Sprite(21, 290, "bosses/konkie/timon", true))
    self.peter = self:addOverlay(Sprite(1, 332, "bosses/konkie/peter", true))
    self.peter.z = -1

    self.peterEndX = 289
    self.timonEndX = 288

    self.bars = self:addOverlay(Sprite(0, 342, "bosses/konkie/deathscreen_bars"))
    self.bars.z = -1

    self.angle = -1
    self.alpha = 0
    self.visible = false

    self.quote = self:addOverlay(Text(214, 243, "Niet aan die bananen zitten!"))
    self.peterDeathCounter = self:addOverlay(Text(104, 411, "Peter deaths\n32"))
    self.timonDeathCounter = self:addOverlay(Text(319, 411, "Timon deaths\n43"))

    self.texts = list({ self.quote, self.peterDeathCounter, self.timonDeathCounter })
    self.texts:setColor(0, 0, 0)
    self.texts:setFont('cutive', 17, nil)
    self.texts:setAlign("center", 300)

    self:setFilter("linear", "linear")

    self.dyingPlayers = list()
end

function DeathScreen:update(dt)
    self.dyingPlayers:update(dt)
    DeathScreen.super.update(self, dt)
end

function DeathScreen:onPlayerDying(player1, player2)
    local konkie = self.scene:findEntityWithTag("Konkie")
    local ratio = (konkie.healthMax - konkie.health) / konkie.healthMax

    local x_peter = self.peter.x + (self.peterEndX - self.peter.x) * ratio
    local x_timon = self.timon.x + (self.timonEndX - self.timon.x) * ratio

    self.quote:write('"' .. _.pick(quotes[konkie.lastMS]) .. '"')

    self.visible = true
    self.angle = -1
    self.alpha = 0

    self:tween(self, .3, { angle = -.06, alpha = 1 })
        :onstart(function()
            self:tween(self.peter, 2, { x = x_peter })
            self:tween(self.timon, 2, { x = x_timon })
        end)

    self.dyingPlayers:clear()
    self.dyingPlayers:add(player1)

    if player2 then
        self.dyingPlayers:add(player2)
    end

    self.dyingPlayers:die()

    local deaths = Save:get("game.deaths")

    self.peterDeathCounter:write("Peter deaths\n" .. deaths.peter)
    self.timonDeathCounter:write("Timon deaths\n" .. deaths.timon)
end

function DeathScreen:getFadeDelay()
    return 5
end

return DeathScreen
