local com = ecs.newcom('attack')
function com:ctor( ... )
	self.status = 'idle'
	self.target = nil
	self.startFrame = 0
end