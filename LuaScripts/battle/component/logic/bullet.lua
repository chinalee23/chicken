local com = ecs.newcom('bullet')
function com:ctor( ... )
	self.att = 0
	self.target = nil
	self.speed = 0
end