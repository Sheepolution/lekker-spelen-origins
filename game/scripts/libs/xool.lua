local xool = {}
xool.__index = xool

function xool.new(a)
	return setmetatable({ state = a and 2 or 0 }, xool)
end

function xool:__call(a)
	local oldstate = self.state
	if a then
		self.state = 2

		return oldstate > 0
	elseif a == false then
		self.state = self.state == 2 and 1 or 0

		return oldstate == 1
	end

	return self.state > 0
end

return xool
