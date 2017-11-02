local _M = module()

local game = require 'game'
local world = require 'battle.world'
local input = require 'battle.input'

local started = false

local function fixedUpdate( ... )
	if not started then return end
	table.insert(ecs.Single.input.inputs, {
		id = world.getPlayerEntityId(game.myid),
		direction = input.direction,
	})
	world.frameCalc()
end

local function update( ... )
	if not started then return end
	world.update()
end

local function onBattleMonoPrepared( ... )
	started = true
end

function start()
	started = false
	LuaInterface.LoadScene('01battlefield_grass_ad_1v1')
end

events.update.addListener(update)
events.fixedUpdate.addListener(fixedUpdate)
events.battleMonoPrepared.addListener(onBattleMonoPrepared)

return _M