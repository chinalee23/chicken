local com = ecs.newcom('attack.dismiss')
function com:ctor()
	self.dismissing = false
	self.startFrame = nil
end