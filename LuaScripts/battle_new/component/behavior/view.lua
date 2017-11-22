local com = ecs.newcom('view')
function com:ctor( ... )
	self.gameObject = nil
	self.currPos = nil
	self.tarPos = nil
end