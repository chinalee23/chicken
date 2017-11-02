local _M = module()

local net = require 'net.net'
local json = require 'util.dkjson'
local game = require 'game'
local driver = require 'battle.logic.driver'
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

	local command = input.getCommand()
	if command[1] or command[2] or command[3] or command[4] then
		sendCommand(command)
	end
end

local function update( ... )
	if not started then return end

	input.update()
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

	local data = {}
	for i = 1, #msg.ids do
		local t = {id = msg.ids[i], pos = {msg.x[i], msg.y[i]}, size = 20}
		table.insert(data, t)
	end

	driver.prepare(data)
	LuaInterface.LoadPrefab('Prefab/battle')
end

local function onFight(msg)
	started = true
end

local function onFrame(msg)
	if msg.frames then
		for _, v in ipairs(msg.frames) do
			driver.characters[v.id]:setCommand(v.command)
		end
	end
	
	driver.go()
end

local function onBattleMonoPrepared( ... )
	local jd = json.encode({
			msgType = 'ready',
		})
	net.send(jd)
end

function start( ... )
	net.connect('192.168.59.128', 12345, onConnect)
end

events.update.addListener(update)
events.fixedUpdate.addListener(fixedUpdate)
events.battleMonoPrepared.addListener(onBattleMonoPrepared)

net.addListener('enterRsp', onEnterRsp)
net.addListener('start', onStart)
net.addListener('fight', onFight)
net.addListener('frame', onFrame)

return _M