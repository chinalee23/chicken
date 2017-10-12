local _M = {}

function _M:ctor(data)
	self.id = data.id
	self.position = Vector3(0, 0)
end

return _M