local _M = ecs.newcom('transform')
function _M:ctor(pos)
	self.position = Vector2(pos[1], pos[2])
	self.direction = Vector2(0, 0)
	self.moving = false
end