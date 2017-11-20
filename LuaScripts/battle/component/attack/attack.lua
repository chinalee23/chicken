local com = ecs.newcom('attack.attack')
function com:ctor( ... )
	self.attacker = nil
	self.attackee = nil
end