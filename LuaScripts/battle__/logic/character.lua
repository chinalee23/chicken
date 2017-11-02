local _M = {}

function _M:ctor(data)
	self.id = data.id
	
	self.position = Vector2(data.pos[1], data.pos[2])

	self.inorigin = true
	self.direction = Vector2(0, 0)
	
	self.generalAgentIndex = -1
	self.generalObstacleIndex = -1
	self.agents = {}
	self.layers = {}

	self.moving = false
end

return _M