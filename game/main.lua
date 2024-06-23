--[[
The MIT License (MIT)

Copyright (c) 2024 Sheepolution

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.


Welkom! Dit is de code van Lekker Spelen: Origins. Ik moet je waarschuwen, het is hier nogal een zooitje.

Het is als een jenga-toren. Pas je ergens iets aan, dan gaat het op een heel andere plek weer helemaal fout.
Schone code was nou niet bepaald mijn prioriteit bij dit project. Maar het werkt, en daar gaat uit eindelijk om.

Succes! En neem gerust contact met me op als je vragen hebt.
]]


-- Add scripts folder to paths
local paths = love.filesystem.getRequirePath()
love.filesystem.setRequirePath(paths .. ";scripts/?.lua;scripts/?/init.lua;scripts/game/?.lua;scripts/game/?/?.lua")

-- Launch type
local launch_type = arg[2]

DEBUG = false
DEBUG_TYPE = false
DEBUG_INFO = false

OS = {}
local os = love.system.getOS()
OS[os:upper()] = true

if launch_type then
    local launch_types = {
        "test", "debug", "profile", "record"
    }

    local success = false
    for _, v in ipairs(launch_types) do
        if launch_type == v then
            success = true
            break
        end
    end

    if success then
        DEBUG = true
        DEBUG_TYPE = launch_type

        DEBUGGER = require "lldebugger"

        if DEBUG_TYPE == "debug" then
            DEBUGGER.start()
        elseif DEBUG_TYPE == "record" then
            CONFIG.window.borderless = true
        end
    end
end

love.window.setTitle(CONFIG.title)

if CONFIG.icon then
    love.window.setIcon(CONFIG.icon)
end

-- Require files
-- Load libs and base
local libs = require "libs"
local base = require "base"

require "head.constants"
require "head.enums"
require "head.zmap"

-- Prevent any more globals
require "base.strict"

local StateManager = require "head.statemanager"

local stateManager, pause, fa, fan

function love.load()
    stateManager = StateManager()
end

function love.update(t)
    local dt = math.min(t, CONFIG.minFPS)

    dt = base.preUpdate(dt)
    libs.update(dt)

    if not fa or fan then
        if fa then
            fan = false
            dt = CONFIG.minFPS
        end
        stateManager:update(dt)
    end

    base.postUpdate(dt)
end

function love.draw()
    base.preDraw()
    libs.preDraw()

    stateManager:draw()

    libs.postDraw()
    base.postDraw()
end

function love.keypressed(key, scancode)
    if DEBUG then
        if key == "pause" then
            pause = not pause
        end
        if key == "f5" then
            love.load()
        end
        if key == "`" then
            love.event.quit()
        end

        if key == ";" then
            fa = not fa
        end

        if key == "." then
            fan = true
        end
    end

    base.keypressed(key)
end

function love.keyreleased(key, scancode)
    base.keyreleased(key)
end

function love.textinput(t)
end

function love.mousepressed(x, y, button)
    base.mousepressed(x, y, button)
end

function love.mousereleased(x, y, button)
    base.mousereleased(x, y, button)
end

function love.mousemoved(x, y)
    base.mousemoved(x, y)
end

function love.resize(w, h)
    libs.resize(w, h)
    base.resize(w, h)
end

function love.wheelmoved(x, y)
    base.wheelmoved(x, y)
end

function love.gamepadpressed(joystick, button)
    base.gamepadpressed(joystick, button)
end

function love.gamepadreleased(joystick, button)
    base.gamepadreleased(joystick, button)
end

function love.gamepadaxis(joystick, axis, value)
    base.gamepadaxis(joystick, axis, value)
end

function love.quit()
end
