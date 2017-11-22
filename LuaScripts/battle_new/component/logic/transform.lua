local com = ecs.newcom('transform')
function com:ctor( ... )
	self.position = nil
	self.direction = nil
	self.face = nil
end