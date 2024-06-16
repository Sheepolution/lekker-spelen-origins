local Colors = {}

Colors.colors = {
	red = { 255, 0, 0 },
	lightred = { 255, 25, 25 },
	blue = { 0, 0, 255 },
	green = { 0, 255, 0 },
	pink = { 255, 0, 255 },
	cyan = { 0, 255, 255 },
	yellow = { 255, 255, 0 },
	orange = { 255, 255 / 2, 0 },
	cyangreen = { 0, 255, 255 / 2 },
	lime = { 255 / 2, 255, 0 },
	purple = { 255 / 2, 0, 255 },
	hotpink = { 255, 0, 255 / 2 },
	white = { 255, 255, 255 },
	black = { 0, 0, 0 }
}

Colors.__index = Colors
-- TODO: Change it so that you can do Colors.cyan. Use __index to return a unique table.

function Colors:__call(color, convert, aa)
	local r, g, b, a = unpack(Colors.colors[color])
	if convert then
		r = r / 255
		g = g / 255
		b = b / 255
	end
	return r, g, b, aa or a or 1
end

function Colors:add(name, r, g, b, a)
	self.colors[name] = { r, g, b, a }
end

return setmetatable({}, Colors)
