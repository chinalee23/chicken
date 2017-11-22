local Vector2 = require 'math.Vector2'

local com = ecs.newcom('view')
function com:ctor(root, prefab, scale, idle)
	self.root = root
	self.prefab = prefab
	self.scale = scale or 1
	self.gameObject = nil
	self.trans = nil
	self.targetPos = Vector2(0, 0)
	self.moveTime = 0.1
	self.moveStartTime = 0
	self.moveStartPos = Vector2(0, 0)
end