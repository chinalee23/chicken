local com = ecs.newcom('property')
function com:ctor(speed)
	self.speed = speed or 1
end