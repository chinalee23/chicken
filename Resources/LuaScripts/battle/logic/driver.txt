local _M = module()

local CHARACTER = require 'battle.logic.character'

local sysMove = require 'battle.logic.sys_move'
local sysFood = require 'battle.logic.sys_food'

characters = {}
foods = {}

function prepare(data)
	for _, v in ipairs(data) do
		local c = instance(CHARACTER, v)
		characters[v.id] = c
	end
end

function go( ... )
	sysMove.calc(characters)
	sysFood.calc(characters)
end

return _M