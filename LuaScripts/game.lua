local _M = module()

frameMaxInterval = 0

local json = require 'util.dkjson'

local function startOffline( ... )
	myid = 1

	_M.battleData = {
		characters = {
			{id = myid, pos = {50, 50}},
			-- {id = 10, pos = {10, 10}},
		},
		seed = os.time(),
		-- seed = 1511398247,
		npcs = {},
	}
	for i = 1, 100 do
		table.insert(_M.battleData.npcs, {pos = {math.random(25, 75), math.random(25, 75)}})
	end
	-- table.insert(_M.battleData.npcs, {pos = {41, 51}})

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