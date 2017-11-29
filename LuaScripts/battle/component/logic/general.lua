local com = ecs.newcom('general')
function com:ctor( ... )
	self.retinues = {}
	self.maxRange = 20
end