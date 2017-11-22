local Vector2 = require 'math.vector2'

local com = ecs.newcom('playercontrolled')
function com:ctor( ... )
	self.avatar = 0
	self.direction = Vector2(0, 0)
end