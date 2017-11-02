local com = ecs.newcom('playercamera')
function com:ctor(go)
	self.gameObject = go
	self.trans = go.transform
	self.offset = UnityEngine.Vector3(0, 0, 0)
end