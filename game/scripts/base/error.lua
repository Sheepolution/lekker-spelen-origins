local utf8 = require("utf8")
local print = print

local function error_printer(msg, layer)
	print(debug.traceback("Error: " .. tostring(msg), 1 + (layer or 1)):gsub("\n[^\n]+$", ""):gsub("scripts/",
		"./game/scripts/"))
end

function love.errorhandler(msg)
	msg = tostring(msg)

	error_printer(msg, 2)

	if DEBUG then
		if DEBUG_TYPE ~= "debug" then
			DEBUGGER.start()
		end

		error(msg, 2)

		return function() return 1 end
	end

	if not love.window or not love.graphics or not love.event then
		return
	end

	if not love.window.isOpen() then
		local success, status = pcall(love.window.setMode, 800, 600)
		if not success or not status then
			return
		end
	end

	-- Reset state.
	if love.mouse then
		love.mouse.setVisible(true)
		love.mouse.setGrabbed(false)
		love.mouse.setRelativeMode(false)
		if love.mouse.isCursorSupported() then
			love.mouse.setCursor()
		end
	end
	if love.joystick then
		-- Stop all joystick vibrations.
		for i, v in ipairs(love.joystick.getJoysticks()) do
			v:setVibration()
		end
	end
	if love.audio then love.audio.stop() end

	love.graphics.reset()
	local fontBig = love.graphics.newFont(24)
	local font = love.graphics.setNewFont(14)

	local copied = false

	love.graphics.setColor(1, 1, 1, 1)

	local trace = debug.traceback()

	love.graphics.origin()

	local sanitizedmsg = {}
	for char in msg:gmatch(utf8.charpattern) do
		table.insert(sanitizedmsg, char)
	end
	sanitizedmsg = table.concat(sanitizedmsg)

	local err = {}

	table.insert(err, sanitizedmsg)

	if #sanitizedmsg ~= #msg then
		table.insert(err, "Invalid UTF-8 string in error message.")
	end

	table.insert(err, "\n")

	for l in trace:gmatch("(.-)\n") do
		if not l:match("boot.lua") then
			l = l:gsub("stack traceback:", "Traceback\n")
			table.insert(err, l)
		end
	end

	local p = table.concat(err, "\n")

	p = p:gsub("\t", "")
	p = p:gsub("%[string \"(.-)\"%]", "%1")

	local function draw()
		local pos = 70

		local width = love.graphics.getWidth() - pos * 4
		love.graphics.clear(12 / 255, 12 / 255, 12 / 255)
		if copied then
			love.graphics.setColor(.4, .9, .4)
		else
			love.graphics.setColor(.9, .9, .9)
		end

		love.graphics.rectangle("fill", pos * 2 + 10, pos * 3 - 40, 162, 10000, 10, 10)
		love.graphics.setColor(48 / 255, 48 / 255, 48 / 255)
		love.graphics.rectangle("fill", pos * 2 - 10, pos * 3 - 12, width, 1000, 20, 20)
		love.graphics.setColor(1, 1, 1)
		love.graphics.setFont(fontBig)
		love.graphics.printf("- #FIASCO -", 0, 10, love.graphics.getWidth(), "center")
		love.graphics.setFont(font)
		love.graphics.printf(
			"De game is gecrasht door een error.\n\nSheeeeeeeeeeeeeep!!\n\nMaar geen zorgen. Je progressie is opgeslagen!\n(Als het goed is...)",
			50, 63, love.graphics.getWidth() - 100, "center")
		love.graphics.printf(p, pos * 2, pos * 3, love.graphics.getWidth() - pos * 4)
		love.graphics.setColor(.1, .1, .1)
		love.graphics.print(copied and "Copied!" or "Press Ctrl + C to copy", pos * 2 + 15, pos * 3 - 33)
		love.graphics.present()
	end

	local fullErrorText = p
	local function copyToClipboard()
		if not love.system then return end
		love.system.setClipboardText(fullErrorText)
		copied = true
		draw()
	end

	return function()
		love.event.pump()

		for e, a, b, c in love.event.poll() do
			if e == "quit" then
				return 1
			elseif e == "keypressed" and a == "escape" then
				return 1
			elseif e == "keypressed" and a == "c" and love.keyboard.isDown("lctrl", "rctrl") then
				copyToClipboard()
			elseif e == "touchpressed" then
				local name = love.window.getTitle()
				if #name == 0 or name == "Untitled" then name = "Game" end
				local buttons = { "OK", "Cancel" }
				if love.system then
					buttons[3] = "Copy to clipboard"
				end
				local pressed = love.window.showMessageBox("Quit " .. name .. "?", "", buttons)
				if pressed == 1 then
					return 1
				elseif pressed == 3 then
					copyToClipboard()
				end
			end
		end

		draw()

		if love.timer then
			love.timer.sleep(0.1)
		end
	end
end
