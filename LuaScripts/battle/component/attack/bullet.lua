local com = ecs.newcom('attack.bullet')
function com:ctor( ... )
	self.target = nil
end