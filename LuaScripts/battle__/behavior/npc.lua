local _M = {}

function _M:ctor(c, root)
	self.lc = c
	self.gameObject = LuaInterface.LoadPrefab('Prefab/npc/N_pikeman_01/N_pikeman_01_low', root)
	self.trans = self.gameObject.transform
	LuaInterface.SetLocalScale(self.gameObject, 1, 1, 1)
	LuaInterface.SetLocalPosition(self.gameObject, c.position.x, 0, c.position.y)
	self.moving = false
end

function _M:go()
	if self.lc.moving then
		self.moving = true
		LuaInterface.PlayAnimation(self.gameObject, 'run')
	elseif not self.lc.moving and self.moving then
		self.moving = false
		LuaInterface.PlayAnimation(self.gameObject, 'idle1')
	end

	local pos = UnityEngine.Vector3(self.lc.position.x, 0, self.lc.position.y)
	self.trans:LookAt(pos)
	self.trans.localPosition = pos
end

return _M