local com = ecs.newcom('bullet')
function com:ctor(att, target)
	self.att = att or 1
	self.target = target
	self.speed = 2
	self.hit = false
end