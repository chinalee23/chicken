local CHARACTER = require 'battle.behavior.character'
local game = require 'game'

local _M = {}
local characters

function _M.start(root)
	local data = game.battle.battleData

	characters = {}
	for _, v in ipairs(data) do
		local c = instance(CHARACTER, v, root)
		characters[v.id] = c
	end
end

function _M.executeData(c, data)
	LuaInterface.SetLocalPosition(c.gameObject, data.position[1], data.position[2], 0)
end

function _M.go(data)
	for _, v in ipairs(data) do
		local c = characters[v.id]
		executeData(c, v.data)
	end
end

return _M