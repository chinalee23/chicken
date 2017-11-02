local _M = module()

local net = require 'net.net'
local json = require 'util.dkjson'
local game = require 'game'
local world = require 'battle.world'
local input = require 'battle.input'

local started = false

local function sendCommand(command)
	local jd = json.encode({
			msgType = 'frame',
			data = {
				id = game.myid,
				command = command,
			},
		})
	net.send(jd)
end

local function fixedUpdate( ... )
	if not started then return end

	if not input.inorigin then
		local jd = json.encode({
				msgType = 'frame',
				data = {
					id = game.myid,
					direction = {input.direction.x, input.direction.y},
				},
			})
		net.send(jd)
	end
end

local function update( ... )
	if not started then return end
	world.update()
end

local function onConnect(status)
	if not status then
		log.info('connect failed!!')
		return
	end

	log.info('connect success')
	local jd = json.encode({
			msgType = 'enter',
		})
	net.send(jd)
end

local function onEnterRsp(msg)
	log.info('id', msg.id)
	game.myid = msg.id
end

local function onStart(msg)
	table.print(msg)

	local data = {
		characters = {},
		seed = msg.seed,
	}
	for i = 1, #msg.ids do
		local t = {id = msg.ids[i], pos = {msg.x[i], msg.y[i]}}
		table.insert(data.characters, t)
	end
	game.battleData = data
	
	LuaInterface.LoadScene('01battlefield_grass_ad_1v1')
end

local function onFight(msg)
	log.info('fight')
	started = true
end

local function onFrame(msg)
	local input = ecs.Single.input.inputs
	if msg.frames then
		for _, v in ipairs(msg.frames) do
			table.insert(input, {
				id = world.getPlayerEntityId(v.id),
				direction = Vector2(v.direction[1], v.direction[2])
			})
		end
	end
	world.frameCalc()
end

local function onBattleMonoPrepared( ... )
	local jd = json.encode({
			msgType = 'ready',
		})
	net.send(jd)
end

function start( ... )
	net.connect('192.168.142.140', 12345, onConnect)
end

events.update.addListener(update)
events.fixedUpdate.addListener(fixedUpdate)
events.battleMonoPrepared.addListener(onBattleMonoPrepared)

net.addListener('enterRsp', onEnterRsp)
net.addListener('start', onStart)
net.addListener('fight', onFight)
net.addListener('frame', onFrame)

return _M