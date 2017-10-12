local _M = {}

local battleLogic = require 'battle.logic.battle_logic'

local input = CS.UnityEngine.Input
local KeyCode = CS.UnityEngine.KeyCode

local battleStarted = false

local function updateInput( ... )
	if input.GetKey(KeyCode.W) then
	end
end

function _M.start(data)
	_M.battleData = data

	battleLogic.start(data)
	LuaInterface.LoadScene('main')
end

function _M.update( ... )
	if not battleStarted then return end
	updateInput()
end

function _M.fixedUpdate( ... )
	if not battleStarted then return end
end

return _M