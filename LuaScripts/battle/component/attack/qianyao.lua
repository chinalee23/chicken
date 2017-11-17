local com = ecs.newcom('attack.qianyao')
function com:ctor(target, frame)
	self.target = target
	self.startFrame = frame
end