local _M = {}

function _M:ctor(x, y)
	self.position = Vector2(x, y)

	self.moving = false
end

return _M