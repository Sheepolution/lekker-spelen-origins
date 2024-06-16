local coil = require "libs.coil"
local json = require "libs.json"
local Class = require "base.class"
local Tileset = require "base.map.tileset"
local Asset = require "base.asset"
local Level = require "base.map.level"
local MapUtils = require "base.map.maputils"

local World = Class:extend("World")

function World:new(scene, mapName, level, properties)
	self.scene = scene
	self.levels = {}
	self.mapName = mapName
	self.properties = properties or {}
	self.autoCamera = false
	self.useTransition = false

	self.coil = coil.group()

	self:loadMap(mapName)

	if level then
		self:toLevel(level)
	end
end

function World:update(dt)
	self.coil:update(dt)

	if self.following then
		self:handleDetectingFollowed()
	end

	if DEBUG then
		if self.mapName and Asset._mapCache[self.mapName] ~= self.mapFile then
			self.mapFile = Asset._mapCache[self.mapName]
			self:hotswap()
		end
	end
end

function World:loadMap(mapName)
	local map = Asset.map(mapName)

	self.mapFile = map
	self.worldData = json.decode(self.mapFile)
	self:buildMap()
end

function World:buildMap()
	local tilesets = {}
	-- Definition tables contain metadata for layers, entitites, and levels.
	local layerDefinitions = {}
	local entityDefinitions = {}
	local levelDefinitions = {}

	for __, tilesetData in ipairs(self.worldData.defs.tilesets) do
		local tileset = Tileset(tilesetData.uid, MapUtils.getProperImagePath(tilesetData.relPath),
			tilesetData.tileGridSize,
			tilesetData.padding, tilesetData.enumTags, tilesetData.customData)
		tilesets[tilesetData.uid] = tileset
	end

	for __, entityData in ipairs(self.worldData.defs.entities) do
		local entityType = { id = entityData.uid, identifier = entityData.identifier, fields = {} }

		if entityData.resizableX or entityData.resizableY then
			entityType.resizable = true
		end

		for ___, entityFieldData in ipairs(entityData.fieldDefs) do
			-- Simplify the field data to only what we need
			local entityField = {
				id = entityFieldData.uid,
				type = entityFieldData.type,
				identifier = entityFieldData.identifier,
				isArray = entityFieldData.isArray,
				default = entityFieldData.defaultOverride,
				language = entityFieldData.textLanguageMode,
			}

			entityType.fields[entityField.id] = entityField
		end

		entityDefinitions[entityType.id] = entityType
	end

	for __, layerData in ipairs(self.worldData.defs.layers) do
		-- Simplify the field data to only what we need
		local layerDefinition = {
			id = layerData.uid,
			tileset = tilesets[layerData.tilesetDefUid],
			gridSize = layerData.gridSize,
			type = layerData.type,
			language = layerData.textLanguageMode,
		}

		layerDefinitions[layerData.uid] = layerDefinition
	end

	-- The data for the custom fields for levels
	for __, levelFieldData in ipairs(self.worldData.defs.levelFields) do
		local levelField = {
			id = levelFieldData.uid,
			identifier = levelFieldData.identifier,
			isArray = levelFieldData.isArray,
			type = levelFieldData.type,
			language = levelFieldData.textLanguageMode,
			default = levelFieldData.defaultOverride
		}

		levelDefinitions[levelField.id] = levelField
	end

	for __, levelData in ipairs(self.worldData.levels) do
		local levelProperties = MapUtils.getInstanceProperties(levelDefinitions, levelData.fieldInstances)
		if self.properties.level then
			for k, v in pairs(self.properties.level) do
				if levelProperties[k] == nil then
					levelProperties[k] = v
				end
			end
		end

		local level = Level(self.scene, self, levelData, layerDefinitions, entityDefinitions, levelProperties,
			self.properties)

		self.levels[levelData.identifier] = level
	end

	self.tilesets = tilesets
	self.layerDefinitions = layerDefinitions
	self.entityDefinitions = entityDefinitions
	self.levelDefinitions = levelDefinitions
end

function World:toLevel(level, unload, transition)
	if transition == nil then
		transition = self.useTransition
	end

	local previousLevel = self.currentLevel
	if self.currentLevel then
		if unload or unload == nil then
			self.currentLevel:unload()
		else
			self.currentLevel:unfocus()
		end
	end

	if type(level) == "number" then
		self.currentLevel = self.levels["World_Level_" .. level]
	elseif type(level) == "string" then
		for __, levelData in ipairs(self.worldData.levels) do
			if levelData.identifier == level then
				self.currentLevel = self.levels[levelData.identifier]
				break
			end
		end
	else
		self.currentLevel = level
	end

	if self.autoCamera then
		local camera = self.scene:getCamera()
		if camera then
			camera:setWorld(self.currentLevel.x, self.currentLevel.y, self.currentLevel.width, self.currentLevel.height)
		end
	end

	-- if self.transitionCallback then
	-- 	self.transitionCallback(self.currentLevel, previousLevel, function()
	-- 		self.currentLevel:focus()
	-- 		self.scene:onChangingLevel(self.currentLevel, previousLevel)
	-- 	end)
	-- else
	self.currentLevel:focus(transition)
	self.scene:onChangingLevel(self.currentLevel, previousLevel)
	-- end
end

function World:follow(entity, newState)
	if self.following then
		self.following.mapUnloadProtection = newState or MapUtils.ProtectionLevel.None
	end

	self.following = entity
	if self.following then
		self.following.mapUnloadProtection = MapUtils.ProtectionLevel.Strong
	end
end

function World:handleDetectingFollowed()
	for __, v in pairs(self.levels) do
		if v:handleDetectingFollowed(self.following, self.useTransition) then
			self:toLevel(v, false, self.useTransition)
			break
		end
	end
end

function World:getCurrentLevel()
	return self.currentLevel
end

function World:hotswap()
	self.worldData = json.decode(self.mapFile)

	for __, levelData in ipairs(self.worldData.levels) do
		local level = self.levels[levelData.identifier]

		if level:isLoaded() then
			for ___, layerInstance in _.ripairs(levelData.layerInstances) do
				local layerDefinition = self.layerDefinitions[layerInstance.layerDefUid]

				if layerDefinition.type == "Tiles" then
					level:updateTileLayer(layerDefinition.id, layerInstance.gridTiles)
				end
			end
		end
	end
end

function World:setTransitionCallback(callback)
	self.transitionCallback = callback
end

function World:getActivateWaitCallback()
	return self.activateWaitCallback
end

function World:destroy()
	for k, v in pairs(self.levels) do
		v:unload()
		v:destroy()
	end
end

return World
