local StateManager = require "base.statemanager"
local Enum = require "libs.enum"
local Input = require "base.input"
local Direction = (require "base.enums").Direction
local Sprite = require "base.sprite"
local Save = require "base.save"
local SFX = require "base.sfx"
local Entity = require "base.entity"

local Fighter = Entity:extend("Fighter")

local PositionState = Enum("Ground", "Air")
local PS = PositionState
Fighter.PS = PS

local BodyState = Enum("Stand", "Crouch", "Jump")
local BS = BodyState
Fighter.BS = BS

local ActionState = Enum("None", "Walk", "Punch", "Kick", "Hit", "Block")
local AS = ActionState
Fighter.AS = AS

Fighter.keys = {
    {
        left = { "c1_left_left", "c1_dpleft" },
        right = { "c1_left_right", "c1_dpright" },
        down = { "c1_left_down", "c1_dpdown" },
        jump = { "c1_a", "c1_dpup" },
        punch = { "c1_x" },
        kick = { "c1_b" },
        dash = { "c1_y", "c1_triggerright", "c1_rightshoulder" }
    },
    {
        left = { "left", "c2_left_left", "c2_dpleft" },
        right = { "right", "c2_left_right", "c2_dpright" },
        down = { "down", "c2_left_down", "c2_dpdown" },
        jump = { "z", "s", "c2_a" },
        punch = { "a", "x", "c2_x" },
        kick = { "w", "e", "c2_b", },
        dash = { "c", "d", "c2_y", "c2_triggerright", "c2_rightshoulder" }
    }
}

-- TODO: Turn off
if DEBUG then
    Fighter.keys = {
        {
            left = { "left", "c1_left_left", "c1_dpleft" },
            right = { "right", "c1_left_right", "c1_dpright" },
            down = { "down", "c1_left_down", "c1_dpdown" },
            jump = { "up", "c1_a", "c1_dpup" },
            punch = { "c1_x", "space" },
            kick = { "c1_b" },
            dash = { "c1_y", "c1_triggerright", "c1_rightshoulder" }
        },
        {
            left = { "a", "c2_left_left", "c2_dpleft" },
            right = { "d", "c2_left_right", "c2_dpright" },
            down = { "s", "c2_left_down", "c2_dpdown" },
            jump = { "w", "c2_a" },
            punch = { "c2_x", "k" },
            kick = { "c2_b", "l" },
            dash = { "u", "c2_y", "c2_triggerright", "c2_rightshoulder" }
        }
    }
end

Fighter.SFX = {
    punch = {
        SFX("sfx/minigames/fighter/punch1", 2, { pitchRange = .1 }),
        SFX("sfx/minigames/fighter/punch2", 2, { pitchRange = .1 }),
    },
    kick = {
        SFX("sfx/minigames/fighter/kick1", 2, { pitchRange = .1 })
    },
    block = {
        SFX("sfx/minigames/fighter/block1", 2, { pitchRange = .1 }),
        SFX("sfx/minigames/fighter/block2", 2, { pitchRange = .1 })
    },
    ko = SFX("sfx/minigames/fighter/ko"),
    land = SFX("sfx/minigames/fighter/land"),
}

function Fighter:new(...)
    Fighter.super.new(self, ...)

    self.bodyWidth = 70

    self.hitboxStand = self:addHitbox("stand", 10, 42, self.bodyWidth, 240)
    self.hitboxCrouch = self:addHitbox("crouch", 10, 72, self.bodyWidth, 180)
    self.hitboxJump = self:addHitbox("crouch", -10, 10, self.bodyWidth, 180)
    self.hitboxStandPunch = self:addHitbox("stand_punch", 90, -40, 80, 30, true)
    self.hitboxStandKick = self:addHitbox("stand_kick", 65, -75, 40, 40, true)
    self.hitboxCrouchPunch = self:addHitbox("crouch_punch", 94, 38, 80, 30, true)
    self.hitboxCrouchKick = self:addHitbox("crouch_kick", 115, 135, 120, 30, true)
    self.hitboxJumpPunch = self:addHitbox("jump_punch", 80, 5, 30, 30, true)
    self.hitboxJumpKick = self:addHitbox("jump_kick", 90, 58, 80, 30, true)

    self.bodyHitboxList = list({
        self.hitboxStand,
        self.hitboxCrouch,
        self.hitboxJump,
    })

    self.bodyHitboxList(function(e) e:deactivate() end)
    self.hitboxStand:activate()

    self.bodyHitboxMap = {
        [BS.Stand] = self.hitboxStand,
        [BS.Crouch] = self.hitboxCrouch,
        [BS.Jump] = self.hitboxJump,
    }

    self.attackHitboxList = list({
        self.hitboxStandPunch,
        self.hitboxStandKick,
        self.hitboxCrouchPunch,
        self.hitboxCrouchKick,
        self.hitboxJumpPunch,
        self.hitboxJumpKick,
    })

    self.attackHitboxList(function(e) e:deactivate() end)

    self.attackHitboxMap = {
        [BS.Stand] = {
            [AS.Punch] = self.hitboxStandPunch,
            [AS.Kick] = self.hitboxStandKick,
        },
        [BS.Crouch] = {
            [AS.Punch] = self.hitboxCrouchPunch,
            [AS.Kick] = self.hitboxCrouchKick,
        },
        [BS.Jump] = {
            [AS.Punch] = self.hitboxJumpPunch,
            [AS.Kick] = self.hitboxJumpKick,
        },
    }

    self.damageMap = {
        [self.hitboxStandPunch] = 5,
        [self.hitboxStandKick] = 6,
        [self.hitboxCrouchPunch] = 6,
        [self.hitboxCrouchKick] = 4,
        [self.hitboxJumpPunch] = 7,
        [self.hitboxJumpKick] = 5,
    }

    self.jumpsMax = 1
    self.jumps = self.jumpsMax
    self.jumpBuffered = false
    self.jumpPower = 1450

    self.jumpPreTimer = step.during(.05)
    self.jumpPreTimer:finish()

    self.autoFlip.x = false

    self.gravity = 4400
    self.speed = 250

    self.health = 100

    self.inControl = false

    self.defaultBodyLockDuration = .1
    self.defaultActionLockDuration = .3
    self.defaultFreezeDuration = .3

    self.bodyLockTimer = step.once(self.defaultBodyLockDuration)
    self.bodyLocked = false

    self.actionLockTimer = step.once(self.defaultActionLockDuration)
    self.actionLocked = false

    self.attackhitboxActiveTimer = step.once(.1)
    self.activeAttackHitbox = nil

    self.freezeTimer = step.during(self.defaultFreezeDuration)
    self.freezeTimer:finish()

    self.sameMoveCooldown = step.during(.4)
    self.lastMove = {}

    self.stunnedTimer = step.once(.2)

    self.dashCooldown = step.during(.5)

    self.SM = StateManager(self, { PS, BS, AS })
    self.SM:configure(BS.Stand, { [PS.Ground] = true })
    self.SM:configure(BS.Crouch, { [PS.Ground] = true })
    self.SM:configure(AS.Walk, { [BS.Stand] = true, [PS.Ground] = true })
    self.SM:to(PS.Ground)
    self.SM:to(BS.Stand)
    self.SM:to(AS.None)
end

function Fighter:update(dt)
    self.controllerId = Save:get("settings.controls." .. self.tag:lower() .. ".player1") and 1 or 2

    if not self.freezeTimer(dt) then
        if self.bodyLockTimer(dt) then
            self.SM:unlock(BS)
        end

        if self.actionLockTimer(dt) then
            self.SM:unlock(AS)
        end

        if self.attackhitboxActiveTimer(dt) then
            if self.activeAttackHitbox then
                self.activeAttackHitbox:deactivate()
                self.activeAttackHitbox = nil
            end
        end

        if self.stunnedTimer(dt) then
            self.stunned = false
            self.SM:unlock(AS)
        end
    end

    if self.SM:is(PS.Air) then
        if Input:isPressed(self.keys[self.controllerId].jump) then
            self.jumpPreTimer()
        end

        self.jumpPreTimer(dt)
    end

    self:handleInput(dt)

    if self.movementDirection then
        self:handleMovement()
    end

    self.SM:update(dt)

    if self.SM:is(PS.Ground) then
        if self:canMove() and self.lastInputDirection == nil then
            self:stopMoving("x")
        end
    end

    if not self:isMoving("x") and self.SM:is(PS.Ground) then
        self:handleStandstill()
    end

    Fighter.super.update(self, dt)

    if self:centerX() - self.bodyWidth < self.scene.tileWidth then
        self:centerX(self.scene.tileWidth + self.bodyWidth)
        self:teleport()
    elseif self:centerX() + self.bodyWidth > self.scene.tileWidth * 6 then
        self:centerX(self.scene.tileWidth * 6 - self.bodyWidth)
        self:teleport()
    end

    if self.SM:is(PS.Ground) and self.SM:is(AS.None) or self.SM:is(AS.Walk) then
        self:lookAt(self.opponent, "x", true)
    end
end

function Fighter:draw()
    if self.defeated and self.SM:is(PS.Ground) then
        self.anim:set(self.died and "dead" or "ko")
    elseif self.victory and self.SM:is(PS.Ground) then
        self.anim:set("victory")
    else
        local anim_ms = self.SM:get(BS):lower()
        local anim_as = self.SM:get(AS):lower()

        anim_as = anim_as == "none" and "" or "_" .. anim_as
        local anim = anim_ms .. anim_as

        if self.anim:getAnimation(anim, true) then
            self.anim:set(anim)
        else
            warning("Animation " .. anim .. " not found for " .. self.tag)
        end
    end

    if (self.anim:is("stand_walk") or self.anim:is("stand")) and self.dashing and self.last.x ~= self.x then
        self.anim:set("dash")
    end

    Fighter.super.draw(self)

    if DEBUG_INFO then
        DEBUG_INFO:addInfo("PS " .. self.tag, self.SM:get(PS))
        DEBUG_INFO:addInfo("BS " .. self.tag, self.SM:get(BS))
        DEBUG_INFO:addInfo("AS " .. self.tag, self.SM:get(AS))
        DEBUG_INFO:addInfo("VEL_Y " .. self.tag, self.velocity.y)
    end
end

function Fighter:onOverlap(i)
    if self.attackHitboxList:contains(i.myHitbox) then
        i.e:onHit(self, self.damageMap[i.myHitbox], i.myHitbox.name:split("_")[2])
        i.myHitbox:deactivate()
    end

    if not i.e.tile then
        if self.bodyHitboxList:contains(i.myHitbox) and i.e.bodyHitboxList:contains(i.theirHitbox) then
            self:moveBack(i.e, "push")
            i.e:moveBack(self, "push")
        end
    end
end

function Fighter:onSeparate(e, i)
    Fighter.super.onSeparate(self, e, i)
    if self.SM:is(PS.Air) then
        self:onGrounding()
    end
end

function Fighter:onGrounding()
    self.SM:unlock(BS)
    self.SM:unlock(AS)
    self.SM:to(PS.Ground)

    if self.defeated then
        Fighter.SFX.land:play("reverb")
        self.scene:setSlowmo(false)
        self.opponent.victory = true
        if self.scene:onWin(self.opponent) then
            self.died = true
        end
    else
        self.SM:to(BS.Stand)
        self.SM:to(AS.None)
        self.y = 412.5
    end

    if self.activeAttackHitbox then
        self.activeAttackHitbox:deactivate()
        self.activeAttackHitbox = nil
    end

    if not self.inControl then
        self:stopMoving()
    end

    self.stunned = false
end

function Fighter:onHit(opponent, damage, kind)
    self.z = 1
    opponent.z = -1
    self.freezeTimer()
    opponent.freezeTimer()

    local block = self:isBlocking(opponent)

    self.SM:unlock(AS)
    self.actionLockTimer:finish(true)
    self.SM:to(block and AS.Block or AS.Hit, true)
    self:stopMoving()

    self.stunned = true

    if self.SM:is(PS.Ground) then
        self.stunnedTimer()
    end

    if not block then
        opponent:createImpactFX()
        self:loseHealth(damage)
        if not self.defeated then
            self:playSFX(kind)
        end
        Input:rumble(self.controllerId, .4, .25)
    else
        Input:rumble(self.controllerId, .2, .2)
        self:playSFX("block")
    end

    self:shake(6, self.defaultFreezeDuration, true)
    self.moves = false
    opponent.moves = false
    self:delay(self.defaultFreezeDuration, function()
        self.moves = true
        opponent.moves = true
        self:stopMoving()
        opponent:stopMoving()
        if self.defeated then
            self.velocity.y = -800
        end
        self:moveBack(opponent, block and "block" or "hit")
        opponent:moveBack(self, "attack")
    end)
end

function Fighter:moveBack(opponent, movementType)
    if self.movingBack then
        return
    end
    self.movingBack = true
    local distance = self:getDistanceX(opponent)
    local speed_modifier = 2
    if movementType == "hit" then
        speed_modifier = 2
    elseif movementType == "block" then
        speed_modifier = 3
    elseif movementType == "attack" then
        speed_modifier = 1.5
    elseif movementType == "push" then
        speed_modifier = 1
    end

    self:addMovement((350 - distance) * speed_modifier * _.boolsign(self:centerX() > opponent:centerX()), 0, 2000, nil,
        true, "x")

    self:delay(.2, function()
        self.movingBack = false
    end)
end

function Fighter:isBlocking(opponent)
    local state = opponent.SM:get(BS, true)
    return self.SM:is(PS.Ground) and
        not self.SM:is(AS.Block) and
        not self.SM:is(AS.Kick) and
        (state ~= BS.Crouch or self.SM:is(BS.Crouch)) and
        (state ~= BS.Jump or self.SM:is(BS.Stand)) and
        ((self.flip.x and Input:isDown(self.keys[self.controllerId].right)) or
            (not self.flip.x and Input:isDown(self.keys[self.controllerId].left)))
end

function Fighter:loseHealth(amount)
    local current = self.health
    local new = current - amount

    if new <= 0 then
        if new >= -2 or self.opponent.defeated then
            self.health = 1
        else
            self:die()
            self.health = 0
        end
        amount = current - self.health
    else
        self.health = new
    end

    self.scene:onLosingHealth(self, amount, self.health)
end

function Fighter:die()
    Fighter.SFX.ko:play()

    self:moveBack(self.opponent, "hit")
    self.opponent:loseControl()
    self:loseControl()

    self.SM:to(PS.Air)
    self.SM:to(BS.Jump)
    self.SM:to(AS.Hit)
    self.defeated = true
    self.scene:setSlowmo(true)
end

function Fighter:loseControl()
    self.inControl = false
    self.lastInputDirection = nil
    self.movementDirection = nil
end

function Fighter:handleInput(dt)
    if not self:canMove() then
        return
    end

    self.inputHoldingDown = Input:isDown(self.keys[self.controllerId].down)

    self:handleDirectionInput()

    self:jumpInput()
    self:crouchInput()
    self:attackInput(dt)
    self:dashInput(dt)
end

function Fighter:handleDirectionInput()
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

function Fighter:handleStandstill()
    if self.inputHoldingDown then
        self.SM:to(BS.Crouch)
    else
        self.SM:to(BS.Stand)
    end

    self.SM:to(AS.None)
end

function Fighter:handleMovement()
    if self.SM:is(PS.Air) then
        return
    end

    if self.inputHoldingDown then
        return
    elseif self.SM:is(BS.Crouch) then
        self.SM:to(BS.Stand)
    end

    self.SM:to(AS.Walk)
end

function Fighter:canMove()
    return not self.stunned and self.inControl
end

function Fighter:walkInit()
    self.SM:to(BS.Stand)
end

function Fighter:walkUpdate()
    self:moveHorizontally()
end

function Fighter:standInit()
    self:onBodyStateChanged(BS.Stand)
end

function Fighter:jumpInput()
    if Input:isPressed(self.keys[self.controllerId].jump) or self.jumpPreTimer(0) then
        self.SM:to(BS.Jump)
    end
end

function Fighter:jumpInit()
    self.jumps = self.jumps - 1
    self.velocity.y = -self.jumpPower
    self.SM:to(PS.Air)
    self.SM:to(AS.None)

    self.jumpPreTimer:finish()
    if self.velocity.x ~= 0 then
        self.velocity.x = self.speed * 2 * _.sign(self.velocity.x)
    end

    self:onBodyStateChanged(BS.Jump)
end

function Fighter:crouchInput()
    if self.inputHoldingDown then
        self.SM:to(BS.Crouch)
    end
end

function Fighter:crouchInit()
    self:stopMoving()
    if self.SM:is(AS.Walk) then
        self.SM:to(AS.None)
    end

    self:onBodyStateChanged(BS.Crouch)
end

function Fighter:onBodyStateChanged(bodyState)
    self.bodyHitboxMap[self.SM:get(BS, true)]:deactivate()
    self.bodyHitboxMap[bodyState]:activate()
    if bodyState ~= BS.Jump then
        self.bodyLockTimer:set(self.defaultBodyLockDuration)
        self.SM:lock(BS)
    end
end

function Fighter:attackInput(dt)
    if self.activeAttackHitbox then return end

    self.sameMoveCooldown(dt)

    if Input:isPressed(self.keys[self.controllerId].punch) then
        if self.lastMove[1] == AS.Punch and self.lastMove[2] == self.SM:get(BS) then
            if self.sameMoveCooldown(0) then
                return
            end
        end
        self.SM:to(AS.Punch, true)
        self.SM:lock(BS)
        self.lastMove = { AS.Punch, self.SM:get(BS) }
        self.sameMoveCooldown()
    elseif Input:isPressed(self.keys[self.controllerId].kick) then
        if self.lastMove[1] == AS.Kick and self.lastMove[2] == self.SM:get(BS) then
            if self.sameMoveCooldown(0) then
                return
            end
        end

        self.SM:to(AS.Kick, true)
        self.SM:lock(BS)
        self.lastMove = { AS.Punch, self.SM:get(BS) }
        self.sameMoveCooldown()
    end
end

function Fighter:punchInit()
    self:onAttack(AS.Punch)
end

function Fighter:kickInit()
    self:onAttack(AS.Kick)
end

function Fighter:onAttack(attack)
    if self.SM:is(BS.Stand) then
        self:stopMoving()
    end

    if not self.SM:is(BS.Jump) then
        self.actionLockTimer()
    else
        if self.velocity.y < 0 then
            self.velocity.y = self.velocity.y / 2
        end
    end

    self.activeAttackHitbox = self.attackHitboxMap[self.SM:get(BS, true)][attack]
    self.activeAttackHitbox:activate()
    if self.SM:is(PS.Ground) then
        self.attackhitboxActiveTimer()
    end

    self.bodyLockTimer:set(self.defaultActionLockDuration)
    self.actionLockTimer:set(self.defaultActionLockDuration)
end

function Fighter:dashInput(dt)
    if self.dashCooldown(dt) then
        return
    end

    if not self:dashCheck() then
        return
    end

    if Input:isPressed(self.keys[self.controllerId].dash) then
        self:dash()
    end
end

function Fighter:dashCheck()
    return self.SM:is(PS.Ground)
        and (self.SM:is(AS.None) or self.SM:is(AS.Walk))
        and (self.SM:is(BS.Stand))
end

function Fighter:dash()
    self.dashing = true
    local speed = 1600
    if self.movementDirection == Direction.Left or (not self.movementDirection and self.flip.x) then
        speed = -speed
    end

    local movement = self:addMovement(speed, nil, 9000, nil, true, "x")
    local destroy = movement.destroy
    movement.destroy = function(m)
        self.dashing = false
        destroy(m)
    end
    self.dashCooldown()
end

function Fighter:moveHorizontally()
    if self.movementDirection == Direction.Left then
        self:moveLeft(self.flip.x and self.speed or self.speed * .75)
    elseif self.movementDirection == Direction.Right then
        self:moveRight(not self.flip.x and self.speed or self.speed * .75)
    else
        self.velocity.x = 0
    end
end

function Fighter:setOpponent(opponent)
    self.opponent = opponent
end

function Fighter:createImpactFX()
    if not self.activeAttackHitbox then return end
    local bb = self.activeAttackHitbox.bb
    local fx = self.scene:add(Sprite(0, 0, "minigames/fighter/impact", true))
    fx.anim:set(self.tag:lower())
    fx:center(self.flip.x and bb.left + 10 or bb.right - 10, bb.centerY)
    fx.scale:set(0, 0)
    fx.flip.x = _.coin()
    fx.flip.y = _.coin()
    self:tween(fx.scale, .2, { x = 1, y = 1 }):ease("backout")
    fx.z = -2
    self:delay(.3, fx.wrap:destroy())
end

function Fighter:playSFX(name)
    _.pick(self.SFX[name]):play("reverb")
end

return Fighter
