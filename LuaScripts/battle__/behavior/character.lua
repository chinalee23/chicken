local _M = {}

local game = require 'game'
local driver = require 'battle.logic.driver'

function _M:ctor(c, root)
	self.id = c.id
	self.lc = c
	self.gameObject = LuaInterface.LoadPrefab('Prefab/Player/Male01/male01_base_prefab', root)
	self.trans = self.gameObject.transform
	LuaInterface.SetLocalPosition(self.gameObject, c.position.x, 0, c.position.y)
	LuaInterface.SetLocalScale(self.gameObject, 1.5, 1.5, 1.5)
	self.moving = false

	if self.id == game.myid then
		log.info('myid', self.id, c.position.x, c.position.y)
		self.transCamera = LuaInterface.Find(root, 'Camera').transform
		self.cameraOffset = self.transCamera.localPosition
		self.transCamera.localPosition = self.cameraOffset + UnityEngine.Vector3(c.position.x, 0, c.position.y)
	end
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

	if self.id == game.myid then
		self.transCamera.localPosition = self.cameraOffset + pos
	end
end

return _M