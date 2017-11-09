local _M = module()

frameMaxInterval = 0

local json = require 'util.dkjson'

local function startOffline( ... )
	myid = 1

	_M.battleData = {
		characters = {
			{id = myid, pos = {0, 0}},
		},
		seed = os.time(),
		npcs = {},
	}
	for i = 1, 100 do
		table.insert(_M.battleData.npcs, {pos = {math.random(-100, 100), math.random(-100, 100)}})
	end
	local battle = require 'battle.battle_offline'
	battle.start()
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