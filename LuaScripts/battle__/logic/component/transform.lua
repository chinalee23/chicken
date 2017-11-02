local _M = ecs.component('transform')

function _M:ctor( ... )
	self.position = Vector2(0, 0)
	self.direction = Vector2(0, 0)
end

return _M