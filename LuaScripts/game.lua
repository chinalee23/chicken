local _M = module()

frameMaxInterval = 0

local json = require 'util.dkjson'

local function startOffline( ... )
	myid = 1

	local addnpc = function( ... )
		for i = 1, 100 do
			table.insert(_M.battleData.npcs, {pos = {math.random(-43, 57), math.random(-66, 34)}})
		end
		-- table.insert(_M.battleData.npcs, {pos = {50, 55}})
	end

	local addweapon = function( ... )
		for i = 1, 30 do
			table.insert(_M.battleData.weapons, {id = math.random(1, 4), pos = {math.random(-43, 57), math.random(-66, 34)}})
		end
	end

	_M.battleData = {
		characters = {
			{id = myid, pos = {0, 0}},
			-- {id = 10, pos = {10, 10}},
		},
		seed = os.time(),
		-- seed = 1511927922,
		npcs = {},
		weapons = {},
	}
	addnpc()
	-- addweapon()

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