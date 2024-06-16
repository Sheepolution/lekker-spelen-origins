local _ = require "base.utils"
local Asset = require "base.asset"
local Shader = require "base.shader"
local Flow = require "base.components.flow"
local Animation = require "base.animation"
local Point = require "base.point"
local Rect = require "base.rect"

local math_round = _.round
local identity = _.identity

local Sprite = Rect:extend("Sprite")

Sprite:implement(Flow)

Sprite._quadCache = {}
Sprite._jsonCache = {}
Sprite.borderCache = {}

local borderShader = Shader.new("border")

function Sprite:new(x, y, img, width, height, margin, byframes)
	Sprite.super.new(self, x, y)

	self.z = ZMAP[self.tag] or 0
	self.anim = Animation()

	self.offset = Point(0, 0)
	self._offsetList = {}
	self.scale = Point(1, 1)
	self.origin = Point(0, 0)
	self.shear = Point(0, 0)
	self.margin = 0

	self.border = Point(0, 0)
	self.border._color = { 255, 255, 255 }
	self.border.auto = true

	self.alpha = 1

	self.angle = 0
	self.angleOffset = 0
	self.rotation = 0
	self.flip = { x = false, y = false }

	self.visible = true
	self.parent = nil

	self.blend = nil
	self.blendAlpha = "premultiplied"

	self.shader = nil
	self._shaders = {}
	self.shaderTimer = 0
	self.shaderSpeed = 1

	self.events = {}

	self._masks = {}

	self._frames = {}

	self.rounding = true

	if type(img) == "string" or (img and img.typeOf and img:typeOf("Texture")) then
		self:setImage(img, width, height, margin, byframes)
	end

	Flow.new(self)
end

function Sprite:update(dt)
	if DEBUG then
		if not self._addedBorder then
			if self.imageName and Asset._imageCache[self.imageName] ~= self.image then
				local image = Asset._imageCache[self.imageName]
				if image then
					self.image = image
				end
			end
		end
	end

	self.anim:update(dt)

	self:rotate(dt)

	if self.shader then
		for i, v in ipairs(self._shaders[self.shader].names) do
			if Shader.has(v, "rnd") then
				self:send(v .. "_rnd", math.random())
			end

			if Shader.has(v, "time") then
				self.shaderTimer = self.shaderTimer + self.shaderSpeed * dt
				self:send(v .. "_time", self.shaderTimer)
			end
		end
	end

	if #self._offsetList > 0 then
		for i = #self._offsetList, 1, -1 do
			if self._offsetList[i].destroyed or self._offsetList[i].once then
				table.remove(self._offsetList, i)
			end
		end
	end

	Flow.update(self, dt)
end

function Sprite:draw()
	local pos = self.rounding and math_round or identity

	if not self.visible or self.alpha == 0 then
		return
	end

	if #self._masks > 0 then
		love.graphics.push("all")
		love.graphics.setCanvas(self._maskCanvas)
		love.graphics.clear()
		love.graphics.origin()
		for i, v in ipairs(self._masks) do
			v:draw()
		end
		love.graphics.pop()
		self:send("mask_gradient_image", self._maskCanvas)
	end

	if self.blend then love.graphics.setBlendMode(self.blend, self.blendAlpha) end
	if self.shader then love.graphics.setShader(self._shaders[self.shader].shader) end

	local r, g, b, a = self._color[1], self._color[2], self._color[3], self.alpha
	local color = r + g + b + a < 4
	color = true
	-- FIX
	if color then
		love.graphics.setColor(r, g, b, a)
	end

	local hasBorder = self:hasBorder()
	if hasBorder or self.singleColor then
		love.graphics.push()
		love.graphics.translate(
			pos(self.x + self.origin.x + self.offset.x - self.margin),
			pos(self.y + self.origin.y + self.offset.y - self.margin))

		love.graphics.rotate(self.angle + self.angleOffset)
		love.graphics.scale(
			self.scale.x * (self.flip.x and -1 or 1),
			self.scale.y * (self.flip.y and -1 or 1))

		if self.singleColor then
			self:drawSingleColor()
		elseif hasBorder then
			self:drawBorder()
			self:drawImage(true)
		end

		love.graphics.pop()
	else
		self:drawImage()
	end

	if self.blend then love.graphics.setBlendMode("alpha") end
	if self.shader then love.graphics.setShader() end

	if color then
		love.graphics.setColor(1, 1, 1, 1)
	end
end

function Sprite:drawImage(hasBorder)
	if self.image then
		local pos = self.rounding and math_round or identity
		local offsetX, offsetY = self:getOffset()

		if self.anim.hasAnimation then
			if self.anim.frame < 1 or self.anim.frame > #self.anim._current.frames then
				warning("Frame out of range! Frame: " ..
					self.anim.frame .. ", Max: " .. #self.anim._current.frames .. " Anim: " .. self.anim:get())
			end

			if hasBorder then
				love.graphics.draw(self.image,
					self._frames[self.anim._current.frames and self.anim._current.frames[self.anim.frame] or 1],
					0, 0,
					0,
					1, 1,
					pos(self.origin.x), pos(self.origin.y),
					self.shear.x, self.shear.y)
			else
				love.graphics.draw(self.image,
					self._frames[self.anim._current.frames and self.anim._current.frames[self.anim.frame] or 1],
					pos(self.x + self.origin.x + offsetX),
					pos(self.y + self.origin.y + offsetY),
					self.angle + self.angleOffset,
					self.scale.x * (self.flip.x and -1 or 1), self.scale.y * (self.flip.y and -1 or 1),
					pos(self.origin.x + self.margin), pos(self.origin.y + self.margin),
					self.shear.x, self.shear.y)
			end
		else
			if hasBorder then
				love.graphics.draw(self.image, self._frames[1],
					0, 0,
					0,
					1, 1,
					pos(self.origin.x + self.margin), pos(self.origin.y + self.margin),
					self.shear.x, self.shear.y)
			else
				love.graphics.draw(self.image,
					pos(self.x + self.origin.x + offsetX - self.margin),
					pos(self.y + self.origin.y + offsetY - self.margin),
					self.angle + self.angleOffset,
					self.scale.x * (self.flip.x and -1 or 1), self.scale.y * (self.flip.y and -1 or 1),
					pos(self.origin.x + self.margin), pos(self.origin.y + self.margin),
					self.shear.x, self.shear.y)
			end
		end
	else
		love.graphics.push()
		love.graphics.translate(self.offset.x, self.offset.y)
		Sprite.super.draw(self)
		love.graphics.pop()
	end
end

function Sprite:getDrawCoordinates(center)
	local pos = self.rounding and math_round or identity
	local offsetX, offsetY = self:getOffset()
	local ox, oy = pos(self.origin.x + self.margin), pos(self.origin.y + self.margin)
	return pos(self.x + self.origin.x + offsetX) - ox + (center and self.width / 2 or 0),
		pos(self.y + self.origin.y + offsetY) - oy + (center and self.height / 2 or 0)
end

function Sprite:drawImageSimple(x, y, r, sx, sy, ox, oy, kx, ky)
	if self.anim.hasAnimation then
		if self.anim.frame < 1 or self.anim.frame > #self.anim._current.frames then
			warning("Frame out of range! Frame: " ..
				self.anim.frame .. ", Max: " .. #self.anim._current.frames .. " Anim: " .. self.anim:get())
		end
	end

	love.graphics.draw(self.image,
		self._frames[1],
		x or self.x + self.offset.x + self.origin.x, y or self.y + self.offset.y + self.origin.y,
		r or self.angle,
		(sx or self.scale.x) * (self.flip.x and -1 or 1), (sy or self.scale.y) * (self.flip.y and -1 or 1),
		ox or self.origin.x, oy or self.origin.y,
		kx or self.shear.x, ky or self.shear.y)
end

function Sprite:drawBorder()
	borderShader:send("border_color", self.border._color)
	love.graphics.setShader(borderShader)
	for i = -self.border.x, self.border.x, self.border.x do
		for j = -self.border.y, self.border.y, self.border.y do
			love.graphics.translate(i, j)
			self:drawImage(true)
			love.graphics.translate(-i, -j)
		end
	end
	love.graphics.setShader()
end

function Sprite:drawSingleColor()
	borderShader:send("border_color", self.singleColor)
	love.graphics.setShader(borderShader)
	self:drawImage(true)
	love.graphics.setShader()
end

function Sprite:hasBorder()
	return self.border.auto and (self.border.x ~= 0 or self.border.y ~= 0)
end

local function get_quads_from_json(json, margin)
	local sourceWidth = json.meta.size.w
	local sourceHeight = json.meta.size.h
	local quads = {}
	for i, v in ipairs(json.frames) do
		local frame = v.frame
		quads[i] = love.graphics.newQuad(frame.x + math_round(margin / 2), frame.y + math_round(margin / 2),
			frame.w - math_round(margin / 2) * 2,
			frame.h - math_round(margin / 2) * 2,
			sourceWidth, sourceHeight)
	end

	return quads
end

function Sprite:setImage(path, width, height, margin, byframes)
	if type(path) == "string" then
		self.imageName = path
		self.image = Asset.image(path)
		self.imageData = Asset.imageData(path)
	else
		self.image = path
	end
	self._frames = {}

	self.image:setFilter(CONFIG.defaultGraphicsFilter, CONFIG.defaultGraphicsFilter)

	if (width == true) then
		local json_path = "assets/images/" .. path .. ".json"
		local json_info = love.filesystem.getInfo(json_path)
		assert(json_info, "Was not able to find JSON file '" .. json_path, 2)
		local data = json.decode(love.filesystem.read(json_path))
		self.imgWidth = data.meta.size.w
		self.imgHeight = data.meta.size.h
		margin = (data.frames[1].frame.w - data.frames[1].spriteSourceSize.w) / 2
		self.margin = math.floor(margin / 2)

		self.width = data.frames[1].frame.w - margin * 2
		self.height = data.frames[1].frame.h - margin * 2

		if Sprite._quadCache[path] then
			self._frames = Sprite._quadCache[path]
		else
			self._frames = get_quads_from_json(data, margin)
			Sprite._quadCache[path] = self._frames
		end

		self.anim:_setFrames(self._frames)
		self.anim:_addFromJson(data)
	else
		margin = margin or (width and 1 or 0)
		self.margin = margin
		local spacing = margin * 2

		width = width or 1

		local imgWidth, imgHeight
		imgWidth = self.image:getWidth()
		imgHeight = self.image:getHeight()
		self.imgWidth = imgWidth
		self.imgHeight = imgHeight

		local fullWidth
		local fullHeight

		local pos = self.rounding and math_round or identity
		if byframes ~= false then
			width = imgWidth / width
			if width > pos(width) then
				warning(tostring(self) .. " - Width is not an even number?", 4)
			end

			height = height and imgHeight / height or imgHeight

			fullWidth = width
			fullHeight = height
		else
			width = width or imgWidth
			height = height or imgHeight
			fullWidth = width + spacing
			fullHeight = height + spacing
		end

		local hor = imgWidth / fullWidth
		local ver = imgHeight / fullHeight

		if width then
			assert(pos(hor) == hor,
				"The given width + margin (" ..
				fullWidth .. ") doesn't round up with the image width (" .. imgWidth .. ")", 2)
			assert(pos(ver) == ver,
				"The given height + margin (" ..
				fullHeight .. ") doesn't round up with the image height (" .. imgHeight .. ")", 2)
		end

		if Sprite._quadCache[path] then
			self._frames = Sprite._quadCache[path]
		else
			local t = {}
			for i = 0, ver - 1 do
				for j = 0, hor - 1 do
					table.insert(self._frames,
						love.graphics.newQuad(margin + j * fullWidth, margin + i * fullHeight, width, height, imgWidth,
							imgHeight))
				end
			end
			Sprite._quadCache[path] = self._frames
		end

		self.width = width - spacing
		self.height = height - spacing

		self.anim:_setFrames(self._frames)
	end

	self:centerOrigin()

	return self
end

local dirs_8 = { { -1, -1 }, { 0, -1 }, { 1, -1 }, { -1, 0 }, { 1, 0 }, { -1, 1 }, { 0, 1 }, { 1, 1 } }
local dirs_4 = { { 0, -1 }, { -1, 0 }, { 1, 0 }, { 0, 1 } }

function Sprite:addBorder(color, eight)
	if DEBUG then
		self._addedBorder = true
	end

	if eight == nil then eight = true end

	local dirs

	if eight then
		dirs = dirs_8
	else
		dirs = dirs_4
	end

	if not color then color = { 1, 1, 1 } end

	if Sprite.borderCache[self.image] then
		self.image = Sprite.borderCache[self.image]
		return
	end
	local old_img = self.image
	local img_data = self.imageData
	local new_img = love.image.newImageData(img_data:getWidth(), img_data:getHeight())

	img_data:mapPixel(function(x, y, r, g, b, a)
		if a > 0 and x > 0 and y > 0 and x < img_data:getWidth() - 1 and y < img_data:getHeight() - 1 then
			for i, v in ipairs(dirs) do
				new_img:setPixel(x + v[1], y + v[2], color[1], color[2], color[3], 1)
			end
		end
		return r, g, b, a
	end)

	img_data:mapPixel(function(x, y, r, g, b, a)
		if a > 0 then
			new_img:setPixel(x, y, r, g, b, a)
		end
		return r, g, b, a
	end)

	self.image = love.graphics.newImage(new_img)
	Sprite.borderCache[old_img] = self.image
end

function Sprite:changeColors(mapping, force)
	local old_img, img_data

	if self.imageName and force then
		old_img = Asset.image(self.imageName, true)
		img_data = Asset.imageData(self.imageName, true)
	else
		old_img = self.image
		img_data = self.imageData
	end
	-- if cache[self.image] then self.image = cache[self.image] return end
	local new_img = love.image.newImageData(img_data:getWidth(), img_data:getHeight())

	img_data:mapPixel(function(x, y, r, g, b, a)
		for i, v in ipairs(mapping) do
			if r == v.from[1] and g == v.from[2] and b == v.from[3] then
				return v.to[1] / 255, v.to[2] / 255, v.to[3] / 255, a
			end
		end
		return r, g, b, a
	end)

	img_data:mapPixel(function(x, y, r, g, b, a)
		if a > 0 then
			new_img:setPixel(x, y, r, g, b, a)
		end
		return r, g, b, a
	end)

	img_data:paste(new_img, 0, 0, 0, 0, new_img:getWidth(), new_img:getHeight())
	self.image = love.graphics.newImage(new_img)
	Sprite.borderCache[old_img] = self.image
end

function Sprite:centerOrigin()
	self.origin.x = self.width / 2
	self.origin.y = self.height / 2
end

function Sprite:centerOffset()
	self.offset.x = -self.width / 2
	self.offset.y = -self.height / 2
end

function Sprite:getOffset()
	local offsetX, offsetY = self.offset.x, self.offset.y

	for i, v in ipairs(self._offsetList) do
		offsetX = offsetX + v.x
		offsetY = offsetY + v.y
	end

	return offsetX, offsetY
end

function Sprite:addOffset(x, y)
	if not y then
		if type(x) == "table" then
			y = x.y
			x = x.x
		else
			y = x
		end
	end

	local offset = Point(x, y)
	table.insert(self._offsetList, offset)
	return offset
end

function Sprite:getRelativePosition(x, y)
	local xx, yy = self:centerX(), self:centerY()
	return xx + (self.flip.x and -x or x), yy + (self.flip.y and -y or y)
end

function Sprite:setFilter(filter)
	self.image:setFilter(filter, filter)
end

function Sprite:setBlend(blend)
	self.blend = blend

	if ("multiply_lighten_darken"):find(blend) then
		self.blendAlpha = "premultiplied"
	else
		self.blendAlpha = "alphamultiply"
	end
end

function Sprite:setVisible(visible)
	self.visible = visible
end

function Sprite:addShader(name, ...)
	local list = { ... }
	if not ... then list = { name } end
	self._shaders[name] = { shader = Shader.new(unpack(list)), names = list }
	self.shader = name
end

function Sprite:setShader(name)
	self.shader = name
end

function Sprite:removeShader(name, ...)
	self._shaders[name] = nil
	if self.shader == name then
		self.shader = nil
	end
end

function Sprite:send(extern, ...)
	if not self.shader then return end
	-- assert(self.shader, "You haven't set a shader!", 2)
	if not extern:find("_") then
		local names = self._shaders[self.shader].names
		if #names == 1 then
			extern = names[1] .. "_" .. extern
		else
			for i, v in ipairs(names) do
				if Shader.has(v, extern) then
					self._shaders[self.shader].shader:send(v .. "_" .. extern, ...)
				end
			end
			return
		end
	end

	if self.shader then
		self._shaders[self.shader].shader:send(extern, ...)
	end
end

local function clone_props(obj, k, v)
	if k == "flip" then
		obj.flip.x = v.x
		obj.flip.y = v.y
	elseif k == "color" then
		if v then
			obj._color = { unpack(v) }
		end
	else
		obj[k] = v
	end
end

function Sprite:drawAsChild(p, props, kind, fromtopleft)
	-- kind = true means copy NO properties except the properties in props
	-- kind = false means copy ALL properties except the properties in props

	if kind == nil then
		if props then
			if props == true then
				kind = "all"
			elseif props == false then
				kind = "none"
			else
				kind = "specific"
			end
		else
			kind = "none"
		end
	elseif not kind then
		kind = "all_except"
	elseif kind then
		kind = "none_except"
	end

	local all_props = { "offset", "flip", "visible", "color", "alpha", "angle", "angleOffset" }

	local parent = p or self.parent
	assert(parent, "Please assign a parent", 2)

	if parent then
		local px, py = parent:center()
		local nx, ny = px - self.width / 2 + parent.origin.x - _.floor(parent.origin.x),
			py - self.height / 2 + parent.origin.y - _.floor(parent.origin.y)
		local pox, poy = self:getOffset()

		if fromtopleft then
			px, py = parent:getDrawCoordinates()
			nx, ny = px, py
			pox, poy = self:getOffset()
		end

		if kind == "none" then
			love.graphics.push()
			love.graphics.translate(math_round(nx), math_round(ny))
			local x, y = self.x, self.y
			self.x = parent.flip.x and -x or x
			self.y = parent.flip.y and -y or y
			self:draw()
			love.graphics.pop()
			self.x, self.y = x, y
		else
			local x, y = self.x, self.y
			local flip_x, flip_y = self.flip.x, self.flip.y
			local visible = self.visible
			local color = { unpack(self._color) }
			local alpha = self.alpha
			local angle = self.angle
			local angleOffset = self.angleOffset

			if kind == "specific" then
				for k, v in pairs(props) do
					self[k] = v
				end
			elseif kind == "none_except" then
				for i, v in ipairs(props) do
					if v == "offset" then
						nx = nx + pox
						ny = ny + poy
					else
						clone_props(self, v, parent[v])
					end
				end
			elseif kind == "all_except" then
				for i, v in ipairs(all_props) do
					if not _.any(props, function(a) return a == v end) then
						if v == "offset" then
							nx = nx + pox
							ny = ny + poy
						else
							clone_props(self, v, parent[v])
						end
					end
				end
			elseif kind == "all" then
				for i, v in ipairs(all_props) do
					if v == "offset" then
						nx = nx + pox
						ny = ny + poy
					else
						clone_props(self, v, parent[v])
					end
				end
			end

			if parent.flip.x then
				self.x = -x
			end

			if parent.flip.y then
				self.y = -y
			end

			local animOffset = parent.anim:getOffset()
			nx = nx + animOffset.x
			ny = ny + animOffset.y

			love.graphics.push()
			love.graphics.translate(math_round(nx), math_round(ny))
			self:draw()
			love.graphics.pop()

			self.x, self.y = x, y
			self.flip.x, self.flip.y = flip_x, flip_y
			self.visible = visible
			self._color = color
			self.alpha = alpha
			self.angle = angle
			self.angleOffset = angleOffset
		end
	end
end

function Sprite:addMask(mask)
	table.insert(self._masks, mask)
	if #self._masks == 1 then
		self._maskCanvas = love.graphics.newCanvas(self.width, self.height)
		self:addShader("mask_gradient")
	end
end

function Sprite:shake(intensity, time, force, outer)
	if force then
		if self.events.shake then
			self.events.shake:stop()
			self.events.shake = nil
		end
	end
	if not self.events.shake then
		self.events.shake = self:event(function()
			for i = 1, time / 0.05 do
				if outer then
					local oldOffsetX, oldOffsetY = self.offset.x, self.offset.y
					repeat
						if _.coin() then
							self.offset.x = _.coin() and -intensity or intensity
							self.offset.y = _.random(-intensity, intensity)
						else
							self.offset.x = _.random(-intensity, intensity)
							self.offset.y = _.coin() and -intensity or intensity
						end
					until self.offset.x ~= oldOffsetX and self.offset.y ~= oldOffsetY
				else
					self.offset:set(_.random(-intensity, intensity), _.random(-intensity, intensity))
				end
				self.coil.wait(0.05)
			end
			self.events.shake = nil
			self.offset:set(0, 0)
		end, 0, 1)
	end
end

function Sprite:rotate(dt)
	if self.rotation ~= 0 then
		self.angle = self.angle + self.rotation * dt
		if self.angle < -PI then self.angle = self.angle + PI * 2 end
		if self.angle > PI then self.angle = self.angle - PI * 2 end
	end
end

function Sprite:rotateTowards(e, amount)
	self.angle = _.rotate(self.angle, self:getAngle(e), amount)
end

function Sprite:setAngle(angle)
	self.angle = angle
	if self.angle < -PI then self.angle = self.angle + PI * 2 end
	if self.angle > PI then self.angle = self.angle - PI * 2 end
end

function Sprite:lookAtAngle(e)
	self.angle = self:getAngle(e)
end

function Sprite:positionToAngle(x, y, angle, distance)
	self.x = x
	self.y = y
	local cos = math.cos(angle)
	local sin = math.sin(angle)
	self.x = self.x + cos * distance
	self.y = self.y + sin * distance
end

function Sprite:positionToAngleCenter(x, y, angle, distance)
	local cos = math.cos(angle)
	local sin = math.sin(angle)
	self:centerX(x + cos * distance)
	self:centerY(y + sin * distance)
end

function Sprite:getRelativeAnglePosition(angle, distance)
	local x, y = self:center()
	local cos = math.cos(angle)
	local sin = math.sin(angle)
	x = x + cos * distance
	y = y + sin * distance

	return x, y
end

return Sprite
