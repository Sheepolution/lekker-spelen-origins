local ComputerBoss = require "bosses.computer.computer"
local Peter = require "characters.players.peter"
local Timon = require "characters.players.timon"
local MapUtils = require "base.map.maputils"
local Interactable = require "interactables.interactable"

local Scene = require "base.scene"

local Computer = Scene:extend("Computer")

function Computer:new(x, y, mapLevel)
    Computer.super.new(self)
    self:setBackgroundAlpha(0)
    self.mapLevel = mapLevel
    self.x = x
    self.y = y
end

function Computer:done()
    local computer = self.mapLevel:add(ComputerBoss(self.x, self.y), true)
    self.scene:findEntitiesOfType(Interactable):foreach(function(e)
        e.addedToLineDrawer = true
        e.connections = {}
    end)

    if self.scene.inWakuMinigame then
        local x, y = self.mapLevel:center()
        local peter = self.mapLevel:add(Peter())
        peter:center(x - 60, y + 140)
        local timon = self.mapLevel:add(Timon())
        timon:center(x + 70, y + 140)
        peter.mapUnloadProtection = MapUtils.ProtectionLevel.None
        timon.mapUnloadProtection = MapUtils.ProtectionLevel.None
        self.scene.noDoorAccess = true
        computer:startWaku()
    end

    self:destroy()
end

return Computer
