local com = ecs.newcom('attack.lengque')
function com:ctor(target, frame)
	self.target = target
	self.startFrame = frame
end