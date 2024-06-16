local _ = require "base.utils"
local Class = require "base.class"

local Locator = Class:extend("Locator")

function Locator:findTargets(a)
	local filter = a
	local targets = self.scene:findEntities(filter)
	if #targets == 1 then
		self:onSingleTarget(targets[1])
	elseif #targets > 0 then
		self:onFindingTargets(targets)
	end
end

function Locator:onFindingTargets(targets)
	self:onFindingTarget(self:filterToNearest(targets))
end

function Locator:onSingleTarget(target)
	self:onFindingTarget(target)
end

function Locator:filterToNearest(targets)
	local sdist
	local target
	for i, v in ipairs(targets) do
		ndist = _.distance(self.x, self.y, self.target.x, self.target.y)
		if not sdist or ndist < sdist then
			sdist = ndist
			target = v
		end
	end
	return target
end

function Locator:findTarget(a)
	local filter = a
	local target = self.scene:findEntity(filter)
	if target then
		self:onFindingTarget(target)
	end
end

function Locator:onFindingTarget()

end

return Locator
