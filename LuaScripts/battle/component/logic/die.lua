local com = ecs.newcom('die')
function com:ctor( ... )
	self.dying = false
	self.startFrame = 0
end