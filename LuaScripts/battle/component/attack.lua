local com = ecs.newcom('attack')
function com:ctor(attDist, attFrame, totalFrame)
	self.attDist = attDist or 0
	self.status = 'idle'
	self.startFrame = 0
	self.attFrame = attFrame or 0
	self.totalFrame = totalFrame or 0
	self.target = 0
end