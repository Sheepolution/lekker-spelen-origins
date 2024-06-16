local wrap = {}

function wrap.new(obj)
	return setmetatable({ obj = obj, chain = wrap.chain }, wrap)
end

function wrap:__index(f)
	return function(obj, ...)
		local a = { ... }
		return function(...)
			local b = { ... }
			for i, v in ipairs(a) do
				table.insert(b, i, v)
			end
			return self.obj[f](self.obj, unpack(b))
		end
	end
end

function wrap:__call(s, t)
	if not t then
		t = s
		s = self.obj
	end
	return function()
		for k, v in pairs(t) do
			s[k] = v
		end
	end
end

local chain_mt = {}

function chain_mt:__index(f)
	return function(obj, ...)
		local a = { ... }
		self[#self + 1] = function(...)
			local b = { ... }
			for i, v in ipairs(b) do
				table.insert(a, v)
			end
			return self.obj[f](self.obj, unpack(a))
		end
		return self
	end
end

function chain_mt:__call(s, t)
	if not t then
		t = s
		s = self.obj
	end
	self[#self + 1] = function()
		for k, v in pairs(t) do
			s[k] = v
		end
	end
	return self
end

function chain_mt:done()
	return function()
		for i, v in ipairs(self) do
			v()
		end
	end
end

function wrap:chain()
	return setmetatable({ obj = self.obj, done = chain_mt.done }, chain_mt)
end

return wrap
