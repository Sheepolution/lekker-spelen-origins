local _ = require "base.utils"
local sock = require "libs.sock"
local bitser = require "libs.bitser"
local wrap = require "libs.wrap"

local Class = require "base.class"

local Network = Class:extend()

function Network:new(server, address, port)
    self.server = server
    self.wrap = wrap.new(self)

    if server then
        self.socket = sock.newServer(address or "*", port)
    else
        self.socket = sock.newClient(address, port)
    end

    self.socket:on("connect", function(data, peer) self:onConnect(data, peer) end)
    self.socket:on("disconnect", function(data, peer) self:onDisconnect(data, peer) end)
    self.socket:setSerialization(bitser.dumps, bitser.loads)

    for i, event in ipairs(self.events) do
        self.socket:on(event, function(...) self["on" .. _.title(event)](self, ...) end)
    end

    if not self.server then
        self.socket:connect()
    end

    self.peers = {}
    self.disconnected = false
end

function Network:update()
    if self.disconnected then return end
    self.data = {}
    self.socket:update()
end

function Network:onConnect(data, peer)
    table.insert(self.peers, peer)
end

function Network:disconnect()
    if self.server then
        self.socket:destroy()
    else
        self.socket:disconnect()
    end
end

function Network:onDisconnect(data, peer)
    print("Disconnected!")
end

function Network:send(name, data, peer)
    if self.disconnected then return end
    if self.server then
        if peer then
            self.socket:sendToPeer(peer, name, data)
        else
            self.socket:sendToAll(name, data)
        end
    else
        self.socket:send(name, data)
    end
end

function Network:onData(data)
    self.data = data
end

function Network:sendData(data)
    self:send("data", data)
end

function Network:insertData(name, id, data)
    if not self.data[name] then
        self.data[name] = {}
    end

    self.data[name][id] = data
end

function Network:receiveData(name, id)
    return _.get(self.data, { name, id })
end

function Network:isServer()
    return self.server
end

return Network
