local Vector2 = require 'math.Vector2'

local _M = {}

function _M.reset( ... )
	_M.direction = Vector2(0, 0)
	_M.attType = nil
	_M.accelerate = nil
end

_M.reset()

return _M