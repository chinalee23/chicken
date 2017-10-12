local _M = module()

local json = require 'util.dkjson'

local online = false

local function startOffline( ... )
	myid = 1

	local data = {
		{id = 1, pos = {0, 0}, size = 20},
		{id = 2, pos = {200, 200}, size = 20},
	}
	local battle = require 'battle.battle'
	battle.start(data)
end

local function startOnline( ... )
	-- body
end

function start( ... )
	if online then
		startOnline()
	else
		startOffline()
	end
end

return _M