local _M = module()

local input = CS.UnityEngine.Input
local keyCode = CS.UnityEngine.KeyCode

local up = false
local down = false
local left = false
local right = false

function update( ... )
	if input.GetKey(keyCode.W) then
		up = true
	end
	if input.GetKey(keyCode.S) then
		down = true
	end
	if input.GetKey(keyCode.A) then
		left = true
	end
	if input.GetKey(keyCode.D) then
		right = true
	end
end

function getCommand( ... )
	local rst = {up, down, left, right}
	up = false
	down = false
	left = false
	right = false
	
	return rst
end

return _M