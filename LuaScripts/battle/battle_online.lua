local Vector2 = require 'math.Vector2'
local pb = require 'protobuf.protobuf'
local cfgSvr = require 'config.server'

local _M = module()

local net = require 'net.net'
local game = require 'game'
local world = require 'battle.world'
local input = require 'battle.input'

local started = false
local playerCount = 0
local roomid = 0

local function fixedUpdate( ... )
	if not started then return end

	local flag = false
	local t = {}
	if input.direction.x ~= 0 or input.direction.y ~= 0 then
		flag = true
		t.direction = {x = input.direction.x, y = input.direction.y}
	end
	if input.attType then
		flag = true
		t.attType = input.attType
	end
	if input.accelerate then
		flag = true
		t.accelerate = input.accelerate
	end
	if flag then
		local msg = pb.encode('sgio.battle.Frame', t)
		net.send('frame', msg)
		input.reset()
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

	net.send('enter')
end

local function onEnterRsp(msg)
	log.info('id', msg.playerid, 'room', msg.roomid)
	game.myid = msg.playerid
	roomid = msg.roomid
end

local function onPlayerCount(msg)
	log.info('onPlayerCount', msg.count)
	playerCount = msg.count
end

local function onStart(msg)
	log.info('start...')
	local data = {
		characters = {},
		seed = msg.seed,
		npcs = {},
		weapons = {},
	}
	for i = 1, #msg.players do
		local t = {id = msg.players[i].id, pos = {msg.players[i].pos.x, msg.players[i].pos.y}}
		table.insert(data.characters, t)
	end
	for i = 1, #msg.npcs do
		local t = {pos = {msg.npcs[i].pos.x, msg.npcs[i].pos.y}}
		table.insert(data.npcs, t)
	end
	for i = 1, #msg.weapons do
		local t = {id = msg.weapons[i].id, pos = {msg.weapons[i].pos.x, msg.weapons[i].pos.y}}
		table.insert(data.weapons, t)
	end
	game.battleData = data

	world.init()
	LuaInterface.LoadScene('set_5v5')
end

local function onFight(msg)
	log.info('fight')
	started = true
end

local lastFrameTime = 0
local function onFrames(msg)
	local now = Time.realtimeSinceStartup
	if lastFrameTime == 0 then
		lastFrameTime = now
	else
		local offset = now - lastFrameTime
		lastFrameTime = now
		game.frameLastInterval = offset
		if offset > game.frameMaxInterval then
			game.frameMaxInterval = offset
		end
	end
	
	
	local inputs = ecs.Single.inputs
	for _, v in ipairs(msg.frames) do
		local eid = world.getPlayerEntityId(v.playerid)
		inputs[eid] = {}
		if not math.approximate(v.direction.x, 0) or not math.approximate(v.direction.y, 0) then
			inputs[eid].direction = Vector2(v.direction.x, v.direction.y)
		end
		if v.attType ~= '' then
			inputs[eid].attType = v.attType
		end
		if v.accelerate ~= '' then
			inputs[eid].accelerate = v.accelerate
		end
	end
	world.frameCalc()
end

local function onBattleMonoPrepared( ... )
	net.send('ready')
end

function start( ... )
	log.info(cfgSvr.ip .. ':' .. cfgSvr.port)
	net.connect(cfgSvr.ip, cfgSvr.port, onConnect)
end

function roomStart( ... )
	log.info('room start')
	net.send('start')
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

net.addListener('enter', onEnterRsp, 'sgio.battle.Enter')
net.addListener('start', onStart, 'sgio.battle.BattleStart')
net.addListener('fight', onFight, 'sgio.battle.BattleStart')
net.addListener('frame', onFrames, 'sgio.battle.Frames')
net.addListener('playercount', onPlayerCount, 'sgio.battle.PlayerCount')

return _M