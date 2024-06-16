local flags = require "data.flags"
local Class = require "base.class"
local Save = require "base.save"

local FlagManager = Class:extend("FlagManager")

local Flag = Enums.Flag

function FlagManager:new(...)
    FlagManager.super.new(self, ...)
    flags = self:convertToEnum(Save:get("game.flags")) or flags
end

function FlagManager:set(name, value)
    if flags[name] == nil then
        error("Invalid flag name: " .. name)
    end

    flags[name] = value
    Save:set("game.flags", self:convertToKeys(flags))
end

function FlagManager:get(name)
    if flags[name] == nil then
        error("Invalid flag name: " .. name)
    end

    return flags[name]
end

function FlagManager:convertToEnum(keys)
    if not keys then return nil end

    local enums = flags
    for key, value in pairs(keys) do
        enums[Flag[key]] = value
    end

    return enums
end

function FlagManager:convertToKeys(enums)
    local keys = {}
    for key_enum, key in pairs(Flag) do
        for key_flag, value in pairs(enums) do
            if key_flag == key then
                keys[key_enum] = value
            end
        end
    end

    return keys
end

function FlagManager:reset()
    for k, v in pairs(flags) do
        flags[k] = false
    end

    flags = self:convertToEnum(Save:get("game.flags")) or flags
end

return FlagManager()
