local _ = require "base.utils"
local Sprite = require "base.sprite"

local Tileset = Sprite:extend("Tileset")

function Tileset:new(id, image, gridSize, spacing, enums, customData)
	Tileset.super.new(self, 0, 0, image, gridSize, gridSize, spacing, false)
	self.anim:add("tiles", nil, "once", 0)
	self.id = id

	self.tiles = {}
	for i = 1, self.anim:getTotalFrameCount() do
		self.tiles[i] = {}
	end

	for __, enum in ipairs(enums) do
		for ___, tileId in ipairs(enum.tileIds) do
			local tile = self.tiles[tileId + 1]

			if not tile.enums then
				tile.enums = {}
			end

			table.insert(tile.enums, enum.enumValueId)
		end
	end

	for __, data in ipairs(customData) do
		local dataList = _.split(data.data, "\n")
		for ___, property in ipairs(dataList) do
			local tile = self.tiles[data.tileId + 1]

			if not tile.customData then
				tile.customData = {}
			end

			local keyValue = _.split(property, "=")
			tile.customData[keyValue[1]] = keyValue[2]
		end
	end
end

return Tileset
