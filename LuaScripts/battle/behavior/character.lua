local _M = {}

local driver = require 'battle.logic.driver'

function _M:ctor(id, root)
	self.id = id
	self.gameObject = LuaInterface.LoadPrefab('Prefab/Block', root)
	self.gameObject.name = id
end

function _M:update()
	local lc = driver.characters[self.id]
	LuaInterface.SetLocalPosition(self.gameObject, lc.position.x, lc.position.y, 0)
	LuaInterface.SetLocalScale(self.gameObject, lc.size, lc.size, 1)
end

return _M