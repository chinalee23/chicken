local com = ecs.newcom('attack.bullet')
function com:ctor(attee, att, speed)
	self.attee = attee or 0
	self.att = att or 0
	self.speed = speed or 0
end