local _M = {}

local speed = 2
local sqrt = math.sqrt(speed / 2)

function _M:ctor(data)
	self.id = data.id
	self.position = Vector2(data.pos[1], data.pos[2])
	self.size = data.size
	self.command = nil
end

function _M:setCommand(command)
	self.command = command
end

function _M:calc( ... )
	if not self.command then return end
	
	local x = 0
	local y = 0

	if self.command[1] and not self.command[2] then
		y = speed
	elseif self.command[2] and not self.command[1] then
		y = -speed
	end

	if self.command[3] and not self.command[4] then
		x = -speed
	elseif self.command[4] and not self.command[3] then
		x = speed
	end

	if x*y ~= 0 then
		x = x > 0 and sqrt or -sqrt
		y = y > 0 and sqrt or -sqrt
	end

	self.position = self.position + Vector2(x, y)
end

return _M