local _M = ecs.newcom('rvo')
function _M:ctor(enableObstacle)
	self.agentIndex = -1

	self.enableObstacle = enableObstacle
	self.obstacleIndex = -1
end