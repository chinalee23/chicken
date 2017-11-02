local com = ecs.newcom('view')
function com:ctor(root, prefab)
	self.root = root
	self.prefab = prefab
	self.gameObject = nil
	self.trans = nil
	self.moving = false
	self.targetPos = Vector2(0, 0)
	self.moveTime = 0.1
end