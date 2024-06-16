local TileGroup = require "base.map.tilegroup"
local Input = require "base.input"
local Sprite = require "base.sprite"
local Entity = require "base.entity"

local TileLayer = Entity:extend("TileLayer")

TileLayer.wasRemoved = {}

function TileLayer:new(scene, level, id, x, y, width, height,
					   tileset, gridSize, gridTiles,
					   properties, mapProperties, offset, z, separated)
	TileLayer.super.new(self, x, y)
	self.scene = scene

	self.id = id
	self.width = width
	self.height = height
	self.tileset = tileset
	self.gridSize = gridSize
	self.gridTiles = gridTiles
	self.columns = math.floor(width / gridSize)
	self.rows = math.floor(height / gridSize)
	self.offset = {
		x = offset.x or 0,
		y = offset.y or 0
	}

	self.interactable = false

	self.z = z or ZMAP[self.tag] or 100

	local separateTiles = {}

	if mapProperties then
		-- TODO: Set properties for this layers specifically
		-- self:setProperties(mapProperties)
		if not separated then
			if mapProperties.separateTileLayers then
				for k, v in pairs(mapProperties.separateTileLayers) do
					separateTiles[k] = true
					level:addTileLayer(TileLayer(self.scene, level, id, x, y, width, height,
						tileset, gridSize, gridTiles,
						v.properties, mapProperties, offset, z, k))
				end
			end
		end
	end

	if properties then
		self:setProperties(properties)
	end

	self.tileGroupSet = {}

	self.normalTileGroups = TileGroup(self)
	self.uniqueTileGroups = { self.normalTileGroups }

	self.enumTileGroups = {}
	self.animatedTiles = {}

	for i, tileData in ipairs(tileset.tiles) do
		if tileData.enums then
			for __, enum in ipairs(tileData.enums) do
				if (not separated and not separateTiles[enum]) or separated == enum then
					if tileData.customData then
						local tileGroup = TileGroup(self, enum, tileData.customData)

						if not self.tileGroupSet[i] then
							self.tileGroupSet[i] = {}
						end

						table.insert(self.tileGroupSet[i], tileGroup)
						table.insert(self.uniqueTileGroups, tileGroup)
					else
						local tileGroup = self.enumTileGroups[enum]

						if not self.tileGroupSet[i] then
							self.tileGroupSet[i] = {}
						end

						if not tileGroup then
							tileGroup = TileGroup(self, enum)
							self.enumTileGroups[enum] = tileGroup
							table.insert(self.uniqueTileGroups, tileGroup)
						end

						table.insert(self.tileGroupSet[i], tileGroup)
					end
				end
			end
		elseif separated then
			-- Empty elseif to prevent adding non-enum tiles when separated
		elseif tileData.customData then
			local tileGroup = TileGroup(self, nil, tileData.customData)
			self.tileGroupSet[i] = { tileGroup }
			table.insert(self.uniqueTileGroups, tileGroup)
		else
			self.tileGroupSet[i] = { self.normalTileGroups }
		end
	end

	self:createTiles(gridTiles)
end

function TileLayer:update(dt)
	TileLayer.super.update(self, dt)
	self.tileset:update(dt)

	for __, v in ipairs(self.animatedTiles) do
		v:update(dt)
	end
end

function TileLayer:draw()
	if not self.spritebatch then return end
	love.graphics.draw(self.spritebatch, self.offset.x, self.offset.y)

	for __, v in ipairs(self.animatedTiles) do
		v:draw()
	end

	if DEBUG then
		if Input:isDown("tab") then
			for __, tileGroup in ipairs(self.tileGroupSet) do
				for ___, tile in ipairs(tileGroup) do
					tile:drawDebug()
				end
			end
		end
	end
end

function TileLayer:getNormalizedPosition(x, y)
	local xNormal = math.floor((x) / self.gridSize)
	local yNormal = math.floor((y) / self.gridSize)
	return xNormal + 1, yNormal + 1
end

function TileLayer:createTiles(gridTiles)
	self.gridTiles = gridTiles

	for __, gridTile in ipairs(gridTiles) do
		-- If not, it's because it got separated
		if self.tileGroupSet[gridTile.t + 1] then
			for ___, tileGroup in ipairs(self.tileGroupSet[gridTile.t + 1]) do
				if (tileGroup.animated) then
					local sprite = Sprite(self.x + self.offset.x + gridTile.px[1],
						self.y + self.offset.y + gridTile.px[2],
						tileGroup.imagePath, true)
					sprite.anim:setRandomFrame()
					table.insert(self.animatedTiles, sprite)
				end
				local x, y = self:getNormalizedPosition(gridTile.px[1], gridTile.px[2])
				tileGroup:addNormalizedPosition(x, y)
			end
		end
	end

	local tileGroupCache = {}

	if not self.decoration then
		for __, tileGroup in ipairs(self.uniqueTileGroups) do
			if not tileGroupCache[tileGroup] then
				tileGroup:createHitboxes()
				tileGroupCache[tileGroup] = true
			end
		end
	end

	self:createSpriteBatch(gridTiles)
end

function TileLayer:createSpriteBatch(gridTiles)
	self.spritebatches = {}

	if #gridTiles == 0 then
		return
	end

	if not self.drawIndividual then
		self.spritebatch = love.graphics.newSpriteBatch(self.tileset.image, #gridTiles, "static")
	end

	for __, gridTile in ipairs(self.gridTiles) do
		-- If not, it's because it got separated.
		-- And in case it got separated, we don't want to draw it here.
		if self.tileGroupSet[gridTile.t + 1] then
			self.spritebatch:add(self.tileset._frames[gridTile.t + 1],
				self.x + gridTile.px[1], self.y + gridTile.px[2],
				0, 1.001, 1.001)
		end
	end
end

-- For layers that don't interact with entities.
function TileLayer:turnIntoDecoration()
	for __, tileGroups in ipairs(self.tileGroupSet) do
		for ___, tileGroup in ipairs(tileGroups) do
			tileGroup:clearHitboxes()
		end
	end
end

function TileLayer:addToScene(scene)
	scene:add(self)

	for i, tileGroup in ipairs(self.uniqueTileGroups) do
		scene:add(tileGroup)
	end
end

function TileLayer:removeFromScene(scene)
	scene:remove(self)
	-- self:destroy()

	for i, tileGroup in ipairs(self.uniqueTileGroups) do
		scene:remove(tileGroup)
	end
end

return TileLayer
