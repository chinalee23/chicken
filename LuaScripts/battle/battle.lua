local _M = module()

local game = require 'game'
local driver = require 'battle.logic.driver'
local input = require 'battle.input'

local started = false

local function fixedUpdate( ... )
	if not started then return end

	local command = input.getCommand()
	driver.characters[game.myid]:setCommand(command)

	driver.go()
end

local function update( ... )
	if not started then return end

	input.update()
end

function start(data)
	driver.prepare(data)
	LuaInterface.LoadPrefab('Prefab/battle')

	started = true
end

events.update.add_listener(update)
events.fixedUpdate.add_listener(fixedUpdate)

return _M