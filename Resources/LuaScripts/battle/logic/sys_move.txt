local _M = module()

local speed = 5
local sqrt = math.sqrt(speed * speed / 2)

function calc(characters)
	for _, v in pairs(characters) do
		if v.command then
			local x = 0
			local y = 0

			if v.command[1] then
				y = speed
			elseif v.command[2] then
				y = -speed
			end

			if v.command[3] then
				x = -speed
			elseif v.command[4] then
				x = speed
			end

			if x*y ~= 0 then
				x = x > 0 and sqrt or -sqrt
				y = y > 0 and sqrt or -sqrt
			end

			v:setPosition(v.position + Vector2(x, y))
			v.command = nil
		else
			v.moved = false
		end
	end
end

return _M