local _M = module()

local game = require 'game'
local world = require 'battle.world'
local input = require 'battle.input'

local started = false

local function fixedUpdate( ... )
	if not started then return end
	-- table.insert(ecs.Single.input.inputs, {
	-- 	id = world.getPlayerEntityId(game.myid),
	-- 	direction = input.direction,
	-- 	blink = input.blink,
	-- 	accelerate = input.accelerate,
	-- 	slowdown = input.slowdown,
	-- 	highcamera = input.highcamera,
	-- 	lowcamera = input.lowcamera,
	-- })
	local eid = world.getPlayerEntityId(game.myid)
	ecs.Single.inputs[eid] = {
		direction = (input.direction.x ~= 0 or input.direction.y ~= 0) and input.direction:Clone() or nil,
		attType = input.attType,
		accelerate = input.accelerate,
	}
	input.reset()
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
	world.init()
	LuaInterface.LoadScene('set_5v5')
end

events.update.addListener(update)
events.fixedUpdate.addListener(fixedUpdate)
events.battleMonoPrepared.addListener(onBattleMonoPrepared)

return _M