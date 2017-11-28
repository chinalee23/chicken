local _M = module()

frameMaxInterval = 0

local json = require 'util.dkjson'

local function startOffline( ... )
	myid = 1

	local addnpc = function( ... )
		for i = 1, 100 do
			table.insert(_M.battleData.npcs, {pos = {math.random(0, 100), math.random(0, 100)}})
		end
		-- table.insert(_M.battleData.npcs, {pos = {50, 55}})
	end

	local addweapon = function( ... )
		-- for i = 1, 10 do
		-- 	table.insert(_M.battleData.weapons, {id = 1, pos = {math.random(0, 100), math.random(0, 100)}})
		-- end
		table.insert(_M.battleData.weapons, {id = 1, pos = {55, 55}})
		table.insert(_M.battleData.weapons, {id = 2, pos = {55, 65}})
		table.insert(_M.battleData.weapons, {id = 3, pos = {55, 75}})
		table.insert(_M.battleData.weapons, {id = 4, pos = {55, 85}})
	end

	_M.battleData = {
		characters = {
			{id = myid, pos = {50, 50}},
			{id = 10, pos = {65, 65}},
		},
		seed = os.time(),
		npcs = {},
		weapons = {},
	}
	-- addnpc()
	addweapon()

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