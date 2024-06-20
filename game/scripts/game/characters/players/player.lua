local Direction = Enums.Direction
local MapUtils = require "base.map.maputils"
local Clone = require "objects.clone"
local Interactable = require "interactables.interactable"
local Input = require "base.input"
local Enum = require "libs.enum"
local StateManager = require "base.statemanager"
local Sprite = require "base.sprite"
local Laser = require "projectiles.laser"
local Point = require "base.point"
local Save = require "base.save"
local SFX = require "base.sfx"
local Entity = require "base.entity"

local Player = Entity:extend("Player")

local PositionState = Enum(
    "Ground",
    "Air",
    "Water"
)

local PS = PositionState

local MovementState = Enum(
    "Idle", "Confused", "Crouch",
    "Push", "Walk", "Run",
    "Crawl", "Standup", "Fall",
    "Jump", "Electric",
    "Sniff", "Die", "Ball", "Swim"
)

local MS = MovementState

Player.PS = PS
Player.MS = MS

local Ability = Enum(
    "Teleport",
    "Clone",
    "Shoot",
    "Light"
)

Player.Ability = Ability

Player.SFX = {
    sniff = SFX("sfx/players/sniff"),
    bark = SFX("sfx/players/bark"),
    squeak = SFX("sfx/players/squeak"),
    teleport_in = SFX("sfx/players/teleport_in", 1),
    teleport_out = SFX("sfx/players/teleport_out", 1),
    teleporter_peter = SFX("sfx/players/teleport_peter"),
    teleporter_timon = SFX("sfx/players/teleport_timon"),
    hurt_peter = SFX("sfx/players/hurt_peter"),
    hurt_timon = SFX("sfx/players/hurt_timon"),
    flashlight = SFX("sfx/players/flashlight"),
    laser_peter = SFX("sfx/players/shoot_peter", 4, { pitchRange = .04 }),
    laser_timon = SFX("sfx/players/shoot_timon", 4, { pitchRange = .04 }),
}

Player.keys = {
    {
        left = { "c1_left_left" },
        right = { "c1_left_right" },
        down = { "c1_left_down", "c1_leftstick", "c1_leftshoulder" },
        up = { "c1_left_up" },
        jump = { "c1_a" },
        run = { "c1_x", "c1_triggerleft" },
        ability = { "c1_b", "c1_triggerright" },
        interact = { "c1_y" },
        sniff = { "c1_rightstick" },
        standstill = { "c1_rightshoulder" },
        menu = { "c1_start" },
        confirm = { "c1_a" },
        back = { "c1_back" }
    },
    {
        left = { "left", "c2_left_left" },
        right = { "right", "c2_left_right" },
        down = { "down", "c2_left_down", "c2_leftstick", "c2_leftshoulder" },
        up = { "up", "c2_left_up" },
        jump = { "z", "s", "c2_a" },
        run = { "a", "x", "c2_x", "c2_triggerleft" },
        ability = { "space", "c2_b", "c2_triggerright" },
        interact = { "e", "d", "c2_y" },
        sniff = { "f", "c2_rightstick" },
        standstill = { "lctrl", "c2_rightshoulder" },
        menu = { "escape", "c2_start" },
        confirm = { "space", "c2_a" },
        back = { "backspace", "c2_back" }
    }
}

if DEBUG then
    Player.keys = {
        {
            left = { "left", "c1_left_left" },
            right = { "right", "c1_left_right" },
            down = { "down", "c1_left_down", "c1_leftstick", "c1_leftshoulder" },
            up = { "up", "c1_left_up" },
            jump = { "up", "c1_a" },
            run = { "space", "c1_x", "c1_triggerleft" },
            ability = { "rshift", "c1_b", "c1_triggerright" },
            interact = { "\\", "c1_y" },
            sniff = { "r", "c1_rightstick" },
            standstill = { "o", "c1_rightshoulder" },
            menu = { "escape", "c1_start" },
            confirm = { "space", "c1_a" },
            back = { "backspace", "c1_back" }
        },
        {
            left = { "a", "c2_left_left" },
            right = { "d", "c2_left_right" },
            down = { "s", "c2_left_down", "c2_leftstick", "c2_leftshoulder" },
            up = { "w", "c2_left_up" },
            jump = { "w", "c2_a" },
            run = { "lshift", "c2_x", "c2_triggerleft" },
            ability = { "e", "c2_b", "c2_triggerright" },
            interact = { "t", "c2_y" },
            sniff = { "r", "c2_rightstick" },
            standstill = { "y", "c2_rightshoulder" },
            menu = { "c2_start" },
            confirm = { "c2_a" },
            back = { "o", "c2_back" }
        }
    }
end

function Player:new(...)
    Player.super.new(self, ...)
    self.touchedGround = true
    self.gravity = 1000
    self.playerEntity = true

    self.controllerId = 1

    self.movementLocked = false

    self.canStand = true
    self.canCrouch = true

    self.jumpsMax = 1
    self.jumps = self.jumpsMax
    self.jumpBuffered = false
    self.jumpSpringPower = 670

    self.jumpPreTimer = step.during(.1)
    self.jumpPreTimer:finish()

    self.jumpPostTimer = step.during(.1)
    self.jumpPostTimer:finish()

    self.inControl = true
    self.inCutscene = false

    self.looking = false
    self.hugging = false

    self.permanentSafePosition = Point()
    self.lastSafePositions = list()
    self.safePositionTimer = step.every(1)
    self.touchedUnsafeEntity = false

    self.health = Save:get("game.health." .. self.tag:lower() .. ".current")
    self.healthMax = Save:get("game.health." .. self.tag:lower() .. ".max")
    self.hurtTimer = step.during(2.5)
    self.hurtTimer:finish()
    self.hurtable = true

    self.bubbleCreateTimer = step.every(1, 5)

    self.lightSourceRadius = 80

    self.indicator = Sprite(0, 0, "characters/players/indicator", true)
    self.indicator.visible = false

    self.abilityHoldable = {
        [Ability.Teleport] = false,
        [Ability.Clone] = false,
        [Ability.Shoot] = true
    }

    -- FINAL: Turn off
    -- self.ability = Ability.Teleport

    if not DEBUG then
        self.ability = nil
    end

    -- Teleporting
    self.teleporting = false
    self.teleportSpeed = .4
    self.teleportSidekickPossible = {
        left = false,
        right = false
    }

    self.teleportEffect = {
        color = { 1, 1, 1 },
        alpha = 0,
        timer = step.new(.03),
        canvas = love.graphics.newCanvas(200, 200),
        trail = {},
        maxTrails = 10
    }

    self.teleportKeyPressed = false
    self.wantToDoubleSwitchTimer = step.after(.1)
    self.teleportedJustNowTimer = step.during(.1)
    self.teleportCooldown = step.after(.1)

    -- Cloning
    self.clone = nil
    self.cloneCooldown = step.during(1)
    self.standingOnClone = false

    -- Laser shooting
    self.laserShootDelay = step.after(.2)

    -- Flashlight
    self.flashlightRadius = 150

    self.floorButtonPresser = true

    self.mapUnloadProtection = MapUtils.ProtectionLevel.Strong

    -- [States]
    self.SM = StateManager(self, { MS, PS })

    self.SM:configure(MS.Idle, { [PS.Ground] = true })
    self.SM:configure(MS.Crouch, { [PS.Ground] = true })
    self.SM:configure(MS.Crawl, { [PS.Ground] = true })
    self.SM:configure(MS.Sniff, { [PS.Ground] = true, [PS.Water] = true })

    self.SM:to(PS.Ground)
    self.SM:to(MS.Idle)
    self.entityIndex = 0
end

function Player:postNew()
    Player.super.postNew(self)
    local animation_standup = self.anim:getAnimation("standup", true)
    if animation_standup then
        animation_standup:onComplete(function()
            self.SM:unlock(MS.Standup)
            self.SM:to(MS.Idle)
        end)
    end

    self:switchToHitbox("stand")
end

function Player:done()
    Player.super.done(self)
    self.lightSource = self.scene:addLightSource(self, self.lightSourceRadius)

    if self.scene.inWater then
        self:goIntoWater()
    end

    self.entityIndex = self.scene.entities:indexOf(self)
    if not self.entityIndex or self.entityIndex == 0 then
        self.entityIndex = self.__id
    end
end

function Player:update(dt)
    self.controllerId = Save:get("settings.controls." .. self.tag:lower() .. ".player1") and 1 or 2

    if self.sidekick and self.entityIndex < self.sidekick.entityIndex then
        if self.wantToTeleport then
            if self.wantToTeleport == "double_switch" then
                if self:canTeleportOther() and self.sidekick:canTeleportOther() then
                    self:actuallyDoubleSwitch()
                end
            elseif self.wantToTeleport == "other" then
                self:teleportOther()
            end
        elseif self.sidekick.wantToTeleport then
            if self.sidekick.wantToTeleport == "double_switch" then
                if self:canTeleportOther() and self.sidekick:canTeleportOther() then
                    self:actuallyDoubleSwitch()
                end
            elseif self.sidekick.wantToTeleport == "other" then
                self.sidekick:teleportOther()
            end
        end
        self.wantToTeleport = nil
        self.sidekick.wantToTeleport = nil
    end

    if not self.teleporting and not self.died then
        if not self.touchedGround and self.SM:is(PS.Ground) then
            self:fall()
        end
    end

    if self.SM:is(PS.Air) or self.SM:is(MS.Crouch) then
        if Input:isPressed(self.keys[self.controllerId].jump) then
            self.jumpPreTimer()
        end

        self.jumpPreTimer(dt)
        self.jumpPostTimer(dt)
    else
        self.jumpPostTimer()
    end

    self:handleInput(dt)

    if self.movementDirection then
        self:handleMovement()
    end

    self:handleSafePosition(dt)
    self:handleCutscene(dt)

    self.SM:update(dt)

    self:handleTeleportation(dt)

    if self:canMove() and self.lastInputDirection == nil then
        if not self.SM:is(PS.Water) then
            self:stopMoving("x")
        end
    end

    if self.SM:is(PS.Ground) and self.inputHoldingStandstill then
        self.SM:to(MS.Idle, nil, true)
        self:stopMoving("x")
        self:handleStandstill()
        if self.lastInputDirection == Direction.Left then
            self.flip.x = true
        elseif self.lastInputDirection == Direction.Right then
            self.flip.x = false
        end
    end

    if not self:isMoving("x") and not self.movementDirection then
        self:handleStandstill()
    end

    if self.barrel then
        self:updateBarrelPosition()
    end

    self:handleHitboxChanging()

    Player.super.update(self, dt)

    self.lightSource:center(self:getDrawCoordinates(true))

    if self.flashlight then
        self.flashlight:center(self:getDrawCoordinates(true))
    end

    self:handleHolding()

    self:handleCutscenePostUpdate(dt)

    if self.hurting then
        if not self.hurtTimer(dt) then
            self.hurting = false
        end
    end

    self.indicator:update(dt)

    local level = self.scene.map:getCurrentLevel()
    if self.y > level:bottom() then
        self:hurt(nil, true)
    end

    self.touchedGround = false
    self.pushing = false
    self.canStand = true
    self.touchedUnsafeEntity = false
    self.teleporterJustUsed = nil

    -- if not self.sidekick or not self.teleportKeyPressed or (not self.sidekick.teleportKeyPressed and not Input:isPressed(Player.keys[self.sidekick.controllerId].ability)) then
    -- if not self.sidekick then
    self.teleportSidekickPossible.left = true
    self.teleportSidekickPossible.right = true
    -- end
end

function Player:draw()
    if self.barrel then return end
    local anim = self.SM:get(MS):lower()

    if not self.teleporting then
        if self.holdingItem then
            local old_anim = anim
            anim = anim .. "_hold"
            self.holdingItem.visible = true

            if not self.anim:has(anim) then
                anim = old_anim
                self.holdingItem.visible = false
            end
        elseif self.looking then
            local old_anim = anim
            anim = anim .. "_look"

            if not self.anim:has(anim) then
                anim = old_anim
            end
        elseif self.hugging then
            anim = "hug"
        end

        if self.SM:is(PS.Water) and not self.SM:is(MS.Die) then
            anim = "swim"
            if self.holdingItem then
                self.holdingItem.visible = true
            end
        end

        self.anim:set(anim)
    end

    Player.super.draw(self)

    self:drawTeleportationEffect()

    self.indicator:drawAsChild(self)
end

function Player:drawTeleportationEffect()
    if not self.teleporting then return end

    if self.teleportEffect.lines then
        love.graphics.push()
        love.graphics.translate(self.x, self.y)
        love.graphics.setLineWidth(1)
        love.graphics.setLineStyle("rough")
        love.graphics.setColor(178 / 255, 1, 1, 1 - self.alpha)
        for i, v in ipairs(self.teleportEffect.lines) do
            love.graphics.line(v)
        end
        love.graphics.pop()
    elseif self.teleportEffect.trail then
        for i, v in ipairs(self.teleportEffect.trail) do
            local r, g, b = unpack(self.teleportEffect.color)
            love.graphics.setColor(r, g, b, v.alpha)
            love.graphics.draw(self.teleportEffect.canvas, v.x, v.y)
        end
    end
end

function Player:onOverlap(i)
    if self.teleporting then
        return false
    end

    if i.myHitbox == self.hitboxTeleportLeft or i.myHitbox == self.hitboxTeleportRight then
        -- NOTE: Need testing
        -- if i.e.unsafeForPlayer then
        --     self.touchedUnsafeEntity = true
        -- end

        if i.e.solid == 2 and i.theirHitbox.solid then
            if not (i.e.tile and i.e.enum == "Platform") then
                if i.myHitbox == self.hitboxTeleportLeft then
                    self.teleportSidekickPossible.left = false
                elseif i.myHitbox == self.hitboxTeleportRight then
                    self.teleportSidekickPossible.right = false
                end
            end
        end
        return false
    end

    if i.myHitbox == self.hitboxBlockPush then
        if self.canPush and i.e.pushable and self.SM:is(PS.Ground) and self:isLookingAt(i.e) then
            if not i.myTop and not i.myBottom then
                self.pushing = true
                if not i.myHitbox:overlaps(i.theirHitbox, true) then
                    return Player.super.onOverlap(self, i)
                end
            end
        end
        return false
    end

    if i.myHitbox == self.hurtboxMain then
        if i.e.jumpable then
            if i.hisTop then
                self.SM:to(MS.Jump, false, true)
                i.e:onJumpedOn()
                return
            end
        end

        if i.e.hurtsPlayer then
            if not i.e.damageBox or i.theirHitbox == i.e.damageBox then
                self:onOverlapEnemy(i)
                if self.hurting then
                    return false
                end
            end
        end
    end

    if i.myHitbox == self.hitboxMain then
        if i.e:is(Clone) then
            return self:onOverlapClone(i)
        end

        if i.e.tile then
            if i.myLeft or i.myRight then
                if i.myHitbox.bb.bottom - i.theirHitbox.bb.top < 1 then
                    return false
                end
            end

            if i.e.enum == "Platform" then
                if not i.myBottom then
                    return false
                end

                if self.inputHoldingDown or self.SM:is(MS.Crawl) or self.SM:is(MS.Crouch) then
                    if Input:isPressed(self.keys[self.controllerId].jump, self.keys[self.controllerId].interact) then
                        return false
                    end
                end
            end
        end

        if (i.e:is(Interactable) and i.e:isInputInteractable()) then
            if self:canMove() then
                if Input:isPressed(self.keys[self.controllerId].interact) then
                    i.e:onInteract(self)
                end
            end
        end

        if i.e.tag == "Spring" then
            return self:onOverlapSpring(i.e)
        end

        if i.e.tag == "Water" then
            -- self.scene:startWaterTransition(self)
        end
    else
        if i.e.tile then
            if self:usesLowerHitbox() and i.e.enum ~= "Platform" then
                if i.myHitbox:centerY() > i.theirHitbox:bottom() then
                    if i.myHitbox:overlaps(i.theirHitbox, true) then
                        self.canStand = false
                    end
                end
            end
        end
    end

    return Player.super.onOverlap(self, i)
end

function Player:onOverlapEnemy(i)
    if i.e.tag == "Horsey" then
        self:onOverlapHorsey(i.e)
        return
    end

    if i.e.hurtsSide then
        if not i["his" .. _.title(i.e.hurtsSide)] then
            return
        end
    end

    self:onTouchingHurtingEntity(i.e)
end

function Player:onOverlapHorsey(e)
    if self.SM:is(MS.Crouch) or self.SM:is(MS.Crawl) then
        return
    end

    self:onTouchingHurtingEntity(e)
end

function Player:onOverlapClone(i)
    if not (i.myBottom or i.hisTop) then
        return false
    end

    if self.inputHoldingDown or self.SM:is(MS.Crawl) or self.SM:is(MS.Crouch) then
        if Input:isPressed(self.keys[self.controllerId].jump, self.keys[self.controllerId].interact) then
            return false
        end
    end

    return true
end

function Player:onOverlapSpring(e)
    if not e:isOn() then
        return
    end

    if self.SM:is(PS.Air) or e.triggered then
        if not e.triggered then
            e:onBeingUsed()
        end

        self.jumpPower = self.jumpSpringPower
        self.SM:to(MS.Jump, false, true)
        self.jumpPower = self.jumpPowerDefault
    end

    return false
end

function Player:separationCheck(i)
    if i.e.pushable then
        return self.SM:is(MS.Push) and 0 or -1
    end

    return 0
end

function Player:handleInput(dt)
    if self.barrel then
        if Input:isPressed(self.keys[self.controllerId].interact) or Input:isPressed(self.keys[self.controllerId].jump) then
            self.barrel:shoot()
            return
        end

        if Input:isDown(self.keys[self.controllerId].run) then
            self.speed = self.runSpeed
        else
            self.speed = self.defaultSpeed
        end
    end

    if not self:canMove() then
        return
    end

    if self.SM:is(PS.Water) then
        self:handleWaterInput()
        return
    end

    if Input:isPressed(self.keys[self.controllerId].back) then
        self:onWantToGoBack()
    elseif not Input:isDown(self.keys[self.controllerId].back) then
        if self.wantToGoBack then
            self.wantToGoBack = false
            self:hideIndicator()
        end
    end

    if self.ability == Ability.Teleport then
        if self.teleportCooldown(dt) then
            if Input:isPressed(self.keys[self.controllerId].ability) then
                self.teleportKeyPressed = true
            end
        end

        if self.teleportKeyPressed then
            if Input:isDown(self.keys[self.controllerId].ability) then
                if self.sidekick.wantToDoubleSwitch then
                    self:onWantingToDoubleSwitch()
                else
                    if self.wantToDoubleSwitchTimer(dt) then
                        self:onWantingToDoubleSwitch()
                    end
                end
            elseif Input:isReleased(self.keys[self.controllerId].ability) then
                self:useAbility()
                self:hideIndicator()
                self:onWantingToDoubleSwitchStop()
                self.teleportKeyPressed = false
            else
                -- Key was released when input was not active
                self:hideIndicator()
                self:onWantingToDoubleSwitchStop()
                self.teleportKeyPressed = false
            end
        end
    elseif self.ability == Ability.Shoot then
        if self.laserShootDelay(dt) then
            if Input:isDown(self.keys[self.controllerId].ability) then
                self:useAbility()
            end
        end
    else
        if (self.abilityHoldable[self.ability] and Input:isDown(self.keys[self.controllerId].ability)) or Input:isPressed(self.keys[self.controllerId].ability) then
            self:useAbility()
        end
    end

    if self.canSniff then
        if Input:isPressed(self.keys[self.controllerId].sniff) then
            self.SM:to(MS.Sniff, true)
        elseif Input:isReleased(self.keys[self.controllerId].sniff) then
            if self.SM:is(MS.Sniff) then
                self.SM:unlock(MS.Sniff)
                self.SM:to(MS.Idle)
            end
        end
    end

    if Input:isPressed(self.keys[self.controllerId].down) then
        self.inputHoldingDown = true
    end

    if not Input:isDown(self.keys[self.controllerId].down) then
        self.inputHoldingDown = false
    end

    -- NOTE: If there is a bug with crouching: You changed this from isPressed to isDown.
    -- if not Input:isDown(self.keys[self.controllerId].down) then
    --     self.inputHoldingDown = true
    -- else
    --     self.inputHoldingDown = false
    -- end

    if Input:isDown(self.keys[self.controllerId].run) then
        self.inputHoldingRun = true
    else
        -- NOTE: If there is a bug with running, it's because you changed this from isReleased to else
        self.inputHoldingRun = false
    end

    if self.ability == Ability.Shoot then
        if Input:isPressed(self.keys[self.controllerId].standstill) then
            self.inputHoldingStandstill = true
        elseif Input:isReleased(self.keys[self.controllerId].standstill) then
            self.inputHoldingStandstill = false
        end
    elseif self.ability == Ability.Light then
        if Input:isDown(self.keys[self.controllerId].ability) then
            self:turnFlashlightOn()
        else
            self:turnFlashlightOff()
        end

        self:handleFlashlightInput(dt)
    end

    self.inputHoldingUp = Input:isDown(self.keys[self.controllerId].up)

    self:handleDirectionInput()

    self:jumpInput()
    self:crouchInput()
end

function Player:idleCheck()
    return (self.inCutscene or (not self.lastInputDirection and not self.inputHoldingDown)) and self.canStand
end

function Player:handleDirectionInput()
    if self.teleporting then return end

    if Input:isPressed(self.keys[self.controllerId].left) then
        self.lastInputDirection = Direction.Left
    elseif Input:isPressed(self.keys[self.controllerId].right) then
        self.lastInputDirection = Direction.Right
    end

    local left = Input:isDown(self.keys[self.controllerId].left)
    local right = Input:isDown(self.keys[self.controllerId].right)

    if left and right then
        left = self.lastInputDirection == Direction.Left
        right = self.lastInputDirection == Direction.Right
    end

    local dir
    if left then
        dir = Direction.Left
    elseif right then
        dir = Direction.Right
    end

    if not dir then
        self.lastInputDirection = nil

        if not self.movementLocked then
            self.movementDirection = nil
        end

        return
    end

    self.lastInputDirection = dir
    self.movementDirection = self.lastInputDirection
end

function Player:handleStandstill()
    if self.SM:is(PS.Water) then
        return
    end

    if self.inputHoldingDown or not self.canStand then
        self.SM:to(MS.Crouch)
    else
        self.SM:to(MS.Idle)
    end
end

function Player:handleMovement()
    if not self.SM:is(PS.Ground) then
        return
    end

    if self.pushing then
        self.SM:to(MS.Push)
    else
        if self.inputHoldingDown or not self.canStand then
            if self.canCrawl then
                if self.inputHoldingRun then
                    self.SM:to(MS.Run)
                else
                    self.SM:to(MS.Crawl)
                end
                return
            end
        end

        if not self.inputHoldingDown then
            if self.inputHoldingRun then
                self.SM:to(MS.Run)
            else
                self.SM:to(MS.Walk)
            end
        end
    end
end

function Player:handleWaterInput()
    self.accel:set(0, self.gravity)

    if Input:isDown(self.keys[self.controllerId].up) or Input:isDown(self.keys[self.controllerId].jump) then
        self.velocity.y = -self.swimSpeed.y
    end

    if Input:isDown(self.keys[self.controllerId].down) then
        self.accel.y = self.gravity * 1.5
    end

    if not self.SM:is(MS.Sniff) then
        self:handleDirectionInput()
    end

    if self.movementDirection == Direction.Left then
        self.accel.x = -self.swimSpeed.x
    end

    if self.movementDirection == Direction.Right then
        self.accel.x = self.swimSpeed.x
    end

    if Input:isPressed(self.keys[self.controllerId].back) then
        self:onWantToGoBack()
    elseif not Input:isDown(self.keys[self.controllerId].back) then
        if self.wantToGoBack then
            self.wantToGoBack = false
            self:hideIndicator()
        end
    end

    if self.canSniff then
        if Input:isPressed(self.keys[self.controllerId].sniff) then
            self.SM:unlock(MS.Swim)
            self.SM:to(MS.Sniff, true)
        elseif Input:isReleased(self.keys[self.controllerId].sniff) then
            if self.SM:is(MS.Sniff) then
                self.SM:unlock(MS.Sniff)
                self.SM:to(MS.Swim, true)
            end
        end
    end
end

function Player:walkCheck()
    return self.canStand
end

function Player:walkUpdate()
    self.speed = self.defaultSpeed
    self:moveHorizontally()
end

function Player:runUpdate()
    self.speed = self.runSpeed
    self:moveHorizontally()
end

function Player:pushUpdate()
    self.speed = self.pushSpeed
    self:moveHorizontally()
end

function Player:airUpdate()
    if not self.shotStraightFromBarrel then
        self:moveHorizontally()
    end
end

function Player:jumpInput()
    if Input:isPressed(self.keys[self.controllerId].jump) or self.jumpPreTimer(0) then
        self.SM:to(MS.Jump)
    end

    if self.velocity.y < 0 and self.SM:is(MS.Jump) then
        if Input:isReleased(self.keys[self.controllerId].jump) then
            self.velocity.y = self.velocity.y / 2
        end
    end
end

function Player:jumpCheck()
    if self:usesLowerHitbox() and not self.canStand then
        return false
    end

    if self.inputHoldingDown then
        return false
    end

    if self.jumps <= 0 then
        return false
    end

    if not self.SM:is(PS.Air) or self.jumpPostTimer(0) then
        return true
    end

    return false
end

function Player:jumpInit()
    self.jumps = self.jumps - 1
    self.velocity.y = -self.jumpPower
    self.SM:to(PS.Air)

    if self.pushing then
        self.speed = self.inputHoldingRun and self.runSpeed or self.defaultSpeed
        self.pushing = false
    end

    self.jumpPreTimer:finish()
    self.jumpPostTimer:finish()
end

function Player:jumpUpdate()
    if self.velocity.y >= 0 then
        self.SM:to(MS.Fall)
    end
end

function Player:restoreJumpCount()
    self.jumps = self.jumpsMax
end

function Player:crouchInput()
    if self.inputHoldingDown then
        if not self.canCrawl or (not self.SM:is(MS.Run) and not self.SM:is(MS.Crawl)) then
            self.SM:to(MS.Crouch)
        end
    end
end

function Player:crouchCheck()
    return self.canCrouch
end

function Player:crouchInit()
    self:stopMoving("x")
end

function Player:handleHitboxChanging()
    if self.SM:is(MS.Crouch) or self.SM:is(MS.Crawl) then
        self:switchToHitbox("crouch")
    elseif self.SM:is(MS.Jump) or self.SM:is(MS.Fall) then
        self:switchToHitbox("jump")
    elseif self.SM:is(PS.Water) then
        self:switchToHitbox("swim")
    elseif self.SM:is(MS.Run) then
        self:switchToHitbox("run")
    else
        self:switchToHitbox("stand")
    end
end

function Player:usesLowerHitbox()
    return self.hitboxMain == self.hitboxCrouch
end

function Player:crawlCheck()
    return self.canCrawl
end

function Player:crawlUpdate()
    self.speed = self.crawlSpeed
    self:moveHorizontally()
end

function Player:swimUpdate(dt)
    if self.bubbleCreateTimer(dt) then
        self:emit("bubble", self.flip.x and -40 or 40, 0, false)
    end
end

function Player:sniffInit()
    self.sniffRadius = 0
    if not self.SM:is(PS.Water) then
        self:stopMoving()
    end
    self.SFX.sniff:play("reverb")
end

function Player:sniffUpdate(dt)
    local growthFactor = 500
    local slowDownRate = 0.01

    self.sniffRadius = self.sniffRadius + (growthFactor / (1 + self.sniffRadius * slowDownRate)) * dt

    if self.sniffRadius > self.sniffRadiusMax then
        self.SM:unlock(MS.Sniff)
        if self.SM:is(PS.Water) then
            self.SM:to(MS.Swim, true)
        else
            self.SM:to(MS.Idle)
        end
        return
    end

    local x, y = self:getSniffPosition()

    local item, distance = self.scene:findNearestEntity({ x = x, y = y }, function(e)
        return e.sniffable and not e.pickedUp
    end)

    if item and distance < self.sniffRadius then
        self.SM:unlock(MS.Sniff)
        self.velocity.y = -200
        self:lookAt(item)
        local sound = self.SFX.bark:play("reverb")
        if self.SM:is(PS.Water) then
            self.SM:to(MS.Swim, true)
            if sound then
                sound:setFilter({ type = "lowpass", highgain = .2 })
            end
        else
            sound:setFilter()
        end
    end
end

function Player:getSniffPosition()
    return self:getRelativePosition(self.sniffOffset.x, self.sniffOffset.y)
end

function Player:handleCutscene(dt)
    if not self.inCutscene then
        return
    end
end

function Player:handleCutscenePostUpdate(dt)
    if not self.inCutscene then
        return
    end

    if self.movingToTarget then
        if self.movingToTargetLeft then
            if self:centerX() < self.movingToTarget then
                self:cutsceneStopWalking()
            end
        else
            if self:centerX() > self.movingToTarget then
                self:cutsceneStopWalking()
            end
        end
    end
end

function Player:cutsceneStopWalking()
    self:centerX(self.movingToTarget)
    self.movingToTarget = nil
    self:stopMoving("x")
    self.SM:to(MS.Idle)
    self.movementDirection = nil

    if self.movingToTargetCallback then
        self.movingToTargetCallback(self)
    end
end

function Player:handleSafePosition(dt)
    if self.touchedUnsafeEntity then
        return
    end

    if self.SM:is(PS.Air) then
        return
    end

    if self.standingOnClone then
        return
    end

    if #self.lastSafePositions > 0 then
        for i = #self.lastSafePositions, _.max(1, #self.lastSafePositions - 4), -1 do
            if self:getDistance(self.lastSafePositions[i]) < 50 then
                return
            end
        end
    end

    local x, y = self:center()

    self.lastSafePositions:add({ x = x, y = y })
    if #self.lastSafePositions > 100 then
        self.lastSafePositions:remove(1)
    end
end

function Player:clearSafePositions()
    self.lastSafePositions:clear()
end

function Player:onWantToGoBack()
    if not self.scene.checkpoint or self.scene.checkpoint.type ~= self.scene.CheckpointType.Reviver then
        return
    end

    local checkpoint_x = self.scene:getCheckpointX()

    if not checkpoint_x then return end

    if self.sidekick.wantToGoBack then
        self.scene:teleportPlayersBackToCheckpoint()
        self.wantToGoBack = false
        self:hideIndicator()
        self.sidekick.wantToGoBack = false
        self.sidekick:hideIndicator()
        return
    end

    self:showIndictatorBack()
    self.wantToGoBack = true
    local left = checkpoint_x < self:centerX()
    self.indicator.flip.x = left
end

function Player:teleportToLastSafePosition(e)
    if self.SM:is(MS.Ball) then
        self.SM:unlock(MS.Ball)
        self.SM:to(MS.Fall)
        self.useGravity = true
        self:removeAllMovement()
        self.shotStraightFromBarrel = false
    end

    if not self.SM:is(PS.Water) then
        self.SM:to(MS.Idle, nil, true)
    end

    self:removeAllMovement()

    local overlaps
    repeat
        local last = self.lastSafePositions:last() or self.permanentSafePosition
        self:center(last.x, last.y - 1)

        self:stopMoving()
        self.lastSafePositions:pop()
        self:teleport()
        if e then
            overlaps = self:overlaps(e, self.hitboxMain, e.hitbox)
        end
    until (not overlaps) or #self.lastSafePositions == 0

    if overlaps then
        if self.sidekick then
            self:centerX(self.sidekick:centerX())
            self:bottom(self.sidekick:bottom())
        end
    end
end

function Player:handleTeleportation(dt)
    if self.teleporting then
        for i, v in ipairs(self.teleportEffect.trail) do
            v.alpha = v.alpha - dt * 6
        end

        if self.teleportEffect.timer(dt) then
            table.insert(self.teleportEffect.trail, { x = self.x, y = self.y, alpha = 1 })
            if #self.teleportEffect.trail > self.teleportEffect.maxTrails then
                table.remove(self.teleportEffect.trail, 1)
            end
        end
    end
end

function Player:onSeparate(e, i)
    Player.super.onSeparate(self, e, i)

    local was_ball = false

    if self.SM:is(MS.Ball) then
        self.SM:unlock(MS.Ball)
        was_ball = true
        self.SM:to(MS.Fall)
        self.useGravity = true
        self:removeAllMovement()
    end

    self.shotStraightFromBarrel = false

    local distanceX = _.abs(self.x - self.last.x)
    local distanceY = _.abs(self.y - self.last.y)

    if not was_ball and (distanceX > 10 or distanceY > 30) then
        if self.lastSafePositions:last() then
            self:teleportToLastSafePosition(e)
        end
    end

    if i.myBottom then
        self.standingOnClone = i.e:is(Clone)

        if not self:is(PS.Ground) then
            self:onGrounding()
        else
            self.touchedGround = true
        end
    end
end

function Player:moveHorizontally()
    if self.movementDirection == Direction.Left then
        if self.drunk then
            self:moveRight()
        else
            self:moveLeft()
        end
    elseif self.movementDirection == Direction.Right then
        if self.drunk then
            self:moveLeft()
        else
            self:moveRight()
        end
    else
        self.velocity.x = 0
    end
end

function Player:stun(duration)
    self.inputHoldingDown = false
    self.lastInputDirection = nil
    self.movementDirection = nil
    self:stopMoving()
    self:shake(3, .3)
    self.stunned = true
    Input:rumble(self.controllerId, .35, .3)

    if duration then
        if self.stunRemoveDelay then
            self.stunRemoveDelay:stop()
        end

        self.stunRemoveDelay = self:delay(duration, function()
            self.stunned = false
            self.stunRemoveDelay = nil
        end)
    end

    self.SM:to(MS.Idle)
end

function Player:stunStop()
    if self.stunRemoveDelay then
        self.stunRemoveDelay:stop()
    end

    self.stunRemoveDelay = nil
    self.stunned = false

    self.SM:to(MS.Idle)
end

function Player:electrify()
    if self.SM:is(MS.Electric) then
        return
    end

    self:stun()
    self.SM:to(MS.Electric, true)
end

function Player:electrifyStop()
    if not self.SM:is(MS.Electric) then return end

    self:hurt()
    self:stunStop()
    self.SM:unlock(MS.Electric)
    self.SM:to(MS.Idle)
end

function Player:isElectrified()
    return self.SM:is(MS.Electric)
end

function Player:fall()
    self.SM:to(PS.Air)
    self.SM:to(MS.Fall)
end

function Player:onGrounding()
    self.SM:to(PS.Ground)
    self.touchedGround = true
    self:restoreJumpCount()
end

function Player:isOnGround(noClone)
    return self.SM:is(PS.Ground) and (not noClone or not self.standingOnClone)
end

function Player:isRunning()
    return self.SM:is(MS.Run)
end

function Player:canMove()
    return not self.inCutscene and
        self.inControl and
        not self.teleporting and
        not self.movementLocked and
        not self.stunned and
        not self.barrel and
        not self.shotStraightFromBarrel
end

function Player:goIntoCutscene()
    self:stopMoving("x")
    self.movementDirection = nil
    self.inputHoldingDown = false
    self.movingToTarget = nil
    self.inCutscene = true
    if self.flashlight then
        self.flashlight.visible = false
    end
    self:onWantingToDoubleSwitchStop()
end

function Player:goOutOfCutscene()
    self.inCutscene = false
end

function Player:cutsceneWalkTo(x, relative, callback, run)
    if not self.inCutscene then
        return
    end

    if relative then
        x = self:centerX() + x
    end

    self.movingToTarget = x
    self.movingToTargetLeft = x < self:centerX()
    self.movementDirection = self.movingToTargetLeft and Direction.Left or Direction.Right
    self.movingToTargetCallback = callback
    self.inputHoldingRun = run
end

function Player:cutsceneIdle()
    self.SM:to(MS.Idle, false, true)
end

function Player:switchToHitbox(name)
    if self.hitboxMain.name == name then
        return
    end

    for k, v in pairs(self.hitboxes) do
        if k ~= name then
            v.solid = false
        end
    end

    self.hitboxes[name].solid = true
    self.hitboxMain = self.hitboxes[name]
    self.hurtboxMain = self.hitboxMain
end

function Player:becomeConfused()
    self.SM:to(MS.Confused, true)
end

function Player:stopBeingConfused()
    self.SM:unlock(MS.Confused)
    self.SM:to(MS.Idle)
end

function Player:holdItem(e)
    self.holdingItem = e
end

function Player:releaseItem()
    self.holdingItem = nil
end

function Player:destroyHoldingItem()
    if not self.holdingItem then return end
    self.holdingItem:destroy()
    self.holdingItem = nil
end

function Player:handleHolding()
    if self.holdingItem then
        if self.holdingItem.destroyed then
            self:releaseItem()
        end
    end
end

function Player:onTouchingHurtingEntity(e)
    self.touchedUnsafeEntity = true
    self:hurt(e, e.teleportsPlayer)
    return not e.teleportsPlayer
end

function Player:hurt(e, teleport)
    if not self:canGetHurt() then
        if teleport and not self.died then
            self:teleportToLastSafePosition(e)
        end
        return
    end

    self.hurting = true
    self.hurtTimer()

    Input:rumble(self.controllerId, .25, .25)

    self:loseHealth()

    if self.health <= 0 then
        return
    end

    if e and e.hitsPlayerSFX then
        local sound = self.scene.sfx:play(e.hitsPlayerSFX)
        if sound then
            if self.scene.inWater then
                sound:setFilter({ type = "lowpass", highgain = .2 })
            else
                sound:setFilter()
            end
        end
    end

    local sound = self.SFX["hurt_" .. self.tag:lower()]:play("reverb")
    if sound then
        if self.scene.inWater then
            sound:setFilter({ type = "lowpass", highgain = .2 })
        else
            sound:setFilter()
        end
    end

    if teleport then
        self:teleportToLastSafePosition(e)
    end

    if self.hurtEvent then
        self.hurtEvent:stop()
    end

    self.hurtEvent = self:event(
        function()
            self.visible = not self.visible
            return not self.hurting
        end, .1, 23,
        function()
            self.visible = true
            self.hurtEvent = nil
        end)
end

function Player:loseHealth()
    self.health = self.health - 1

    self.scene:onPlayerChangingHealth(self, self.health)

    if self.health <= 0 then
        self.died = true
    end
end

function Player:increaseHealth(amount)
    local old_health = self.health
    self.health = _.min(self.healthMax, self.health + (amount or 1))
    if self.health ~= old_health then
        self.scene:onPlayerChangingHealth(self, self.health)
    end
end

function Player:die()
    if self.SM:is(MS.Die) then return end
    self:stopMoving()
    self.solid = 0
    self.useGravity = false
    self.movementDirection = nil
    self.lastInputDirection = nil
    self.accel.y = 0
    self.inControl = false
    self.inCutscene = true
    self.SM:to(MS.Die, true, true)
    self.barrel = false
    self.visible = true
    self.died = true
end

function Player:canGetHurt()
    return self.hurtable and not self.hurting and not self.electrified and not self.died
end

function Player:becomeDrunk()
    self.drunk = true
    if self.undrunkDelay then
        self.undrunkDelay:stop()
    end

    self.undrunkDelay = self:delay(3, function()
        self.drunk = false
        self.undrunkDelay = nil
    end)
end

function Player:setSidekick(sidekick)
    self.sidekick = sidekick
end

function Player:goIntoBarrel(barrel)
    self.SM:to(PS.Air)
    self.barrel = barrel
    local x, y = barrel:center()
    self:tween(.1, { x = x - self.width / 2, y = y - self.height / 2 - 10 })
    self.useGravity = false
    self.accel.y = 0
    self:stopMoving()
    self.lastInputDirection = nil
    self.movementDirection = nil
    self:removeAllMovement()
end

function Player:shootFromBarrel(barrel)
    if not barrel.on then
        self.barrel = nil
        self.useGravity = true
        return
    end

    local x, y = barrel:center()
    -- self.x = x - self.width / 2
    -- self.y = y - self.height / 2 - 10
    self:positionToAngleCenter(x, y, barrel.angle, 50)
    self.SM:to(MS.Ball, true)
    self.useGravity = not barrel.noGravity
    self.barrel = nil
    self.shotStraightFromBarrel = barrel.noGravity

    if not barrel.noGravity then
        local vx, vy = math.cos(barrel.angle), math.sin(barrel.angle)
        self:addMovement(Point(vx * 1000, vy * 1000), nil, Point(1000, 1000), nil, true)
    else
        self:moveToAngle(barrel.angle, 500)
    end
    -- if not barrel.noGravity then
    -- end
end

function Player:updateBarrelPosition()
    local x, y = self.barrel:center()
    self.x = x - self.width / 2
    self.y = y - self.height / 2 - 10
end

function Player:useAbility()
    if self.ability == Ability.Teleport then
        self.wantToTeleport = "other"
    elseif self.ability == Ability.Clone then
        self:createClone()
    elseif self.ability == Ability.Shoot then
        self:shootLaser()
    end
end

-- Teleporting

function Player:showIndictatorTeleport()
    self.indicator.anim:set("exclamation_" .. self.tag:lower())
    self.indicator.visible = true
    Input:rumble(self.sidekick.controllerId, .1, .2)
end

function Player:showIndictatorDenied()
    self.indicator.anim:set("cross_" .. self.tag:lower())
    self.indicator.visible = true
end

function Player:showIndictatorBack()
    self.indicator.anim:set("arrow_" .. self.tag:lower())
    self.indicator.visible = true
end

function Player:hideIndicator()
    self.indicator.visible = false
end

function Player:onWantingToDoubleSwitch()
    if not self:canTeleportOther() then
        self.wantToDoubleSwitch = false
        self:showIndictatorDenied()
        return
    end

    if self.sidekick and self.sidekick.wantToDoubleSwitch then
        self.wantToTeleport = "double_switch"
        return
    end

    self.wantToDoubleSwitch = true
    self:showIndictatorTeleport()
end

function Player:actuallyDoubleSwitch()
    self:teleportOther()
    self.sidekick:teleportOther()
    self:onWantingToDoubleSwitchStop()
    self.sidekick:onWantingToDoubleSwitchStop()
    self.teleportKeyPressed = false
    self.sidekick.teleportKeyPressed = false
    self.wantToTeleport = nil
end

function Player:onWantingToDoubleSwitchStop()
    self.wantToDoubleSwitch = false
    self:hideIndicator()
    self.wantToDoubleSwitchTimer()
end

function Player:canTeleportOther()
    return self.teleportSidekickPossible.left or self.teleportSidekickPossible.right
end

function Player:canBeTeleported()
    return not self.teleporting and not self.died
end

function Player:teleportOther()
    if not self:canTeleportOther() or not self.sidekick:canBeTeleported() then
        return
    end

    local x
    local y = self:bottom() - 1
    local left, right =
        self.teleportSidekickPossible.left,
        self.teleportSidekickPossible.right

    if self.flip.x then
        local temp = left
        left = right
        right = temp
    end

    if left and right then
        x = self.last:centerX()
    elseif left then
        x = self.last:left() + self.sidekick.width * .4
    else
        x = self.last:right() - self.sidekick.width * .4
    end

    if self.tag == "Peter" then
        self.SFX.teleporter_timon:play("reverb")
    else
        self.SFX.teleporter_peter:play("reverb")
    end

    self.sidekick:teleportTo(x, y)
    self.teleportCooldown()
end

local function isBorder(data, x, y, w, h)
    if x == 0 or y == 0 or x == w - 1 or y == h - 1 then
        return true
    end
    local curr = { data:getPixel(x, y) }
    if curr[1] == 0 and curr[2] == 0 and curr[3] == 0 then -- Check if the pixel is black.
        local directions = {
            { -1, 0 }, { 1, 0 }, { 0, -1 }, { 0, 1 }
        }

        for _, dir in ipairs(directions) do
            local nx, ny = x + dir[1], y + dir[2]
            if nx >= 0 and ny >= 0 and nx < w and ny < h then
                local neighbor = { data:getPixel(nx, ny) }
                if neighbor[4] == 0 then -- If neighbor is transparent.
                    return true
                end
            end
        end
    end

    return false
end

function Player:getOutlineDots(cx, cy, imageData, quad, offset)
    local x, y, w, h = quad:getViewport()
    local frame = love.image.newImageData(w, h)
    frame:paste(imageData, 0, 0, x, y, w, h)

    local dots = {}

    frame:mapPixel(function(x, y, r, g, b, a)
        if a == 0 then
            return r, g, b, a
        end

        if isBorder(frame, x, y, w, h) then
            table.insert(dots, cx + (offset and (offset - x) or x))
            table.insert(dots, cy + y)
        end

        return r, g, b, a
    end)

    return dots
end

function Player:getTeleportationLines(imageData, quad, offset)
    local vx, vy, w, h = quad:getViewport()
    local frame = love.image.newImageData(w, h)
    frame:paste(imageData, 0, 0, vx, vy, w, h)

    local y_min_max = {}

    frame:mapPixel(function(x, y, r, g, b, a)
        if a > 0 and x % 3 == 0 then -- Replace this condition with your own
            if not y_min_max[x] then
                y_min_max[x] = { min = y, max = y }
            else
                if y < y_min_max[x].min then y_min_max[x].min = y end
                if y > y_min_max[x].max then y_min_max[x].max = y end
            end
        end

        return r, g, b, a
    end)

    local lines = {}
    for x, minMax in pairs(y_min_max) do
        x = (offset and (offset - x) or x)
        table.insert(lines, { x, minMax.min, x, minMax.max })
    end

    return lines
end

function Player:teleportTo(cx, bottom)
    if not self:canBeTeleported() then
        return
    end

    self:teleportPrepare()

    self.indicator.visible = false

    self.jumps = 0

    local dots = self:getOutlineDots(0, 0, self.imageData,
        self._frames[self.anim._current.frames[self.anim.frame]], self.flip.x and self.width)

    love.graphics.push("all")
    love.graphics.setCanvas(self.teleportEffect.canvas)
    love.graphics.clear(0, 0, 0, 0)
    love.graphics.points(dots)
    love.graphics.pop()

    self:tween(self.teleportSpeed, { x = cx - self.width / 2, y = bottom - self.height })
        :oncomplete(function()
            self:tween(self.teleportEffect, .2, { alpha = 0 }):oncomplete(function()
                self.teleportEffect.dots = nil
            end)
            self:tween(.2, { alpha = 1 }):oncomplete(function()
                self:teleportFinish()
            end)
        end)
end

function Player:teleportPrepare()
    self:stopMoving()
    self.teleporting = true
    self.useGravity = false
    self.movementDirection = nil
    self.lastInputDirection = nil
    self.alpha = 0

    if self.SM:is(MS.Sniff) then
        self.SM:unlock(MS.Sniff)
        self.SM:to(MS.Idle)
    end
end

function Player:teleportFinish()
    self:stopMoving()
    self.teleporting = false
    self.useGravity = true
    self.teleportEffect.trail = {}
    -- self.teleportedJustNowTimer()

    if not self.SM:is(PS.Water) then
        self.SM:lock(MS[self.SM:get(MS)])
        self.SM:lock(PS[self.SM:get(PS)])
        self:delay(.1, function()
            self.SM:unlock(MS[self.SM:get(MS)])
            self.SM:unlock(PS[self.SM:get(PS)])
        end)
    end
end

function Player:teleportByPlatform(platform, platformTo)
    if not self:canBeTeleported() then
        return
    end

    self:teleportPrepare()

    local lines = self:getTeleportationLines(self.imageData,
        self._frames[self.anim._current.frames[self.anim.frame]], self.flip.x and self.width)

    self.teleportEffect.byPlatform = true
    self.teleportEffect.lines = lines

    self.alpha = 1

    self.SFX.teleport_in:play("reverb")

    for i, v in ipairs(lines) do
        local y1_start = v[2]
        local y2_start = v[4]
        self:tween(v, _.random(.1, .3), { [2] = self.height, [4] = self.height }):delay(.1)
            :after(_.random(.1, .3), { [2] = y1_start, [4] = y2_start }):delay(.5)
    end

    self:tween(.1, { alpha = 0, x = platform:centerX() - self.width / 2 })

    self:tween(self.teleportSpeed,
        {
            x = platformTo:centerX() - self.width / 2,
            y = platformTo:centerY() - self.height + 2 + (self.tag == "Peter" and 0 or -1)
        }):delay(.4)
        :oncomplete(function()
            self:teleport(self.x, self.y)
            self.SFX.teleport_out:play("reverb")
            self:tween(.2, { alpha = 1 }):oncomplete(function()
                self.teleportEffect.lines = nil
                self.teleportEffect.byPlatform = false
                self:teleportFinish()
            end):delay(.2)
        end)
end

function Player:teleportToCheckpoint(checkpoint, instant)
    if not self:canBeTeleported() then
        return
    end

    self:teleportPrepare()

    local lines = self:getTeleportationLines(self.imageData,
        self._frames[self.anim._current.frames[self.anim.frame]], self.flip.x and self.width)

    self.teleportEffect.byPlatform = true
    self.teleportEffect.lines = lines

    local appear = function()
        self:tween(.2, { alpha = 1 }):oncomplete(function()
            self.teleportEffect.lines = nil
            self.teleportEffect.byPlatform = false
            self:teleportFinish()
            self.SM:to(MS.Idle)
            self.SM:to(PS.Air)
            self.touchedGround = true
            self:setPermanentSafePosition()
        end):delay(.2)
    end

    if instant then
        self.alpha = 0
        self.x = checkpoint:centerX() - self.width / 2
        self.y = checkpoint:bottom() - self.height - 17
        for i, v in ipairs(lines) do
            local y1_start = v[2]
            local y2_start = v[4]
            v[2] = self.height
            v[4] = self.height
            self:tween(v, _.random(.1, .3), { [2] = y1_start, [4] = y2_start }):delay(.3)
        end

        self.SFX.teleport_out:play("reverb")

        self:delay(.3, appear)
    else
        self.alpha = 1

        self.SFX.teleport_in:play("reverb")

        self:delay(.3, function() self.SFX.teleport_out:play("reverb") end)

        for i, v in ipairs(lines) do
            local y1_start = v[2]
            local y2_start = v[4]
            self:tween(v, _.random(.1, .3), { [2] = self.height / 2, [4] = self.height / 2 }):delay(.1)
                :oncomplete(function()
                    v[2] = self.height
                    v[4] = self.height
                    self:tween(v, _.random(.1, .3), { [2] = y1_start, [4] = y2_start }):delay(.5)
                end)
        end

        self:tween(.1, { alpha = 0 })

        self:tween(self.teleportSpeed,
            {
                x = checkpoint:centerX() - self.width / 2,
                y = checkpoint:bottom() - self.height - 17
            }):delay(.4)
            :oncomplete(appear)
    end
end

-- Cloning

function Player:createClone()
    if self.clonedPlayer then
        self.clonedPlayer:kill()
    end

    self.clonedPlayer = Clone(self)
    self.mapLevel:addEntity(self.clonedPlayer, true)
end

-- Shoot

function Player:shootLaser()
    local direction = self.flip.x and Direction.Left or Direction.Right

    if self.inputHoldingUp then
        if self.lastInputDirection == Direction.Left then
            direction = Direction.LeftUp
        elseif self.lastInputDirection == Direction.Right then
            direction = Direction.RightUp
        else
            direction = Direction.Up
        end
    elseif self.inputHoldingDown then
        if not self.SM:is(PS.Ground) then
            if self.lastInputDirection == Direction.Left then
                direction = Direction.LeftDown
            elseif self.lastInputDirection == Direction.Right then
                direction = Direction.RightDown
            else
                direction = Direction.Down
            end
        end
    end

    self.SFX["laser_" .. self.tag:lower()]:play()

    self.laserShootDelay()
    local x, y = self:getRelativePosition(self.shootOffset, (self:usesLowerHitbox() and 15 or -15))
    self.scene:add(Laser(x, y, direction, self.tag))
end

function Player:turnFlashlightOn()
    if not self.flashlight or not self.flashlight.visible then
        self.SFX.flashlight:play("reverb")
    end

    if not self.flashlight then
        self.flashlight = self.scene:addLightSource(self, self.flashlightRadius, self.flashlightRadius)
    else
        self.flashlight.visible = true
    end
end

function Player:turnFlashlightOff()
    if self.flashlight then
        self.flashlight.visible = false
    end
end

function Player:handleFlashlightInput(dt)
    if not self.flashlight then return end

    local axis_x, axis_y = Input:getGamepadAxes(self.controllerId, "right")
    if not axis_x then return end

    local light = self.flashlight

    light.offset.x = axis_x * 200
    light.offset.y = axis_y * 200
end

function Player:goIntoWater()
    self.SM:to(MS.Swim, true)
    self.SM:to(PS.Water, true)

    -- self.y = self.y + 100

    self.gravity = 250

    self.maxVelocity.x = self.swimSpeed.x
    self.maxVelocity.y = self.swimSpeed.y

    self.drag.x = 100
    self:stopMoving()

    self.autoFlip.accel = true

    if self.hitboxSwim then
        self.hitboxSwim.active = true
    end
end

function Player:goOutWater()
    self.SM:unlock(MS.Swim)
    self.SM:unlock(PS.Water)
    self.SM:to(MS.Fall)
    self.SM:to(PS.Water)

    self.gravity = 1000

    self.maxVelocity.x = math.huge
    self.maxVelocity.y = math.huge

    self.drag.x = 0
    self:stopMoving()

    self.autoFlip.accel = false
    if self.hitboxSwim then
        self.hitboxSwim.active = false
    end
end

function Player:swimOutOfWater()
    self.gravity = 0
    self.accel.y = 0
    self.velocity.y = -self.swimSpeed.y
end

function Player:setPermanentSafePosition()
    self.permanentSafePosition = { x = self.x, y = self.y }
end

function Player:onWarpIn(i)
    self.inControl = false
    self.useGravity = false
    self.accel.y = 0
    self.movementDirection = nil
    self:stopMoving()
    self.rotation = i == 1 and -5 or 5
end

return Player
