local Vector2 = require 'math.vector2'

local com = ecs.newcom('logic.weapon')
function com:ctor(id, pos)
	self.id = id
	self.position = Vector2(pos[1], pos[2])
	self.owner = nil
end