local com = ecs.newcom('view')
function com:ctor(root, prefab, scale)
	self.root = root
	self.prefab = prefab
	self.scale = scale or 1
	self.gameObject = nil
	self.trans = nil
	self.moving = false
	self.targetPos = Vector2(0, 0)
	self.moveTime = 0.1
	self.moveStartTime = 0
	self.moveStartPos = UnityEngine.Vector3(0, 0, 0)
end