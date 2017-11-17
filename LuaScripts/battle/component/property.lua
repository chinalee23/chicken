local com = ecs.newcom('property')
function com:ctor(att, def, hp, attDist, attSpeed, qianyaoFrame, houyaoFrame, dieFrame)
	self.att = att
	self.def = def
	self.hpMax = hp
	self.hp = hp

	self.attDist = attDist
	self.attSpeed = attSpeed
	self.qianyaoFrame = qianyaoFrame
	self.houyaoFrame = houyaoFrame
	self.dieFrame = dieFrame
end