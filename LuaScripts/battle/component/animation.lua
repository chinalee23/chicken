local _M = ecs.newcom('animation')
function _M:ctor( ... )
	self.currAnim = nil
	
	self.tarAnim = nil
	self.tarSpeed = 1
end