local _M = module()

local json = require 'util.dkjson'

local function startOffline( ... )
	myid = 1

	local data = {
		{id = 1, pos = {200, 200}, size = 20},
	}
	local battle = require 'battle.battle_offline'
	battle.start(data)
end

local function startOnline( ... )
	local battle = require 'battle.battle_online'
	battle.start()
end

function start(online)
	if online then
		startOnline()
	else
		startOffline()
	end
end

return _M