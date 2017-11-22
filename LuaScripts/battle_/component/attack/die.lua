local com = ecs.newcom('attack.die')
function com:ctor()
	self.dying = false
	self.startFrame = nil
end