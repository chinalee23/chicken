local com = ecs.newcom('attacker')
function com:ctor( ... )
	self.status = 'idle'
	self.target = nil
	self.startFrame = 0

	self.weapons = {}
	self.attType = 'jinzhan'
end