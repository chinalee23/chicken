local _M = module()

function calc(c, input)
	if input then
		c.inorigin = input.inorigin
		c.direction = input.direction
	else
		c.inorigin = true
		c.direction.x = 0
		c.direction.y = 0
	end
end

return _M