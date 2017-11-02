local _M = module()

function reset( ... )
	inorigin = true
	direction = Vector2(0, 0)
	blink = false
	accelerate = false
	slowdown = false
	highcamera = false
	lowcamera = false
end

reset()

return _M