local com = ecs.newcom('unit')
function com:ctor(root, prefab, scale)
	self.gameObject = nil

	self.root = root
	self.prefab = prefab
	self.scale = scale or 1

	self.currPos = nil
	self.tarPos = nil

	self.currAnim = nil
end