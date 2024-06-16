local TileGroup = require "base.map.tilegroup"
local Entity = require "base.entity"

local Clone = Entity:extend("Clone")

local function lazy()
    local Player = require "characters.players.player"
    local Enemy = require "creatures.enemy"
    local Block = require "objects.block"
    local Interactable = require "interactables.interactable"
    local Sawblade = require "hazards.sawblade"
    local Horsey = require "bosses.horsey.horsey"
    Clone:addExclusiveOverlap(Player, Enemy, Block, Interactable, Sawblade, Horsey)
    lazy = nil
end


function Clone:new(player)
    Clone.super.new(self)

    if lazy then
        lazy()
    end

    local x, y = player:getDrawCoordinates()
    self.x = x + 1
    self.y = y + 1

    self.playerEntity = true

    -- HACK
    if player.tag == "Peter" and player.flip.x then
        self.x = self.x - 1
    end

    self.width = player.width
    self.height = player.height

    self:addHitbox(player.hitboxMain:get())

    self.floorButtonPresser = true
    self.immovable = true

    self.color = player.abilityColor
    self.dots = player:getOutlineDots(self.x, self.y, player.imageData,
        player._frames[player.anim._current.frames[player.anim.frame]], player.flip.x and player.width)

    self.dotRemoveTimer = step.new(.05)
    self.start = {
        x = self.x,
        y = self.y
    }

    self.playerTag = player.tag
    self.playerObject = player

    self.drag:set(2100)

    self.usedTeleporter = false

    self.springDelay = step.after(.1)

    self.removeOnLevelChange = true
end

function Clone:update(dt)
    self.springDelay(dt)
    if self.dead then
        if self.dotRemoveTimer(dt) then
            if #self.dots == 0 then
                self:destroy()
                return
            end
            for i = 1, 25 do
                -- Remove a random pair of x y dots
                local j = math.random(1, #self.dots / 2)
                table.remove(self.dots, j * 2)
                table.remove(self.dots, j * 2 - 1)
            end
        end
    end

    if self.scene.inDeathAnimation then
        self:destroy()
    end

    Clone.super.update(self, dt)
end

function Clone:draw()
    love.graphics.push()
    love.graphics.translate(self.x - self.start.x, self.y - self.start.y)
    love.graphics.setColor(self.color)
    love.graphics.points(self.dots)
    love.graphics.setColor(1, 1, 1)
    love.graphics.pop()
end

function Clone:onOverlap(i)
    if i.e.tag == "Peter" or i.e.tag == "Timon" then
        if i.e.tag ~= self.playerTag then
            return true
        end
    end

    if i.e.tag == "Teleporter" then
        if i.e.on and i.e ~= self.usedTeleporter then
            i.e:onInteract(self)
        end
    end

    if i.e.tag == "Spring" and self.springDelay(0) then
        if i.e.on and not i.e.triggered then
            i.e:onBeingUsed()
            if self.velocity.y == 0 then
                self.velocity.y = -1000
            end
        end
    end

    if not self.dead and i.e.hurtsPlayer and i.e.tag ~= "Block" then
        self:kill()
    end
end

function Clone:teleportByPlatform(teleporter, otherTeleporter)
    self:centerX(otherTeleporter:centerX())
    self:bottom(otherTeleporter:top() + 17)
    self.usedTeleporter = otherTeleporter
    self:teleport()
end

return Clone
