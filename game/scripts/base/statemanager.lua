local Class = require "base.class"

local StateManager = Class:extend("StateManager")

function StateManager:new(object, stateTypes)
    self.object = object
    self.currentStates = {}
    self.stateTypes = stateTypes
    self.stateData = {}
    self.stateToType = {}
    self.names = {}
    self.locks = {}

    for i, statetype in ipairs(self.stateTypes) do
        self.stateData[statetype] = {}
        for k, v in pairs(statetype) do
            if not self.currentStates[statetype] then
                self.currentStates[statetype] = v
            end

            self.stateData[statetype][v] = { all = true, functions = {} }
            self.stateToType[v] = statetype
            self.names[v] = k
        end
    end
end

function StateManager:update(dt)
    for k, v in pairs(self.currentStates) do
        self:executeFunction(v, self.stateData[k][v], "Update", dt)
    end
end

function StateManager:configure(state, conditions)
    local stateType = self:findStateType(state)

    local data = self.stateData[stateType][state]

    data.all = false

    data.list = {}
    for k, v in pairs(conditions) do
        local stateType2 = self:findStateType(k)
        if data.list[stateType2] == nil then
            data.list[stateType2] = v and true or nil
        end

        data.list[k] = true
    end

    self.stateData[state] = data
end

function StateManager:get(stateType, value)
    return value and self.currentStates[stateType] or self.names[self.currentStates[stateType]]
end

function StateManager:is(state)
    for k, v in pairs(self.currentStates) do
        if v == state then
            return true
        end
    end

    return false
end

function StateManager:to(state, lock, force)
    local stateType = self:findStateType(state)
    if force or self:canGoToState(state) then
        local current = self.currentStates[stateType]
        if current and current ~= state then
            self:executeFunction(current, self.stateData[stateType][current], "End")
        end

        self:executeFunction(state, self.stateData[stateType][state], "Init")

        local new_current = self.currentStates[stateType]
        if new_current ~= current then
            -- The state changed during the init function
            return false
        end

        self.currentStates[stateType] = state

        if force then
            -- Break the lock
            self.locks[stateType] = nil
        end

        if lock then
            self.locks[stateType] = state
        end
    end
end

function StateManager:lock(state)
    if type(state) == "string" then
        local stateType = self:findStateType(state)

        if self.currentStates[stateType] ~= state then
            return false
        end

        self.locks[stateType] = state
        return true
    end

    self.locks[state] = self.currentStates[state]
    return true
end

function StateManager:unlock(state)
    if type(state) == "string" then
        local stateType = self:findStateType(state)
        if self.locks[stateType] == state then
            self.locks[stateType] = nil
            return true
        end
        return false
    end

    self.locks[state] = nil
    return true
end

function StateManager:canGoToState(state)
    local stateType = self:findStateType(state)

    if self.currentStates[stateType] == state then
        -- We are already in this state
        return false
    end

    if self.locks[stateType] then
        return false
    end

    local data = self.stateData[stateType][state]

    local result = self:executeFunction(state, data, "Check")
    if result == false then
        return false
    end

    if data.all then
        return true
    end

    for k, v in pairs(self.currentStates) do
        if data.list[v] ~= data.list[k] then
            return false
        end
    end

    return true
end

function StateManager:executeFunction(state, data, name, ...)
    local functions = data.functions
    local propName = name

    if functions[propName] == nil then
        local name_state = self.names[state]
        name_state = name_state:sub(1, 1):lower() .. name_state:sub(2)
        local f = self.object[name_state .. name]

        if f then
            functions[propName] = f
            return f(self.object, ...)
        else
            functions[propName] = false
        end
    else
        if functions[propName] then
            return functions[propName](self.object, ...)
        end
    end
end

function StateManager:findStateType(state)
    return self.stateToType[state]
end

return StateManager
