local _M = {}

function _M:ctor(data, root)
	self.id = data.id

	self.gameObject = LuaInterface.LoadPrefab('Prefab/Block', root)
end

return _M