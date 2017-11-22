local Vector3 = require 'math.vector3'

local com = ecs.newcom('playercamera')
function com:ctor(go)
	self.gameObject = go
	self.offset = Vector3(2.2, 16.7, -17.7)
end