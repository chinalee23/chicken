local Vector2 = require 'math.vector2'

local com = ecs.newcom('logic.transform')
function com:ctor(pos)
	self.position = Vector2(pos[1], pos[2])
	self.direction = Vector2(0, -1)
	self.speed = 0.7
	self.velocity = Vector2(0, 0)
end