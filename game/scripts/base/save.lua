local _ = require "base.utils"
local bitser = require "libs.bitser"
local Class = require "base.class"

local Save = Class:extend("Save")

local function serialize(data)
    return DEBUG and _.serialize(data) or bitser.dumps(data)
end

local function deserialize(data)
    return DEBUG and _.deserialize(data) or bitser.loads(data)
end

Save._class = Save

function Save:new()
    Save.super.new(self)
    self.fileName = "data"
end

function Save:get(path)
    if not self.data then
        self:load()
    end

    local value = _.get(self.data, path)
    if type(value) == "table" then
        return _.deep_copy(value)
    end

    return value
end

function Save:set(path, value)
    if not self.data then
        self:load()
    end

    _.set(self.data, path, value, true)
end

function Save:increase(path, amount, save)
    if not self.data then
        self:load()
    end

    local value = _.get(self.data, path)
    if type(value) ~= "number" then
        value = 0
    end

    value = value + (amount or 1)
    _.set(self.data, path, value, true)

    if save then
        self:save(path)
    end
end

function Save:getAll()
    return _.deep_copy(self.data)
end

function Save:load()
    local info = love.filesystem.getInfo(self.fileName)
    if not info then
        self:_createFile()
    else
        if info.type ~= "file" then
            love.filesystem.remove(self.fileName)
            self:_createFile()
        else
            self.data = deserialize(love.filesystem.read(self.fileName))
            self.dataOG = _.deep_copy(self.data)
        end
    end
end

function Save:save(path, value)
    if not self.data then
        self:load()
    end

    if path then
        if value then
            self:set(path, value)
        else
            value = _.get(self.data, path)
        end

        _.set(self.dataOG, path, value, true)
    else
        self.dataOG = _.deep_copy(self.data)
    end

    love.filesystem.write("data", serialize(self.dataOG))
end

function Save:restore(path)
    if not self.data then
        self:load()
    end

    if path then
        self:set(path, _.get(self.dataOG, path))
        return
    end

    self.data = _.deep_copy(self.dataOG)
end

function Save:saveDefault(data)
    if self.data then return end
    local info = love.filesystem.getInfo(self.fileName)
    if info then
        return
    end

    self.data = _.deep_copy(data)
    self.dataOG = _.deep_copy(data)
    self:save()
end

function Save:_createFile()
    self.data = {}
    self.dataOG = {}
    self:save()
end

return Save()
