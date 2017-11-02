local com = ecs.newcom('troop')
function com:ctor(rank, generalId)
	self.rank = rank
	self.generalId = generalId
	self.retinues = {}
end