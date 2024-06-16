require "data.savedata"
local Scene = require "base.scene"
local Intro = require "intro"
local GameManager = require "gamemanager"

local StateManager = Scene:extend("State")

function StateManager:new()
	if DEBUG then
		self:toGame()
	else
		self:toIntro()
	end
end

function StateManager:toGame()
	self:setScene(GameManager())
end

function StateManager:toIntro()
	self:setScene(Intro())
end

return StateManager
