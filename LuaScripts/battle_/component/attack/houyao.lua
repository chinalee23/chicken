local com = ecs.newcom('attack.houyao')
function com:ctor(target, frame)
	self.target = target
	self.startFrame = frame
end