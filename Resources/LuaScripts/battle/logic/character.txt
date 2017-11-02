local _M = {}

-- map size
local width = 1136
local height = 640

function _M:ctor(data)
	self.id = data.id
	self.position = Vector2(data.pos[1], data.pos[2])
	self.size = data.size
	self.command = nil
	self.moved = false
end

function _M:setCommand(command)
	self.command = command
end

function _M:setPosition(pos)
	local newPos = pos or self.position
	local offset = self.size / 2
	newPos.x = math.max(newPos.x, 1+self.size/2)
	newPos.x = math.min(newPos.x, width-self.size/2+1)
	newPos.y = math.max(newPos.y, 1+self.size/2)
	newPos.y = math.min(newPos.y, height-self.size/2+1)

	if self.position ~= newPos then
		self.position = newPos
		self.moved = true
	end
end

function _M:calcBound( ... )
	return {
		self.position.x - self.size/2, self.position.x + self.size/2,
		self.position.y - self.size/2, self.position.y + self.size/2,
	}
end

return _M