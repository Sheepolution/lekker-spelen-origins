local _ = require "base.utils"
local Class = require "base.class"

local Input = Class:extend("Input")

Input.doublePressTime = 0.25
Input.analogTreshhold = 0.5

function Input:new()
	self._class = Input
	self._pressed = {}
	self._released = {}
	self._custom = {}
	self._lastPressed = {}
	self._gamepadAnalogPresses = {}

	local findPressed = function(b) return _.find(self._pressed, b) end
	self._isPressedCheck = function(a) return self._custom[a] and _.any(self._custom[a], findPressed) end

	local findDoublePressed = function(b) return _.find(self._pressed, b) and self._lastPressed[b] end
	self._isDoublePressedCheck = function(a) return self._custom[a] and _.any(self._custom[a], findDoublePressed) end

	local findReleased = function(b) return _.find(self._released, b) end
	self._isReleasedCheck = function(a) return self._custom[a] and _.any(self._custom[a], findReleased) end

	local findDown = function(b)
		if #b > 1 and b:find("_") then
			return CONFIG.gamepadSupport and self:_gamepadIsDown(b)
		else
			return love.keyboard.isScancodeDown(b)
		end
	end
	self._isDownCheck = function(a) return self._custom[a] and _.any(self._custom[a], findDown) end
end

function Input:update(dt)
	for k, v in pairs(self._lastPressed) do
		local t = v - dt
		if t <= 0 then
			self._lastPressed[k] = nil
		else
			self._lastPressed[k] = t
		end
	end
end

function Input:isPressed(...)
	local t = { ... }
	if type(t[1]) == "table" then
		t = t[1]
	end
	return _.any(t, self._isPressedCheck)
end

function Input:isDoublePressed(...)
	local t = { ... }
	if type(t[1]) == "table" then
		t = t[1]
	end
	return _.any(t, self._isDoublePressedCheck)
end

function Input:isReleased(...)
	local t = { ... }
	if type(t[1]) == "table" then
		t = t[1]
	end
	return _.any(t, self._isReleasedCheck)
end

function Input:isDown(...)
	local t = { ... }
	if type(t[1]) == "table" then
		t = t[1]
	end
	return _.any(t, self._isDownCheck)
end

function Input:map(t)
	for k, v in pairs(t) do
		self._custom[k] = v
	end
end

function Input:isAnyPressed()
	return #self._pressed > 0
end

function Input:getGamepadAxes(id, button, threshhold)
	for i, v in ipairs(love.joystick.getJoysticks()) do
		if id == v:getID() then
			local x, y
			if button == "trigger" then
				x, y = v:getGamepadAxis("triggerleft"), v:getGamepadAxis("triggerright")
			else
				x, y = v:getGamepadAxis(button .. "x"), v:getGamepadAxis(button .. "y")
			end

			if threshhold then
				return math.abs(x) >= Input.analogTreshhold and x or 0, math.abs(y) >= Input.analogTreshhold and y or 0
			else
				return x, y
			end
		end
	end
end

function Input:rumble(id, strength, length)
	for i, v in ipairs(love.joystick.getJoysticks()) do
		if v:getID() == id then
			if v:isVibrationSupported() then
				v:setVibration(strength or .25, strength or .25, length or .25)
			end
		end
	end
end

function Input:_inputPressed(input)
	table.insert(self._pressed, input)
	if not self._custom[input] then
		self._custom[input] = { input }
	end
end

function Input:_inputReleased(input)
	table.insert(self._released, input)
end

function Input:_reset()
	for i, v in ipairs(self._pressed) do
		self._lastPressed[v] = Input.doublePressTime
	end

	self._pressed = {}
	self._released = {}
end

function Input:_gamepadIsDown(input)
	local id, button = input:match("c(%d+)_(.+)")
	if not id then return end
	id = tonumber(id)

	for i, v in ipairs(love.joystick.getJoysticks()) do
		if id == v:getID() then
			if button == "triggerleft" then
				return self._gamepadAnalogPresses[id].triggerleft.pressed
			elseif button == "triggerright" then
				return self._gamepadAnalogPresses[id].triggerright.pressed
			elseif button:find("_") then
				local stick, direction = button:match("(.+)_(.+)")
				return self._gamepadAnalogPresses[id][stick][direction]
			end

			return v:isGamepadDown(button)
		end
	end
end

function Input:_handleGamepadAxis(joystick, axis, value)
	local id = joystick:getID()

	local gamepad = self._gamepadAnalogPresses[id]
	if not gamepad then
		gamepad = {}
		self._gamepadAnalogPresses[id] = gamepad
	end

	local simpleAxis = axis:find("trigger") and axis or axis:sub(1, -2)
	local gamepadAxis = gamepad[simpleAxis]
	if not gamepadAxis then
		gamepadAxis = {}
		gamepad[simpleAxis] = gamepadAxis
	end

	-- print(axis)

	if value <= -Input.analogTreshhold then
		if axis:find("x") then
			if not gamepadAxis.left then
				self:_inputPressed("c" .. id .. "_" .. simpleAxis .. "_left")
				gamepadAxis.left = true
			end
		else
			if not gamepadAxis.up then
				self:_inputPressed("c" .. id .. "_" .. simpleAxis .. "_up")
				gamepadAxis.up = true
			end
		end
	elseif value >= Input.analogTreshhold then
		if axis:find("trigger") then
			if not gamepadAxis.pressed then
				self:_inputPressed("c" .. id .. "_" .. simpleAxis)
				gamepadAxis.pressed = true
			end
		else
			if axis:find("x") then
				if not gamepadAxis.right then
					self:_inputPressed("c" .. id .. "_" .. simpleAxis .. "_right")
					gamepadAxis.right = true
				end
			else
				print("DOWN")
				print(value)
				if not gamepadAxis.down then
					self:_inputPressed("c" .. id .. "_" .. simpleAxis .. "_down")
					gamepadAxis.down = true
				end
			end
		end
	else
		if axis:find("trigger") then
			if gamepadAxis.pressed then
				self:_inputReleased("c" .. id .. "_" .. axis)
			end
			gamepadAxis.pressed = false
		elseif axis:find("x") then
			if gamepadAxis.left then
				self:_inputReleased("c" .. id .. "_" .. simpleAxis .. "_left")
			end

			if gamepadAxis.right then
				self:_inputReleased("c" .. id .. "_" .. simpleAxis .. "_right")
			end

			gamepadAxis.left = false
			gamepadAxis.right = false
		else
			if gamepadAxis.up then
				self:_inputReleased("c" .. id .. "_" .. simpleAxis .. "_up")
			end

			if gamepadAxis.down then
				self:_inputReleased("c" .. id .. "_" .. simpleAxis .. "_down")
			end

			gamepadAxis.up = false
			gamepadAxis.down = false
		end
	end
end

return Input()
