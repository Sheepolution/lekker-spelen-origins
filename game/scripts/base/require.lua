local require = require
return function (name, path, back)
	if not path then return require(name) end

	if path:find("init") then
		return require((path):gsub('%.init$', '') .. "." .. name)
	end
	for i=1, 1 + (back or 0) do
		path = path:gsub('%.[^%.]+$', '')
	end

	return require(path .. "." .. name)
end