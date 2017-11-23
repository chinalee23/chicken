local com = ecs.newcom('logic.weapon')
function com:ctor(id, level)
	self.id = id
	self.level = level or 1
end