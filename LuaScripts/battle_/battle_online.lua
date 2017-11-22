local Vector2 = require 'math.Vector2'

local _M = module()

local net = require 'net.net'
local json = require 'util.dkjson'
local game = require 'game'
local world = require 'battle.world'
local input = require 'battle.input'

local started = false
local playerCount = 0
local roomid = 0

local function fixedUpdate( ... )
	if not started then return end

	local jd = json.encode({
			msgType = 'frame',
			data = {
				id = game.myid,
				direction = {input.direction.x, input.direction.y},
				blink = input.blink,
				accelerate = input.accelerate,
				slowdown = input.slowdown,
				highcamera = input.highcamera,
				lowcamera = input.lowcamera,
			},
		})
	-- log.info(jd)
	input.reset()
	net.send(jd)
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
	roomid = msg.roomId
end

local function onPlayerCount(msg)
	log.info('onPlayerCount', msg.playerCount)
	playerCount = msg.playerCount
end

local function onStart(msg)
	local data = {
		characters = {},
		seed = msg.seed,
		npcs = {}
	}
	for i = 1, #msg.ids do
		local t = {id = msg.ids[i], pos = {msg.x[i], msg.y[i]}}
		table.insert(data.characters, t)
	end
	for i = 1, #msg.nx do
		local t = {pos = {msg.nx[i], msg.ny[i]}}
		table.insert(data.npcs, t)
	end
	game.battleData = data

	world.init()
	LuaInterface.LoadScene('01battlefield_grass_ad_1v1')
end

local function onFight(msg)
	log.info('fight')
	started = true
end

local lastFrameTime = 0
local function onFrame(msg)
	local now = Time.realtimeSinceStartup
	if lastFrameTime == 0 then
		lastFrameTime = now
	else
		local offset = now - lastFrameTime
		lastFrameTime = now
		if offset > game.frameMaxInterval then
			game.frameMaxInterval = offset
		end
	end
	
	
	local input = ecs.Single.input.inputs
	if msg.frames then
		for _, v in ipairs(msg.frames) do
			table.insert(input, {
				id = world.getPlayerEntityId(v.id),
				direction = Vector2(v.direction[1], v.direction[2]),
				blink = v.blink,
				accelerate = v.accelerate,
				slowdown = v.slowdown,
				highcamera = v.highcamera,
				lowcamera = v.lowcamera,
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
	net.connect('192.168.10.238', 12345, onConnect)
end

function roomStart( ... )
	log.info('room start')
	local jd = json.encode({
			msgType = 'start',
		})
	net.send(jd)
end

function getPlayerCount( ... )
	return playerCount
end

function getRoomId( ... )
	return roomid
end

events.update.addListener(update)
events.fixedUpdate.addListener(fixedUpdate)
events.battleMonoPrepared.addListener(onBattleMonoPrepared)

net.addListener('enterRsp', onEnterRsp)
net.addListener('start', onStart)
net.addListener('fight', onFight)
net.addListener('frame', onFrame)
net.addListener('playerCount', onPlayerCount)

return _M