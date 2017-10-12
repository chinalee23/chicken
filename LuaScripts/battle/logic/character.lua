local _M = {}

local speed = 2
local sqrt = math.sqrt(speed / 2)

function _M:ctor(data)
	self.id = data.id
	self.position = Vector2(data.pos[1], data.pos[2])
	self.size = data.size
end

function _M:setCommand(command)
	local x = 0
	local y = 0

	if command[1] and not command[2] then
		y = speed
	elseif command[2] and not command[1] then
		y = -speed
	end

	if command[3] and not command[4] then
		x = -speed
	elseif command[4] and not command[3] then
		x = speed
	end

	if x*y ~= 0 then
		x = x > 0 and sqrt or -sqrt
		y = y > 0 and sqrt or -sqrt
	end

	self.position = self.position + Vector2(x, y)
end

return _M