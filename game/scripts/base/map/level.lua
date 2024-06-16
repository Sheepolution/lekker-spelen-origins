local Enum = require "libs.enum"
local Rect = require "base.rect"
local TileLayer = require "base.map.tilelayer"
local MapUtils = require "base.map.maputils"

local Level = Rect:extend("Level")

Level.State = Enum("Unloaded", "Preloaded", "Activated", "Focused")

function Level:new(scene, world, levelData, layerDefinitions, entityDefinitions, properties, mapProperties)
    Level.super.new(self, levelData.worldX, levelData.worldY, levelData.pxWid,
        levelData.pxHei)

    self.scene = scene
    self.world = world

    self.levelData = levelData
    self.layerDefinitions = layerDefinitions
    self.entityDefinitions = entityDefinitions
    -- Get part after last underscore
    if levelData.identifier:find("World_level_") then
        self.id = tonumber(levelData.identifier:match("([^_]+)$"))
    else
        self.id = levelData.identifier
    end

    self.tileLayers = list()
    self.entityLayers = list()
    self.layers = list({ self.tileLayers, self.entityLayers })
    self.entities = list()

    self.destroyedEntities = list()

    self.decorationLayers = {}
    if mapProperties.layer then
        for i, v in ipairs(mapProperties.layer) do
            table.insert(self.decorationLayers, v.decoration and true)
        end
    end

    self.mapProperties = mapProperties or {}

    if properties then
        self:setProperties(properties)
    end

    self.state = Level.State.Unloaded

    local preloadRange = CONFIG.levelPreloadRange
    local activateRange = CONFIG.levelActivateRange

    self.preloadDetector = Rect(self.x - preloadRange, self.y - preloadRange, self.width + preloadRange * 2,
        self.height + preloadRange * 2)
    self.activateDetector = Rect(self.x - activateRange, self.y - activateRange, self.width + activateRange * 2,
        self.height + activateRange * 2)
end

function Level:addTileLayer(layer)
    self.tileLayers:add(layer)
    -- self.scene:add(layer)
end

function Level:addEntity(entity, scene)
    entity.mapEntityId = -1
    entity.mapLevel = self

    if not entity.mapUnloadProtection then
        entity.mapUnloadProtection = MapUtils.ProtectionLevel.None
    end

    self.entities:add(entity)

    if scene ~= false then
        self.scene:add(entity)
    end

    return entity
end

Level.add = Level.addEntity

function Level:handleDetectingFollowed(entity, transition)
    -- Unloaded
    if not self:isLoaded() then
        if self:overlapsWithPreloadDetector(entity) then
            self:preload(transition)
        end
        -- Loaded
    elseif not self:isActive() then
        if not self:overlapsWithPreloadDetector(entity) then
            self:unload()
        elseif self:overlapsWithActivateDetector(entity) then
            self:activate()
        end
        -- Activated
    elseif not self:overlapsWithActivateDetector(entity) then
        self:deactivate()
    elseif not self:isFocused() and self:isEntityInside(entity) then
        return true
    end
end

function Level:preload(transition)
    if self.eventPreload then return end

    self.eventPreload = function()
        if transition then
            self.world.activateWaitCallback = self.world.coil.callback()
            self.world.coil.wait(self.world.activateWaitCallback)
        end

        -- Go through all the layers this level has.
        for j, layerInstance in _.ripairs(self.levelData.layerInstances) do
            local layerDefinition = self.layerDefinitions[layerInstance.layerDefUid]

            if layerDefinition.type == "Tiles" then
                local layer = TileLayer(self.scene, self, layerDefinition.id, self.x,
                    self.y, self.width, self.height,
                    layerDefinition.tileset,
                    layerDefinition.gridSize, layerInstance.gridTiles,
                    self.layer_properties and self.layer_properties[j] or nil, self.mapProperties,
                    { x = layerInstance.__pxTotalOffsetX, y = layerInstance.__pxTotalOffsetY },
                    self.mapProperties.zmap and self.mapProperties.zmap[j])

                self:addTileLayer(layer)

                if self.decorationLayers[#self.tileLayers] then
                    -- Remove the hitboxes from this layer.
                    layer:turnIntoDecoration()
                end
            elseif layerDefinition.type == "Entities" then
                for l, entityInstance in ipairs(layerInstance.entityInstances) do
                    -- Check if there is an entity with the same entityId already in the level.
                    if not self.entities:find(function(e) return e.mapEntityId == entityInstance.iid end)
                        and not self.destroyedEntities:contains(entityInstance.iid) then
                        local entityDefinition = self.entityDefinitions[entityInstance.defUid]
                        local entityProperties = MapUtils.getInstanceProperties(entityDefinition.fields,
                            entityInstance.fieldInstances)
                        local requirePath = entityProperties.requirePath or entityDefinition.identifier:lower()
                        entityProperties.requirePath = nil

                        -- In case the entity has a Point array field, add the real coordinates to the points.
                        for __, fieldInstance in ipairs(entityInstance.fieldInstances) do
                            if fieldInstance.__type == "Array<Point>" then
                                MapUtils.addRealCoordinatesToPoints(entityProperties[fieldInstance.__identifier],
                                    fieldInstance.__value,
                                    self.levelData, layerDefinition)
                            elseif fieldInstance.__type == "Point" then
                                if entityProperties[fieldInstance.__identifier] then
                                    entityProperties[fieldInstance.__identifier] = {
                                        x = self.levelData.worldX + fieldInstance.__value.cx * layerDefinition.gridSize,
                                        y = self.levelData.worldY + fieldInstance.__value.cy * layerDefinition.gridSize
                                    }
                                end
                            end
                        end

                        local entity = require(requirePath)(self.x + entityInstance.px[1],
                            self.y + entityInstance.px[2])
                        entity.mapEntityId = entityInstance.iid
                        entity.mapLevel = self
                        if entityDefinition.resizable then
                            entity.width = entityInstance.width
                            entity.height = entityInstance.height
                        end
                        entity:setProperties(entityProperties)

                        if not entity.mapUnloadProtection then
                            entity.mapUnloadProtection = MapUtils.ProtectionLevel.None
                        end

                        -- Add the entity to the list of entities, but not yet to the scene.
                        table.insert(self.entities, entity)
                    end
                end
            end
        end

        self.eventPreload = nil
        self.state = Level.State.Preloaded
    end

    if transition then
        self.world.coil:add(self.eventPreload)
    else
        self.eventPreload()
    end
end

-- Remove all entities and layers from the level to save memory
function Level:unload()
    if self.state == Level.State.Focused then
        self:deactivate()
    end

    self.layers(function(e) e:clear() end)

    -- TODO: What if you want to save entity states?
    -- Instead of saving the entities you could have a registry that keeps track of properties of certain entities in this level
    self.entities:filter_inplace(function(e) return e.mapUnloadProtection > MapUtils.ProtectionLevel.None end)
    self.state = Level.State.Unloaded
end

-- Add all entities and layers to the scene
function Level:activate()
    self.layers:addToScene(self.scene)

    for i, entity in ipairs(self.entities) do
        if not entity.scene and not entity.destroyed then
            self.scene.entities:add(entity)
        end
    end

    for i, entity in ipairs(self.entities) do
        if not entity.scene and not entity.destroyed then
            self.scene:finishObject(entity)
        end
    end

    self.state = Level.State.Activated
    self.eventActivate = nil
    self.activateWaitCallback = nil
end

-- Remove all entities and layers from the scene
function Level:deactivate()
    self.layers:removeFromScene(self.scene)

    for i, entity in ipairs(self.entities) do
        if entity.mapUnloadProtection < MapUtils.ProtectionLevel.Strong then
            self.scene:remove(entity)
        end
    end

    self.state = Level.State.Preloaded
end

function Level:focus()
    if self.state == Level.State.Unloaded then
        self:preload()
    end

    if self.state == Level.State.Preloaded then
        self:activate()
    end

    self.state = Level.State.Focused
end

function Level:unfocus()
    if self.state == Level.State.Focused then
        self.state = Level.State.Activated
    end
end

function Level:updateTileLayer(layerId, gridTiles)
    self.tileLayers:find(function(l) return l.id == layerId end):createTiles(gridTiles)
end

function Level:overlapsWithPreloadDetector(entity)
    return self.preloadDetector:overlaps(entity)
end

function Level:overlapsWithActivateDetector(entity)
    return self.activateDetector:overlaps(entity)
end

function Level:isEntityInside(entity)
    local x, y = entity:center()
    return x > self.x and x < self.x + self.width and
        y > self.y and y < self.y + self.height
end

function Level:isLoaded()
    return self.state ~= Level.State.Unloaded
end

function Level:isActive()
    return self.state == Level.State.Activated or
        self.state == Level.State.Focused
end

function Level:isFocused()
    return self.state == Level.State.Focused
end

function Level:registerDestroyedEntity(entityId)
    self.destroyedEntities:add(entityId)
end

return Level
