local FlagManager = require "flagmanager"
local usernames = require "data.chat_usernames"
local websocket = require "libs.websocket"
local Sprite = require "base.sprite"
local FloorButton = require "interactables.floorbutton"
local Television = require "bosses.horsey.television"
local ElectricPlatform = require "bosses.horsey.electric_platform"
local SFX = require "base.sfx"
local Scene = require "base.scene"

local HorseyRoom = Scene:extend("HorseyRoom")

HorseyRoom.seen = set()

function HorseyRoom:new(x, y, mapLevel)
    HorseyRoom.super.new(self)
    self:setBackgroundAlpha(0)
    self.mapLevel = mapLevel
    self.x = x
    self.y = y

    self.batteryAmount = 0

    self.useFakeTimer = false
    self.switchToFakeTimerDelay = step.every(2)
    self.fakeMessageTimer = step.new(.05, 0.3)

    self.storedMessages = {}

    self.started = false

    self.batterySpeed = 10 -- How many seconds it takes to get the battery full

    self.SFX = {
        electricity = SFX("sfx/bosses/horsey/electricity")
    }
end

function HorseyRoom:done()
    self.background:add("hooibalen", 711, 370)
    self.background:add("hooiberg", 78, 343)
    self.background:add("hooibaal", 577, 444)
    self.background:add("plafond_slierten4", 94, 56)
    self.background:add("plafond_slierten1", 822, 56)
    self.background:add("bordje_schok", 463, 331)

    self.television = self.mapLevel:add(Television(self.x, self.y), true)

    self.electricPlatforms = list()
    for i = 0, 6 do
        if i ~= 3 then
            self.electricPlatforms:add(
                self.mapLevel:add(
                    ElectricPlatform(self.x + 63 + 119 * i, self.y + 472),
                    true
                )
            )
        end
    end

    local floorButton = self.scene:findEntityWithTag("FloorButton")
    floorButton.connections = {}
    floorButton.changeState = function(fb, state)
        self.batteryButtonPressed = state
        FloorButton.changeState(fb, state)
    end

    floorButton.addedToLineDrawer = true

    self.horsey = self.scene:findEntityWithTag("Horsey")
    self.horsey.roomManager = self
    self.horseyHealth = 3

    if FlagManager:get(Enums.Flag.defeatedHorsey) then
        self:initializeRevisit()
    else
        self.scene:onInitializingBoss()

        if FlagManager:get(Enums.Flag.cutsceneHorseyIntro) then
            self:initializeRestart()
        else
            self:initializeCutscene()
        end
    end

    if LEKKER_SPELEN then
        self:connectWithChat()
    else
        self.useFakeTimer = true
    end
end

function HorseyRoom:update(dt)
    if self.started and not self.horseyDefeated then
        if not self.electricityTurnedOn then
            if self.batteryButtonPressed then
                self.batteryAmount = self.batteryAmount + dt * (100 / self.batterySpeed)
                if self.batteryAmount > 100 then
                    self.batteryAmount = 100
                    self:turnOnElectricity()
                end
                self.television.batteryFill.height = self.television.batteryFill.defaultHeight *
                    (self.batteryAmount / 100)
                self.television.batteryText:write(math.floor(self.batteryAmount) .. "%")
            end
        end


        if self.switchToFakeTimerDelay(dt) then
            self.useFakeTimer = true
        end

        if self.useFakeTimer then
            if self.fakeMessageTimer(dt) then
                self:createFakeMessage()
            end
        end

        if self.client then
            self.client:update(dt)
        end

        if self.horsey:isReadyForNextDirection(dt) then
            self:pickMessage()
        end
    end

    HorseyRoom.super.update(self, dt)
end

function HorseyRoom:turnOnElectricity()
    if self.horsey and not self.horsey.defeated then
        self.SFX.electricity:play()
    end

    self.electricityTurnedOn = true
    self.electricPlatforms:turnOn()
    self:tween(1.5, { batteryAmount = 0 })
        :ease("cubicin")
        :delay(.5)
        :onupdate(function()
            self.television.batteryFill.height = self.television.batteryFill.defaultHeight * (self.batteryAmount / 100)
            self.television.batteryText:write(math.floor(self.batteryAmount) .. "%")
        end)
        :oncomplete(function()
            self.electricityTurnedOn = false
            self.electricPlatforms:stop()
            self.horsey:electrifyStop()
            local players = self.scene:getPlayers()
            players:electrifyStop()
        end)
end

function HorseyRoom:connectWithChat()
    ---@diagnostic disable-next-line: missing-parameter
    self.client = websocket.new(SERVER_IP, 8082)

    ---@diagnostic disable-next-line: duplicate-set-field
    self.client.onmessage = function(c, message)
        local data = json.decode(message)
        local direction = self:extractDirectionFromMessage(data.message)
        if not direction then
            return
        end

        self:addMessage(data.user, direction, data.subscriber + 1)

        self.useFakeTimer = false
        self.switchToFakeTimerDelay()
    end

    ---@diagnostic disable-next-line: duplicate-set-field
    self.client.onerror = function()
        self.client:close()
        self.client = nil
        self.useFakeTimer = true
    end
end

function HorseyRoom:extractDirectionFromMessage(message)
    if message:startsWith("left") or message:startsWith("lekkerLeft") then
        return "left"
    elseif message:startsWith("right") or message:startsWith("lekkerRight") then
        return "right"
    elseif message:startsWith("up") or message:startsWith("lekkerUp") then
        return "up"
    end

    return false
end

function HorseyRoom:createFakeMessage()
    local name = _.weightedchoice(usernames)
    local direction = _.pick({ "left", "right", "up" })
    self:addMessage(name, direction)
end

function HorseyRoom:addMessage(name, direction, subscriber)
    self.television:addDirection(name, direction)

    if HorseyRoom.seen:has(name) then
        return
    end

    if not self.horsey:canAcceptDirection(direction) then
        return
    end

    HorseyRoom.seen:add(name)
    self.storedMessages[name] = { direction = direction, value = subscriber or 1 }

    if HorseyRoom.seen:size() > 50 then
        HorseyRoom.seen:remove(HorseyRoom.seen:get(1))
    end
end

function HorseyRoom:pickMessage()
    if _.count(self.storedMessages) == 0 then
        return
    end

    local messages
    local data = self.horsey:getPreferredDirectionData()

    repeat
        local direction = _.weightedchoice(data)
        messages = _.filter(self.storedMessages, function(e) return e.direction == direction end, true)
    until not _.empty(messages)

    local weights = {}
    for k, v in pairs(messages) do
        weights[k] = v.value
    end

    local name = _.weightedchoice(weights)

    local direction = messages[name].direction

    self.television:showPickedDirection(name, direction)
    self.horsey:onDirection(direction)
    self.storedMessages = {}
end

function HorseyRoom:onHorseyLanding()
    self.scene:shake(5, .5)

    local clones = self.scene:findEntitiesWithTag("Clone")
    clones:kill()

    local peter = self.scene.peter
    local timon = self.scene.timon

    if not peter or not timon then
        return
    end

    if peter:isOnGround(true) then
        peter:stun(2)
    end

    if timon:isOnGround(true) then
        timon:stun(2)
    end
end

function HorseyRoom:onHorseyElectrifiedDone()
    self.horseyHealth = self.horseyHealth - 1
    if self.horseyHealth == 2 then
        self.electricPlatforms[2].standby = false
        self.electricPlatforms[5].standby = false
    elseif self.horseyHealth == 1 then
        self.electricPlatforms:foreach(function(p)
            p.standby = false
        end)
        self.electricPlatforms[2].standby = true
        self.electricPlatforms[5].standby = true
    else
        self.electricPlatforms:foreach(function(p)
            p.standby = false
        end)
    end

    self.television:updateHorseyHealth(self.horseyHealth)

    if self.horseyHealth == 0 then
        self:onHorseyNoHealth()
    end
end

function HorseyRoom:onHorseyNoHealth()
    self.horsey:die()
    self.television:onHorseyDead()
    self.scene.music:stop(2, true)
    self:delay(1, function()
        FlagManager:set(Enums.Flag.defeatedHorsey, true)
        self.scene:startCutscene("horsey_defeat")
    end)
end

function HorseyRoom:onEndCutscene()
    self:delay(1, function()
        self.started = true
    end)
end

function HorseyRoom:initializeRestart()
    self.scene.noDoorAccess = true

    self:delay(1, function()
        self.started = true
    end)

    self.horsey.flip.x = true

    self.scene.music:play("bosses/horsey/theme", nil, true)
end

function HorseyRoom:initializeCutscene()
    self:delay(2, function()
        self.scene.noDoorAccess = true
    end)
end

function HorseyRoom:initializeRevisit()
    self.horsey:destroy()
    self.television:onHorseyDead()
end

function HorseyRoom:destroy()
    if self.client then
        self.client:close()
    end
    HorseyRoom.super.destroy(self)
end

return HorseyRoom
