local com = ecs.newcom('behavior.transform')
function com:ctor(go, scale, height)
	self.gameObject = go
	self.scale = scale or 1
	self.currPos = nil
	self.tarPos = nil
	self.height = height or 0

	self.moveStartPos = nil
	self.moveStartTime = 0
	self.moveTime = 0
end