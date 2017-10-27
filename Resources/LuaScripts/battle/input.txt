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
	if up and down then
		up = false
		down = false
	end
	if left and right then
		left = false
		right = false
	end

	local rst = {up, down, left, right}
	up = false
	down = false
	left = false
	right = false
	
	return rst
end

return _M