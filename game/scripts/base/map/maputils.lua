local MapUtils = {}

MapUtils.ProtectionLevel = {
    None = 0,   -- Remove and unload
    Weak = 1,   -- Remove from scene but never unload
    Strong = 2, -- Never remove from scene
}

function MapUtils.getInstanceProperties(fieldDefinitions, fieldInstances)
    local properties = {}
    local mock = { { params = {} } }

    for i, fieldInstance in ipairs(fieldInstances) do
        local fieldDefinition = fieldDefinitions[fieldInstance.defUid]
        local values = #fieldInstance.realEditorValues > 0 and fieldInstance.realEditorValues or
            (fieldDefinition.default and { fieldDefinition.default }) or mock
        if fieldDefinition.isArray then
            local array = {}
            for k, value in pairs(values) do
                local v = value.params[1]

                if v and fieldDefinition.type == "F_Text" and fieldDefinition.language == "LangLua" then
                    v = _.parse(v, "\\n")
                    array[k] = v
                elseif fieldDefinition.type == "F_EntityRef" then
                    for j, idList in ipairs(fieldInstance.__value) do
                        local t = {}
                        for key, id in pairs(idList) do
                            t[key:gsub("Iid", "Id")] = id
                        end
                        array[j] = t
                    end
                    break
                else
                    array[k] = v
                end
            end
            properties[fieldDefinition.identifier] = array
        else
            if fieldDefinition.type == "F_Text" and fieldDefinition.language == "LangLua" then
                if values[1].params[1] then
                    properties[fieldDefinition.identifier] = _.parse(values[1].params[1], "\\n")
                end
            elseif fieldDefinition.type == "F_EntityRef" then
                properties[fieldDefinition.identifier] = {}
                for k, v in pairs(fieldInstance.__value) do
                    properties[fieldDefinition.identifier][k:gsub("Iid", "Id")] = v
                end
            else
                properties[fieldDefinition.identifier] = values[1].params[1]
            end
        end
    end

    return properties
end

function MapUtils.getProperImagePath(path)
    local imageFolderName = "/images/"
    local extension = ".png"
    local start = path:find(imageFolderName) + #imageFolderName
    local ending = path:find(extension)
    return path:sub(start, ending - 1)
end

function MapUtils.addRealCoordinatesToPoints(property, points, levelData, layerDefinition)
    for i, point in ipairs(points) do
        local t = {}
        t.x = levelData.worldX + point.cx * layerDefinition.gridSize
        t.y = levelData.worldY + point.cy * layerDefinition.gridSize
        property[i] = t
    end
end

return MapUtils
