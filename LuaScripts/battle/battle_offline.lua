local _M = module()

local game = require 'game'
local driver = require 'battle.logic.driver'
local input = require 'battle.input'

local started = false

local function fixedUpdate( ... )
	if not started then return end

	local command = input.getCommand()
	if command[1] or command[2] or command[3] or command[4] then
		driver.characters[game.myid]:setCommand(command)
	end

	driver.go()
end

local function update( ... )
	if not started then return end

	input.update()
end

local function onBattleMonoPrepared( ... )
	started = true
end

function start(data)
	driver.prepare(data)
	LuaInterface.LoadPrefab('Prefab/battle')
end

events.update.addListener(update)
events.fixedUpdate.addListener(fixedUpdate)
events.battleMonoPrepared.addListener(onBattleMonoPrepared)

return _M