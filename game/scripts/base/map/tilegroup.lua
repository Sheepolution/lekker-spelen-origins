local Entity = require "base.entity"

local TileGroup = Entity:extend("TileGroup")

function TileGroup:new(tileLayer, enum, customData)
    TileGroup.super.new(self)

    self.tileLayer = tileLayer
    self.x = self.tileLayer.x
    self.y = self.tileLayer.y
    self.enum = enum
    self.size = tileLayer.gridSize

    if tileLayer.properties then
        self:setProperties(tileLayer.properties)
    end

    self.normalizedPositions = {}

    self.visible = false
    self.immovable = true
    self.tile = true

    self.solid = 2

    if customData then
        for name, value in pairs(customData) do
            self[name] = _.autoConvert(value)
        end
    end
end

function TileGroup:update(dt)
    TileGroup.super.update(self, dt)
end

function TileGroup:extraOverlapCheck(e, myHitbox, theirHitbox)
    if self.slope then
        local myY = myHitbox.bb.y
        local myWidth = myHitbox.bb.width
        local myHeight = myHitbox.bb.height

        local theirX = theirHitbox.bb.centerX - myHitbox.bb.x
        if theirX < 0 or theirX > myWidth then return false end
        local slopeHeight = self:getSlopeHeight(theirX, myY, myWidth, myHeight)

        if self.reverse then
            return theirHitbox.bb.top < slopeHeight
        else
            return theirHitbox.bb.bottom > slopeHeight
        end
    end

    return true
end

function TileGroup:separate(collisionInfo, axis, size, moveBack)
    if self.slope then
        local e = collisionInfo.e
        local myHitbox = collisionInfo.myHitbox
        local theirHitbox = collisionInfo.theirHitbox
        local myY = myHitbox.bb.y
        local myWidth = myHitbox.bb.width
        local myHeight = myHitbox.bb.height

        local theirX = theirHitbox.bb.centerX - myHitbox.bb.x
        if theirX < 0 or theirX > myWidth then return false end

        local slopeHeight = self:getSlopeHeight(theirX, myY, myWidth, myHeight)

        if self.reverse then
            e.y = e.y + (slopeHeight - theirHitbox:top())
        else
            e.y = e.y - (theirHitbox:bottom() - slopeHeight)
        end

        collisionInfo.hisTop = false
        collisionInfo.hisBottom = true

        e._collisionInfo.myBottom = true

        return true
    end

    return TileGroup.super.separate(self, collisionInfo, axis, size, moveBack)
end

function TileGroup:getSlopeHeight(theirX, y, width, height)
    return y + height * (self.start + (theirX * (self.ending - self.start)) / width)
end

function TileGroup:clearHitboxes()
    TileGroup.super.clearHitboxes(self)
    self.normalizedPositions = {}
end

function TileGroup:addNormalizedPosition(x, y)
    if not self.normalizedPositions[y] then
        self.normalizedPositions[y] = {}
    end

    self.normalizedPositions[y][x] = true
end

function TileGroup:createHitboxes()
    local used = {}  -- Keeps track of used tiles
    local column = 0 -- Current column position
    local row = 1    -- Current row position

    local x, y, w, h -- Variables to store the position and dimensions of hitboxes

    while true do
        for i = row, self.tileLayer.rows do
            row = i

            if not used[i] then
                used[i] = {} -- Initialize used[i] if it doesn't exist
            end

            for j = column + 1, self.tileLayer.columns do
                column = j
                if self.normalizedPositions[row] and self.normalizedPositions[row][j] and not used[row][j] then
                    used[row][j] = true -- Mark the tile as used

                    if not x then
                        x, y, w, h = j, row, 1, 1 -- Initialize hitbox position and dimensions
                    else
                        w = w + 1                 -- Expand the width of the hitbox
                    end
                elseif x then
                    break -- Break the inner loop if no more tiles can be added to the current hitbox
                else
                    if column == self.tileLayer.columns and row == self.tileLayer.rows then
                        return -- Return if we reached the end of the tilemap
                    end
                end
            end

            if x then
                break      -- Break the outer loop if a hitbox is being constructed
            else
                column = 0 -- Reset the column position if no hitbox is being constructed
            end
        end

        for i = row + 1, self.tileLayer.rows do
            if not used[i] then
                used[i] = {} -- Initialize used[i] if it doesn't exist
            end

            local success = true
            for j = x, (x + w - 1) do
                if not self.normalizedPositions[i] or not self.normalizedPositions[i][j] or used[i][j] then
                    success = false -- Check if tiles in the next row can be added to the current hitbox
                    break
                end
            end

            if success then
                for j = x, (x + w - 1) do
                    used[i][j] = true -- Mark tiles in the next row as used
                end

                h = h + 1 -- Expand the height of the hitbox
            else
                break     -- Break the loop if tiles in the next row cannot be added
            end
        end

        self:addHitbox((x - 1) * self.size, (y - 1) * self.size, w * self.size, h * self.size, false, false) -- Add the constructed hitbox to the tile group

        -- We added the last tile.
        if column == self.tileLayer.columns and row == self.tileLayer.rows then
            return -- Return if we added the last tile in the tilemap
        end

        x, y, w, h = nil, nil, nil, nil -- Reset hitbox variables for the next iteration
    end
end

return TileGroup
