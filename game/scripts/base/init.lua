_ = require "base.utils"

for __, v in ipairs({
	"all",
	"any",
	"same",
}) do
	list[v] = _[v]
end

local Mouse = require "base.mouse"
local Input = require "base.input"
local libs = require "libs"
oldprint = print
require "base.error"

require = require "base.require"
-- Redefine standard functions
print = DEBUG and
	function(...)
		_.print(1, ...)
	end or _.noop

if not DEBUG then
	assert:nop()
end

if OS.WEB then
	CONFIG.resizable = false

	CONFIG.windowScale = .5
	CONFIG.window.width = CONFIG.baseWidth * CONFIG.windowScale
	CONFIG.window.height = CONFIG.baseHeight * CONFIG.windowScale
end

love.graphics.setDefaultFilter(CONFIG.defaultGraphicsFilter, CONFIG.defaultGraphicsFilter)

libs.push:setupScreen(CONFIG.gameWidth, CONFIG.gameHeight, CONFIG.window.width, CONFIG.window.height,
	{
		fullscreen = CONFIG.window.fullscreen,
		fullscreentype = CONFIG.window.fullscreentype,
		vsync = CONFIG.window.vsync,
		msaa = CONFIG.window.msaa,
		stencil = CONFIG.window.stencil,
		depth = CONFIG.window.depth,
		resizable = CONFIG.window.resizable,
		borderless = CONFIG.window.borderless,
		centered = CONFIG.window.centered,
		display = CONFIG.window.display,
		minwidth = CONFIG.window.minwidth,
		minheight = CONFIG.window.minheight,
		highdpi = CONFIG.window.highdpi,
		usedpiscale = CONFIG.window.usedpiscale,
		pixelperfect = true,
		x = CONFIG.window.x,
		y = CONFIG.window.y,
	})

require "base.globals"

--Tools
local profiler

if DEBUG_TYPE == "test" or DEBUG_TYPE == "debug" then
	DEBUG_INFO = require("base.debuginfo")()
elseif DEBUG_TYPE == "profile" then
	profiler = require("base.profiler")()
end

local base = {}

function base.preUpdate(dt)
	if DEBUG_INFO then
		DEBUG_INFO:preUpdate(dt)
	end

	if DEBUG then
		if Input:isDown("tab") then
			if Input:isPressed("t") then
				DEBUG_INFO:toggle()
			end

			if Input:isDown("0") then
				dt = 0
			elseif Input:isDown("1") then
				dt = dt * .1
			else
				for i = 2, 5 do
					if Input:isDown(i .. "") then
						dt = dt * i
						break
					end
				end
			end
		end
	end

	Input:update(dt)
	Mouse:update(dt)
	return dt
end

function base.postUpdate(dt)
	if DEBUG then
		if Input:isDown("lctrl") and Input:isDown("q") then
			love.event.quit()
		end
	end

	Input:_reset()
	Mouse:_reset()

	if DEBUG_INFO then
		DEBUG_INFO:postUpdate(dt)
	end

	if profiler then
		profiler:update(dt)
	end
end

function base.preDraw()
	if DEBUG_INFO then
		DEBUG_INFO:preDraw()
	end

	CANVAS:clear()
end

function base.postDraw()
	love.graphics.origin()

	CANVAS:drawCanvas()

	if DEBUG_INFO then
		DEBUG_INFO:postDraw()
	end

	if profiler then
		profiler:draw()
	end
end

function base.keypressed(key)
	Input:_inputPressed(key)
end

function base.keyreleased(key)
	Input:_inputReleased(key)
end

function base.mousepressed(x, y, button)
	Mouse:_inputPressed(button)
end

function base.mousereleased(x, y, button)
	Mouse:_inputReleased(button)
end

function base.mousemoved(x, y)
end

function base.textinput()
end

function base.resize(w, h)
	CANVAS:onWindowResize(w, h)
end

function base.wheelmoved(x, y)
	local a = y == 0 and x or y
	Mouse:_inputPressed(a >= 0 and "wu" or "wd")
end

function base.gamepadpressed(joystick, button)
	local id = joystick:getID()
	base.keypressed("c" .. id .. "_" .. button)
end

function base.gamepadreleased(joystick, button)
	local id = joystick:getID()
	base.keyreleased("c" .. id .. "_" .. button)
end

function base.gamepadaxis(joystick, axis, value)
	Input:_handleGamepadAxis(joystick, axis, value)
end

function warning(msg, tb)
	_.debug(tb or 1, "[WARNING] -", msg)
end

function info(msg, tb)
	_.debug(tb or 1, "[INFO] -", msg)
end

--prints on n stacks back
function bprint(n, ...)
	_.debug(n, ...)
end

--prints if a is true
function printif(a, ...)
	if not a then return end
	_.debug(1, ...)
end

return base
