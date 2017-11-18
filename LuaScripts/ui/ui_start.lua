local battleOnline = require 'battle.battle_online'

local _M = module()

local gameObject
local goOperate
local room = {}

function awake(go)
	gameObject = go

	goOperate = LuaInterface.Find(go, 'Operate')
	local btnOnline = LuaInterface.Find(goOperate, 'BtnOnline')
	local btnOffline = LuaInterface.Find(goOperate, 'BtnOffline')

	local cb = function (btn)
		local game = require 'game'
		if btn == btnOnline then
			log.info('click online')
			game.start(true)
			goOperate:SetActive(false)
			room.go:SetActive(true)
		else
			game.start(false)
		end
	end
	LuaInterface.AddClick(btnOnline, cb)
	LuaInterface.AddClick(btnOffline, cb)

	room.go = LuaInterface.Find(go, 'Room')
	room.btn = LuaInterface.Find(room.go, 'Button')
	room.txtPlayerCnt = LuaInterface.Find(room.go, 'TextPlayerCnt', 'Text')
	room.txtRoomId = LuaInterface.Find(room.go, 'TextRoomId', 'Text')
	LuaInterface.AddClick(room.btn, function ( ... )
		battleOnline.roomStart()
	end)
	room.go:SetActive(false)
end




function start( ... )
	-- body
end

function update( ... )
	room.txtPlayerCnt.text = '当前房间人数：' .. battleOnline.getPlayerCount()
	room.txtRoomId.text = '房间号：' .. battleOnline.getRoomId()
end

function ondestroy( ... )
	
end

function fixedupdate( ... )
	-- body
end

return _M