local _ = require "base.utils"
local Asset = require "base.asset"
local Class = require "base.class"

local SFX = Class:extend("SFX")

SFX.maxVolume = CONFIG.defaultSFXMax

function SFX:new(path, max, props)
	self.path = path
	self.sounds = {}
	self.max = max or 0

	if props then
		self:setProperties(props)
	end

	-- Preload
	table.insert(self.sounds, Asset.audio(self.path, true))
end

function SFX:play(effect)
	for i, v in _.ripairs(self.sounds) do
		if not v:isPlaying() then
			self:_play(v, effect)
			return v
		end
	end

	if self.max > 0 and #self.sounds >= self.max then
		return
	end

	local sound = Asset.audio(self.path, true, true)
	table.insert(self.sounds, sound)
	self:_play(sound, effect)
	return sound
end

function SFX:stop()
	for i, v in ipairs(self.sounds) do
		v:stop()
	end
end

function SFX:pause()
	for i, v in ipairs(self.sounds) do
		if v:tell() > 0 then
			v:pause()
		end
	end
end

function SFX:_play(sound, effect)
	sound:setVolume((self.volume or CONFIG.defaultSFXVolume) * SFX.maxVolume)

	if self.pitchRange then
		sound:setPitch(1 + _.random(-self.pitchRange, self.pitchRange))
	elseif self.pitch then
		sound:setPitch(self.pitch)
	end

	if effect then
		sound:setEffect(effect)
	end

	sound:play()
end

function SFX:destroy()
end

function SFX.updateMaxVolume(max)
	SFX.maxVolume = CONFIG.defaultSFXMax * max
end

return SFX
