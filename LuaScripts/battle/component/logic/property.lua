local com = ecs.newcom('property')
function com:ctor(speed, attDist, att, def, hp)
	self.speed = speed or 1

	self.attDist = attDist or 0
	self.att = att or 1
	self.def = def or 1

	self.hp = hp or 10000
	self.hpmax = self.hp

	self.qianyaoFrame = 3
	self.totalFrame = 10
	self.lengqueFrame = 5
	self.attType = 'yuancheng'
end