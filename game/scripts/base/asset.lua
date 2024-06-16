require "libs.json"

local Asset = {}

local imageCache = {}
Asset._imageCache = imageCache
local imgDataCache = {}
local fontCache = {}
local audioCache = {}
local audioDataCache = {}
local videoCache = {}
local mapCache = {}
local dataCache = {}
Asset._mapCache = mapCache

function Asset.image(path, force)
	local image
	if force or not imageCache[path] then
		image = love.graphics.newImage("assets/images/" .. path .. ".png")
		imageCache[path] = image
	else
		image = imageCache[path]
	end
	return image
end

function Asset.imageData(path, force)
	local image
	if force or not imgDataCache[path] then
		image = love.image.newImageData("assets/images/" .. path .. ".png")
		imgDataCache[path] = image
	else
		image = imgDataCache[path]
	end
	return image
end

function Asset.font(path, size, force, hinting)
	local font
	if force or not fontCache[path] or not fontCache[path][size] then
		font = love.graphics.newFont("assets/fonts/" .. path .. ".ttf", size, hinting)
		if not fontCache[path] then
			fontCache[path] = {}
		end
		fontCache[path][size] = font
	else
		font = fontCache[path][size]
	end
	return font
end

local audio_formats = {
	".mp3",
	".ogg",
	".wav"
}

function Asset.audio(path, static, force)
	local audio
	if force or not audioCache[path] then
		for i, v in ipairs(audio_formats) do
			local fullPath = "assets/audio/" .. path .. v
			local info     = love.filesystem.getInfo(fullPath)
			if info then
				audio = love.audio.newSource(fullPath, (static or OS.WEB) and "static" or "stream")
				audioCache[path] = audio
			end
		end
		assert(audio, "No audio found named " .. path, 2)
	else
		audio = audioCache[path]
		audio:stop()
	end
	return audio
end

function Asset.audioData(path, force)
	local audioData
	if force or not audioDataCache[path] then
		for i, v in ipairs(audio_formats) do
			local fullPath = "assets/audio/" .. path .. v
			local info     = love.filesystem.getInfo(fullPath)
			if info then
				audioData = love.sound.newSoundData(fullPath)
				audioDataCache[path] = audioData
			end
		end
		assert(audioData, "No audio found named " .. path, 2)
	else
		audioData = audioDataCache[path]
	end

	return audioData
end

function Asset.video(path, force)
	local video
	if force or not videoCache[path] then
		video = love.graphics.newVideo("assets/videos/" .. path .. ".ogv")
		videoCache[path] = video
	else
		video = videoCache[path]
	end
	return video
end

function Asset.map(path, force)
	local map
	if force or not mapCache[path] then
		map = love.filesystem.read("assets/maps/" .. path .. ".ldtk")
		assert(map, "No map found named " .. path, 3)
		mapCache[path] = map
	else
		map = mapCache[path]
	end

	return map
end

function Asset.data(path, force)
	local data
	if force or not dataCache[path] then
		local dataText = love.filesystem.read("assets/data/" .. path .. ".json")
		assert(dataText, "No data found named " .. path, 3)
		data = json.decode(dataText)
		dataCache[path] = data
	else
		data = dataCache[path]
	end

	return data
end

function Asset.clearCache()
	imageCache = {}
	Asset._imageCache = imageCache
	imgDataCache = {}
	fontCache = {}
	audioCache = {}
	audioDataCache = {}
	videoCache = {}
	Asset._mapCache = mapCache
end

return Asset
