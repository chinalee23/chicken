local Vector2 = require 'math.vector2'

local _M = class()
function _M:ctor(minDot, maxDot)
	self.min = minDot
	self.max = maxDot
	
	self.center = (self.max + self.min) / 2
	self.radius = self.max - self.center
end

function _M:expend(length)
	local v = Vector2(length, length)
	return _M.new(self.min - v, self.max + v)
end

return _M