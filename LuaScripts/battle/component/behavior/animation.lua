local com = ecs.newcom('behavior.animation')
function com:ctor(go)
	self.gameObject = go
	self.currAnim = nil
end