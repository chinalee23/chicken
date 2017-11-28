local com = ecs.newcom('behavior.weapon')
function com:ctor(id, go)
	self.id = id
	self.gameObject = go

	self.equipped = false
	self.showing = true
end