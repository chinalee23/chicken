local com = ecs.newcom('logic.animation')
function com:ctor(animName, idleName, runName, skillName)
	self.anim = animName

	self.idleName = idleName
	self.runName = runName
	self.skillName = skillName
end