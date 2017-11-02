local _M = ecs.newcom('transform')
function _M:ctor(pos)
	self.position = Vector2(pos[1], pos[2])
	self.direction = Vector2(0, 0)
	self.face = Vector2(0, 1)
	self.moving = false
	self.speed = 7
end