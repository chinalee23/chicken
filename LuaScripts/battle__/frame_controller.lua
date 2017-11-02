local _M = module()

local frameNo = 0
local online
local logic

input = {}
frames = {}

local function fixedupdate( ... )
	if online then
		if #input > 0 then
			local data = dataParser.encode(input)
			net.send(data)
		end
	else
		logic(input)
		input = {}
	end
end

local function onFrame(data)
	local input = dataParser.decode(data)
	table.insert(frames, input)
	events.frameReceived()
end

function init(online, logic)
	online = online
	logic = logic
end

return _M